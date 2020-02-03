package simulations

import math.random
import scala.util.Random.shuffle

class EpidemySimulator extends Simulator {

  def randomBelow(i: Int) = (random * i).toInt
  def twentyFivePercent() = randomBelow(100) < 25
  def fortyPercent() = randomBelow(100) < 40

  protected[simulations] object SimConfig {
    val population: Int = 300
    val roomRows: Int = 8
    val roomColumns: Int = 8
    val numOfDays: Int = 5
    val numOfDirections: Int = 4
  }

  import SimConfig._

  val persons: List[Person] = {
    def constructPerson(n: Int): List[Person] = n match {
      case 0 => Nil
      case i => new Person(i) :: constructPerson(n - 1)
    }
    constructPerson(population)
  }

  case class Position(row: Int, col: Int) {
    def hasInfectedPersonHere(persons: List[Person]) = personsHere(persons).exists(_.infected)
    def hasInfectiousPersonHere(persons: List[Person]) = personsHere(persons).exists(_.infectious)
    def infectedPersonsHere(persons: List[Person]) = personsHere(persons).filter(_.infected)
    def notInfectedPersonsHere(persons: List[Person]) = personsHere(persons).filter(!_.infected)
    def personsHere(persons: List[Person]) = persons.filter(p => p.row == row && p.col == col)
    def up: Position = Position((row + 1) % 8, col)
    def down: Position = Position((row + 8 - 1) % 8, col)
    def right: Position = Position(row, (col + 1) % 8)
    def left: Position = Position(row, (col + 8 - 1) % 8)
  }

  class Person (val id: Int) {
    var infected = false
    var sick = false
    var immune = false
    var dead = false
    def infectious = sick || dead

    // demonstrates random number generation
    var position = Position(randomBelow(roomRows), randomBelow(roomColumns))
    var row: Int = position.row
    var col: Int = position.col

    private var actions: List[Action] = List()

    def becameSick = {
      sick = true
    }

    def probablyDie = {
      dead = twentyFivePercent
    }

    def becameImmune = {
      if (!dead) {
	sick = false
	immune = true
      }
    }

    def becameHealthy = {
      infected = false
      immune = false
    }

    def becameInfected = {
      infected = true
      this addAction (() => { afterDelay(6) { becameSick } } )
      this addAction (() => { afterDelay(14) { probablyDie } } )
      this addAction (() => { afterDelay(16) { becameImmune } } )
      this addAction (() => { afterDelay(18) { becameHealthy } } )
    }

    def becameInfectedAccordingRate = if (!infected && fortyPercent) becameInfected


    def scheduleMove(): Unit = {
      this addAction (() => { afterDelay(randomBelow(numOfDays) + 1) { if (!dead) move } } )
    }

    def move(): Unit = {
      val positions = List(position.up, position.down, position.right, position.left).filter(!_.hasInfectiousPersonHere(persons))
      if (!positions.isEmpty) {
	position = positions(randomBelow(positions.size))
	row = position.row
	col = position.col
	if (position.hasInfectedPersonHere(persons)) becameInfectedAccordingRate
      }
      scheduleMove
    }

    def addAction(a: Action): Unit = {
      actions = a :: actions
      a()
    }
  }

  for (p <- persons) p.move
  for (i <- shuffle(0 to persons.size - 1).take(3)) persons(i).becameInfected

}
