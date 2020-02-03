/**
 * Copyright (C) 2009-2013 Typesafe Inc. <http://www.typesafe.com>
 */
package actorbintree

import akka.actor._
import scala.collection.immutable.Queue

object BinaryTreeSet {

  trait Operation {
    def requester: ActorRef
    def id: Int
    def elem: Int
  }

  trait OperationReply {
    def id: Int
  }

  /** Request with identifier `id` to insert an element `elem` into the tree.
    * The actor at reference `requester` should be notified when this operation
    * is completed.
    */
  case class Insert(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request with identifier `id` to check whether an element `elem` is present
    * in the tree. The actor at reference `requester` should be notified when
    * this operation is completed.
    */
  case class Contains(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request with identifier `id` to remove the element `elem` from the tree.
    * The actor at reference `requester` should be notified when this operation
    * is completed.
    */
  case class Remove(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request to perform garbage collection*/
  case object GC

  /** Holds the answer to the Contains request with identifier `id`.
    * `result` is true if and only if the element is present in the tree.
    */
  case class ContainsResult(id: Int, result: Boolean) extends OperationReply
  
  /** Message to signal successful completion of an insert or remove operation. */
  case class OperationFinished(id: Int) extends OperationReply

}


class BinaryTreeSet extends Actor {
  import BinaryTreeSet._
  import BinaryTreeNode._

  def createRoot: ActorRef = context.actorOf(BinaryTreeNode.props(0, initiallyRemoved = true))

  var root = createRoot

  // optional
  var pendingQueue = Queue.empty[Operation]

  // optional
  def receive = normal

  // optional
  /** Accepts `Operation` and `GC` messages. */
  val normal: Receive = {
    case o: Operation => root ! o
    case GC =>
      val newRoot = createRoot
      root ! CopyTo(newRoot)
      context.become(garbageCollecting(newRoot))
  }

  // optional
  /** Handles messages while garbage collection is performed.
    * `newRoot` is the root of the new binary tree where we want to copy
    * all non-removed elements into.
    */
  def garbageCollecting(newRoot: ActorRef): Receive = {
    case CopyFinished =>
      root = newRoot
      pendingQueue.foreach(root ! _)
      pendingQueue = Queue.empty[Operation]
      context.stop(this.sender)
      context.become(normal)
    case o: Operation => pendingQueue = pendingQueue.enqueue(o)
  }

}

object BinaryTreeNode {
  trait Position

  case object Left extends Position
  case object Right extends Position

  case class CopyTo(treeNode: ActorRef)
  case object CopyFinished

  def props(elem: Int, initiallyRemoved: Boolean) = Props(classOf[BinaryTreeNode], elem, initiallyRemoved)

  def path(elem1: Int, elem2: Int) = (elem1, elem2) match {
    case (a, b) if (a > b) => Some(BinaryTreeNode.Right)
    case (a, b) if (a < b) => Some(BinaryTreeNode.Left)
    case _ => None
  }
}

class BinaryTreeNode(val elem: Int, initiallyRemoved: Boolean) extends Actor {
  import BinaryTreeNode._
  import BinaryTreeSet._

  var subtrees = Map[Position, ActorRef]()
  var removed = initiallyRemoved

  // optional
  def receive = normal

  // optional
  /** Handles `Operation` messages and `CopyTo` requests. */
  val normal: Receive = {
    case Insert(requester, id, elem) => BinaryTreeNode.path(elem, this.elem) match {
      case Some(position) => 
        if (this.subtrees.contains(position)) {
          this.subtrees(position) ! Insert(requester, id, elem)
        }
        else {
          this.subtrees += position -> context.actorOf(BinaryTreeNode.props(elem, initiallyRemoved = false))
          requester ! OperationFinished(id)
        }
      case _ =>
	this.removed = false
        requester ! OperationFinished(id)
    }
    case Contains(requester, id, elem) => BinaryTreeNode.path(elem, this.elem) match {
      case Some(position) => 
        if (this.subtrees.contains(position))
          this.subtrees(position) ! Contains(requester, id, elem)
        else
          requester ! ContainsResult(id, false)
      case _ =>
        requester ! ContainsResult(id, !this.removed)
    }
    case Remove(requester, id, elem) => BinaryTreeNode.path(elem, this.elem) match {
      case Some(position) => 
        if (this.subtrees.contains(position))
          this.subtrees(position) ! Remove(requester, id, elem)
        else
          requester ! OperationFinished(id)
      case _ =>
        this.removed = true
        requester ! OperationFinished(id)
    }
    case CopyTo(_) if (this.removed && this.subtrees.isEmpty) => this.sender ! CopyFinished
    case CopyTo(n) => 
      context.become(copying(this.subtrees.values.toSet, !this.removed))
      this.subtrees.values.foreach(_ ! CopyTo(n))
      if (!this.removed) n ! Insert(this.self, 0, this.elem)
  }

  // optional
  /** `expected` is the set of ActorRefs whose replies we are waiting for,
    * `insertConfirmed` tracks whether the copy of this node to the new tree has been confirmed.
    */
  def copying(expected: Set[ActorRef], insertConfirmed: Boolean): Receive = {
    case OperationFinished(_) =>
      if (expected.isEmpty) context.parent ! CopyFinished else context.become(copying(expected, false))
    case CopyFinished =>
      val newExpected = expected - this.sender
      context.stop(this.sender)
      if (newExpected.isEmpty && !insertConfirmed) context.parent ! CopyFinished else context.become(copying(newExpected, insertConfirmed))
  }

}
