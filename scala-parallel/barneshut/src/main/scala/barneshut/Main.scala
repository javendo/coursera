import barneshut._

object Main {
  def main(args: Array[String]) {
    val b = new Body(123f, 18f, 26f, 0f, 0f)
    val nw = Leaf(17.5f, 27.5f, 5f, Seq(b))
    val ne = Empty(22.5f, 27.5f, 5f)
    val sw = Empty(17.5f, 32.5f, 5f)
    val se = Empty(22.5f, 32.5f, 5f)
    val quad = Fork(nw, ne, sw, se)

    println(s"${quad.centerX} should be 20f")
    println(s"${quad.centerY} should be 30f")
    println(s"${quad.mass} should be 123f")
    println(s"${quad.massX} should be 18f")
    println(s"${quad.massY} should be 26f")
    println(s"${quad.total} should be 1")    
  }
}
