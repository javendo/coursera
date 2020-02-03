package kvstore

import akka.actor.{ OneForOneStrategy, Props, ActorRef, Actor }
import kvstore.Arbiter._
import scala.collection.immutable.Queue
import akka.actor.SupervisorStrategy.Restart
import scala.annotation.tailrec
import akka.pattern.{ ask, pipe }
import akka.actor.Terminated
import scala.concurrent.duration._
import akka.actor.PoisonPill
import akka.actor.OneForOneStrategy
import akka.actor.SupervisorStrategy
import akka.util.Timeout
import akka.actor.DeadLetter
import scala.util.Failure
import scala.util.Failure
import scala.concurrent.Promise
import scala.concurrent.Future
import scala.actors.AskTimeoutException
import java.util.concurrent.TimeoutException
import akka.actor.Cancellable
import scala.util.Success
import scala.util.Failure

object Replica {
  sealed trait Operation {
    def key: String
    def id: Long
  }
  case class Insert(key: String, value: String, id: Long) extends Operation
  case class Remove(key: String, id: Long) extends Operation
  case class Get(key: String, id: Long) extends Operation

  sealed trait OperationReply
  case class OperationAck(id: Long) extends OperationReply
  case class OperationFailed(id: Long) extends OperationReply
  case class GetResult(key: String, valueOption: Option[String], id: Long) extends OperationReply

  def props(arbiter: ActorRef, persistenceProps: Props): Props = Props(new Replica(arbiter, persistenceProps))
}

class Replica(val arbiter: ActorRef, persistenceProps: Props) extends Actor {
  import Replica._
  import Replicator._
  import Persistence._
  import context.dispatcher

  /*
   * The contents of this actor is just a suggestion, you can implement it in any way you like.
   */

  var kv = Map.empty[String, String]
  // a map from secondary replicas to replicators
  var secondaries = Map.empty[ActorRef, ActorRef]
  // the current set of replicators
  var replicators = Set.empty[ActorRef]
  // the last seq sent by Replicator
  var seqCounter = 0L
  var ack = Map.empty[Long, (ActorRef, Snapshot, Cancellable)]

  override val supervisorStrategy = OneForOneStrategy(maxNrOfRetries = 10, withinTimeRange = 1 second) {
    case _ => println("*******************************************************"); SupervisorStrategy.Restart
  }
  val persistence = context.actorOf(persistenceProps)
  context.watch(persistence)
  context.setReceiveTimeout(100 milliseconds)

  implicit val timeout = Timeout(1 second)

  arbiter ! Join

  def receive = {
    case JoinedPrimary => context.become(leader)
    case JoinedSecondary => context.become(replica)
  }

  /* TODO Behavior for the leader role. */
  val leader: Receive = {
    case Insert(key, value, id) => {
      ack += id -> (sender, Snapshot(key, Some(value), id), context.system.scheduler.schedule(0 milliseconds, 100 milliseconds, persistence, Persist(key, Some(value), id)))
      /*
      (persistence ? Persist(key, Some(value), id)).mapTo[Persisted]
        .map(persisted => {
          kv = kv + (key -> value)
          secondaries foreach (i => i._2 ! Replicate(key, kv.get(key), id))
          OperationAck(id)
        })
        .recoverWith {
          case _: TimeoutException => Future(OperationFailed(id))
        }
        .pipeTo(sender)
        * 
        */
    }
    case Remove(key, id) => {
      ack += id -> (sender, Snapshot(key, None, id), context.system.scheduler.schedule(0 milliseconds, 100 milliseconds, persistence, Persist(key, None, id)))
      /*
      (persistence ? Persist(key, None, id)).mapTo[Persisted]
        .map(persisted => {
          kv = kv - key
          secondaries foreach (i => i._2 ! Replicate(key, kv.get(key), id))
          OperationAck(id)
        })
        .recoverWith {
          case _: TimeoutException => Future(OperationFailed(id))
        }
        .pipeTo(sender)
        * 
        */
    }
    case Persisted(key, id) => ack.get(id) foreach {
      case (actor, Snapshot(key, Some(value), id), cancellable) => {
        cancellable.cancel
        ack -= id
        kv = kv + (key -> value)
        secondaries foreach (i => i._2 ! Replicate(key, kv.get(key), id))
        actor ! OperationAck(id)
      }
      case (actor, Snapshot(key, None, id), cancellable) => {
        cancellable.cancel
        ack -= id
        kv = kv - key
        secondaries foreach (i => i._2 ! Replicate(key, kv.get(key), id))
        actor ! OperationAck(id)
      }
    }
    case Get(key, id) => sender ! GetResult(key, kv.get(key), id)
    case Replicas(replicas) => {
      secondaries -- replicas foreach {
        i =>
          {
            secondaries -= i._1
            context.stop(i._2)
          }
      }
      replicas -- secondaries.keys filter (_ != self) foreach {
        r =>
          {
            val replicator = context.actorOf(Replicator.props(r))
            var i = 0
            kv.keys foreach {
              key =>
                replicator ! Replicate(key, kv.get(key), i)
                i += 1
            }
            secondaries += (r -> replicator)
          }
      }
      replicators = secondaries.keySet + self
    }
  }

  /* TODO Behavior for the replica role. */
  val replica: Receive = {
    case Get(key, id) => sender ! GetResult(key, kv.get(key), id)
    case Snapshot(key, valueOption, seq) if (seq == seqCounter) => {
      ack += seq -> (sender, Snapshot(key, valueOption, seq), context.system.scheduler.schedule(0 milliseconds, 100 milliseconds, persistence, Persist(key, valueOption, seq)))
    }
    case Snapshot(key, valueOption, seq) if (seq < seqCounter + 1) => {
      sender ! SnapshotAck(key, seq)
      seqCounter = seqCounter max seq + 1
    }
    case Persisted(key, seq) => ack.get(seq) foreach {
      case (actor, Snapshot(key, Some(value), seq), cancellable) => {
        cancellable.cancel
        ack -= seq
        seqCounter += 1
        kv = kv + (key -> value)
        actor ! SnapshotAck(key, seq)
      }
      case (actor, Snapshot(key, None, seq), cancellable) => {
        cancellable.cancel
        ack -= seq
        seqCounter += 1
        kv = kv - key
        actor ! SnapshotAck(key, seq)
      }
    }
  }

}
