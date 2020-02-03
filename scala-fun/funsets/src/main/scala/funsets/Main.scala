package funsets

object Main extends App {
  import FunSets._
  println(contains(singletonSet(1), 1))
  val s = union(union(singletonSet(1), singletonSet(3)), singletonSet(18))
  printSet(s)
  println(forall(s, x => x > 15))
  println(forall(s, x => x < 20))
  println(exists(s, x => x > 15))
  println(exists(s, x => x == 2))
  println(exists(s, x => x == 3))
  printSet(map(s, x => x * 2))
}
