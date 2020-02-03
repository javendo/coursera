package recfun
import common._

object Main {
  def main(args: Array[String]) {
    println("Pascal's Triangle")
    for (row <- 0 to 10) {
      for (col <- 0 to row)
        print(pascal(col, row) + " ")
      println()
    }
  }

  /**
   * Exercise 1
   */
  def pascal(c: Int, r: Int): Int = (c, r) match {
    case (col, row) if (col > row) => throw new IllegalArgumentException
    case (col, row) if (col == row) => 1
    case (0, _) => 1
    case (col, row) => pascal(col-1, row-1) + pascal(col, row-1)
  }

  /**
   * Exercise 2
   */
  def balance(chars: List[Char]): Boolean = {
    def _balance(chars: List[Char], accumulator: Int): Int = chars match {
      case Nil => accumulator
      case '(' :: tail => _balance(tail, accumulator + 1)
      case ')' :: tail => if (accumulator < 1) -1 else _balance(tail, accumulator - 1)
      case _ :: tail => _balance(tail, accumulator)
    }
    _balance(chars, 0) == 0
  }

  /**
   * Exercise 3
   */
  def countChange(money: Int, coins: List[Int]): Int = coins match {
    case Nil => 0
    case head :: tail if (money == head) => 1 + countChange(money, tail)
    case head :: tail if (money < head) => countChange(money, tail)
    case head :: tail => countChange(money - head, coins) + countChange(money, tail)
  }

}
