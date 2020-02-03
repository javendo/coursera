package simulations

import common._

class Wire {
  private var sigVal = false
  private var actions: List[Simulator#Action] = List()

  def getSignal: Boolean = sigVal

  def setSignal(s: Boolean) {
    if (s != sigVal) {
      sigVal = s
      actions.foreach(action => action())
    }
  }

  def addAction(a: Simulator#Action) {
    actions = a :: actions
    a()
  }
}

abstract class CircuitSimulator extends Simulator {

  val InverterDelay: Int
  val AndGateDelay: Int
  val OrGateDelay: Int

  def probe(name: String, wire: Wire) {
    wire addAction {
      () =>
        afterDelay(0) {
          println(
            "  " + currentTime + ": " + name + " -> " + wire.getSignal)
        }
    }
  }

  def inverter(input: Wire, output: Wire) {
    def invertAction() {
      val inputSig = input.getSignal
      afterDelay(InverterDelay) { output.setSignal(!inputSig) }
    }
    input addAction invertAction
  }

  def andGate(a1: Wire, a2: Wire, output: Wire) {
    def andAction() {
      val a1Sig = a1.getSignal
      val a2Sig = a2.getSignal
      afterDelay(AndGateDelay) { output.setSignal(a1Sig & a2Sig) }
    }
    a1 addAction andAction
    a2 addAction andAction
  }

  //
  // to complete with orGates and demux...
  //

  def orGate(a1: Wire, a2: Wire, output: Wire) {
    def orAction() {
      val a1Sig = a1.getSignal
      val a2Sig = a2.getSignal
      afterDelay(OrGateDelay) { output.setSignal(a1Sig | a2Sig) }
    }
    a1 addAction orAction
    a2 addAction orAction
  }

  def orGate2(a1: Wire, a2: Wire, output: Wire) {
    def orAction() {
      val a1Inv, a2Inv, outA1InvA2Inv = new Wire
      inverter(a1, a1Inv)
      inverter(a2, a2Inv)
      andGate(a1Inv, a2Inv, outA1InvA2Inv)
      inverter(outA1InvA2Inv, output)
    }
    a1 addAction orAction
    a2 addAction orAction
  }

  def demux(in: Wire, c: List[Wire], out: List[Wire]) {
    def demuxAction() {
      var indice: Int = 0
      def demuxAux(connectors: List[Wire], acc: Wire) {
	connectors match {
	  case Nil => {
	    out(indice).setSignal(acc.getSignal)
	    indice = indice + 1
	  }
          case h :: t => {
	    val inv, o1, o2 = new Wire
	    inverter(h, inv)
	    andGate(acc, inv, o1)
	    andGate(acc, h, o2)
	    run
	    demuxAux(t, o2)
	    demuxAux(t, o1)
	  }
	}
      }
      demuxAux(c, in)
    }
    in addAction demuxAction
    for (w <- c) w addAction demuxAction
  }
}

object Circuit extends CircuitSimulator {
  val InverterDelay = 1
  val AndGateDelay = 3
  val OrGateDelay = 5

  def andGateExample {
    val in1, in2, out = new Wire
    andGate(in1, in2, out)
    probe("in1", in1)
    probe("in2", in2)
    probe("out", out)
    in1.setSignal(false)
    in2.setSignal(false)
    run
    in1.setSignal(true)
    run
    in2.setSignal(true)
    run
  }

  def orGateExample {
    val in1, in2, out = new Wire
    orGate(in1, in2, out)
    probe("in1", in1)
    probe("in2", in2)
    probe("out", out)
    in1.setSignal(false)
    in2.setSignal(false)
    run
    in1.setSignal(true)
    run
    in2.setSignal(true)
    run
  }

  def orGate2Example {
    val in1, in2, out = new Wire
    orGate2(in1, in2, out)
    probe("in1", in1)
    probe("in2", in2)
    probe("out", out)
    in1.setSignal(false)
    in2.setSignal(false)
    run
    in1.setSignal(true)
    run
    in2.setSignal(true)
    run
  }

  def demuxExample {
  }

  //
  // to complete with orGateExample and demuxExample...
  //
}

object CircuitMain extends App {
  // You can write tests either here, or better in the test class CircuitSuite.
  Circuit.andGateExample
  Circuit.orGateExample
  Circuit.orGate2Example
}
