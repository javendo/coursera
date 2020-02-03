package nodescala

import scala.language.postfixOps
import scala.util.{Try, Success, Failure}
import scala.collection._
import scala.concurrent._
import ExecutionContext.Implicits.global
import scala.concurrent.duration._
import scala.async.Async.{async, await}
import org.scalatest._
import NodeScala._
import org.junit.runner.RunWith
import org.scalatest.junit.JUnitRunner

@RunWith(classOf[JUnitRunner])
class NodeScalaSuite extends FunSuite {

  test("A Future should always be created") {
    val always = Future.always(517)
    assert(Await.result(always, 0 nanos) == 517)
  }

  test("A Future should never be created") {
    val never = Future.never[Int]
    try {
      Await.result(never, 1 second)
      assert(false)
    }
    catch {
      case t: TimeoutException => // ok!
    }
  }

  test("any") {
    val durs = List.fill(5)(math.random).zipWithIndex
    val minIndex = durs.minBy{_._1}._2
    val fxs = durs.map {
      case (dur, idx) => {
	val p = Promise[Int]()
	Future.delay(dur seconds) onComplete {
	  case _ => p.success(idx)
	}
	p.future
      }
    }
    val any = Future.any(fxs)
    assert(Await.result(any, 1 second) === minIndex)
  }

  test("delay") {
    @volatile var test = 0;
    info("before call delay. time=" + System.currentTimeMillis)
    val fd = Future.delay(1 seconds)
    info("after call delay. time=" + System.currentTimeMillis)
    fd onComplete { case _ => test = 42 }
    Await.ready(fd, 3 seconds)
    Thread.sleep(10) // allow time for callback to be called
    assert(test === 42)
  }

  test("run") {
    var finished = false
    val working = Future.run() { ct =>
      Future {
        while (ct.nonCancelled) {
          info("working")
          Thread.sleep(100)
        }
        info("done")
        finished = true
      }
    }
    Future.delay(1 seconds) onSuccess {
      case _ => working.unsubscribe()
    }
    Await.ready(Future.delay(2 seconds), Duration.Inf)
    assert(finished)
  }

  test("now") {
    assert(1 == Future.always(1).now)
    try {
      Future.never.now
      assert(false, "Should throw TimeoutException")
    }
    catch {
      case t : NoSuchElementException =>
    }
    try {
      Future.delay(10 seconds).now
      assert(false, "Should throw NoSuchElementException")
    }
    catch {
      case t : NoSuchElementException =>
    }
  }

  test("continueWith - on failure calls continuation") {
    val broken: Future[Int] = Future.failed(new IllegalArgumentException("ups"))
    var value = 1000
    val result: Future[Int] = broken.continueWith {
      f =>
        assert(f.isCompleted)
      assert(f.value.get.isFailure)
      value = 55
      value
    }
    assert(Await.result(result, 1 second) === 55)
  }

  test("continueWith - on success calls continuation") {
    val good: Future[Int] = Future.always[Int](1)
    var value = 1000
    val result: Future[Int] = good.continueWith {
      f =>
        assert(f.isCompleted)
      assert(f.value.get.isSuccess)
      value = 55
      value
    }
    assert(Await.result(result, 1 second) === 55)
  }

  test("continue - should not throw exception") {
    val f = future(throw new Exception())
    val s = f.continue(_ => "Hello")
    assert("Hello" === Await.result(s, Duration("100 ms")))
  }

  test("continue - should throw exception") {
    val f = future(1)
    val s = f.continue(_ => throw new Exception())
    intercept[Exception] {
      Await.result(s, Duration("100 ms"))
    }
  }

  test("CancellationTokenSource should allow stopping the computation") {
    val cts = CancellationTokenSource()
    val ct = cts.cancellationToken
    val p = Promise[String]()
    async {
      while (ct.nonCancelled) {
        // do work
      }
      p.success("done")
    }
    cts.unsubscribe()
    assert(Await.result(p.future, 1 second) == "done")
  }

  class DummyExchange(val request: Request) extends Exchange {
    @volatile var response = ""
    val loaded = Promise[String]()
    def write(s: String) {
      response += s
    }
    def close() {
      loaded.success(response)
    }
  }

  class DummyListener(val port: Int, val relativePath: String) extends NodeScala.Listener {
    self =>
      @volatile private var started = false

    var handler: Exchange => Unit = null

    def createContext(h: Exchange => Unit) = this.synchronized {
      assert(started, "is server started?")
      handler = h
    }

    def removeContext() = this.synchronized {
      assert(started, "is server started?")
      handler = null
    }

    def start() = self.synchronized {
      started = true
      new Subscription {
        def unsubscribe() = self.synchronized {
          started = false
        }
      }
    }

    def emit(req: Request) = {
      val exchange = new DummyExchange(req)
      if (handler != null) handler(exchange)
      exchange
    }
  }

  class DummyServer(val port: Int) extends NodeScala {
    self =>
    val listeners = mutable.Map[String, DummyListener]()

    def createListener(relativePath: String) = {
      val l = new DummyListener(port, relativePath)
      listeners(relativePath) = l
      l
    }

    def emit(relativePath: String, req: Request) = this.synchronized {
      val l = listeners(relativePath)
      l.emit(req)
    }
  }

  test("Listener should serve the next request as a future") {
    val dummy = new DummyListener(8191, "/test")
    val subscription = dummy.start()

    def test(req: Request) {
      val f = dummy.nextRequest()
      dummy.emit(req)
      val (reqReturned, xchg) = Await.result(f, 1 second)

      assert(reqReturned == req)
    }

    test(immutable.Map("StrangeHeader" -> List("StrangeValue1")))
    test(immutable.Map("StrangeHeader" -> List("StrangeValue2")))
    subscription.unsubscribe()
  }

  test("Server should serve requests") {
    val dummy = new DummyServer(8191)
    val dummySubscription = dummy.start("/testDir") {
      request => for (kv <- request.iterator) yield (kv + "\n").toString
    }

    // wait until server is really installed
    Thread.sleep(500)

    def test(req: Request) {
      val webpage = dummy.emit("/testDir", req)
      val content = Await.result(webpage.loaded.future, 1 second)
      val expected = (for (kv <- req.iterator) yield (kv + "\n").toString).mkString
      assert(content == expected, s"'$content' vs. '$expected'")
    }

    test(immutable.Map("StrangeRequest" -> List("Does it work?")))
    test(immutable.Map("StrangeRequest" -> List("It works!")))
    test(immutable.Map("WorksForThree" -> List("Always works. Trust me.")))

    dummySubscription.unsubscribe()
  }

}




