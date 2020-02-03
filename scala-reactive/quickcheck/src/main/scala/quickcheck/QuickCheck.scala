package quickcheck

import common._

import org.scalacheck._
import Arbitrary._
import Gen._
import Prop._
import scala.util.{Try, Success, Failure}

abstract class QuickCheckHeap extends Properties("Heap") with IntHeap {

  property("Heap with one element, then the min should be the element") = forAll { a: Int => findMin(insert(a, empty)) == a }

  property("Heap with two elements, then the min should be the min of those elements") = forAll { (a: Int, b: Int) => findMin(insert(b, insert(a, empty))) == (if (a < b) a else b) }

  property("After delete min element of the Heap, the min element should be greater or equal to the element deleted") = forAll { h: H => !isEmpty(h) ==> {
    def paramShouldBeMin(param: Int, heap: H): Boolean = {
      Try(findMin(heap)) match {
	case Success(s) => (param <= s && paramShouldBeMin(s, deleteMin(heap)))
	case Failure(_) => true
      }
    }
    paramShouldBeMin(findMin(h), deleteMin(h))
  }}

  property("After delete min element of the Heap, the min element should be greater or equal to the element deleted") = forAll { (h1: H, h2: H) => {
    def bothShouldBeEqual(first: H, second: H): Boolean = {
      (Try(findMin(first)), Try(findMin(second))) match {
	case (Success(s1), Success(s2)) => (s1 == s2 && bothShouldBeEqual(deleteMin(first), deleteMin(second)))
	case (Failure(_), Failure(_)) => true
	case _ => false
      }
    }
    val firstMin = findMin(h1)
    val firstWithoutMin = deleteMin(h1)
    val secondWithMin = insert(firstMin, h2)
    bothShouldBeEqual(meld(h1, h2), meld(firstWithoutMin, secondWithMin))
  }}

  property("After insert an element in an empty Heap and deleteMin, then an empty Heap should be returned") = forAll { a: Int =>
    deleteMin(insert(a, empty)) == empty
  }

  property("After you meld an empty Heap with an element the min element should be equal to the Heap resulted of the meld an element with an empty list") = forAll { h: H => !isEmpty(h) ==> (findMin(meld(empty, h)) == findMin(meld(h, empty))) }

  property("The min of the Heap generated by the meld of two other Heaps should be the min of one of the Heaps") = forAll { (h1: H, h2: H) => (!isEmpty(h1) && !isEmpty(h2)) ==> {
    val min1 = findMin(h1); val min2 = findMin(h2)
    findMin(meld(h1, h2)) == (if (min1 < min2) min1 else min2)
  }}

  property("The min of a Heap generated by insert(a, insert(b, heap)) should be equal the min of a Heap generated by insert(b, insert(a, heap))") = forAll { (a: Int, b: Int, h: H) => findMin(insert(a, insert(b, h))) ==  findMin(insert(b, insert(a, h))) }
  
  property("After insert an element in an empty Heap, the Heap generated should not be empty") = forAll { a: Int => !isEmpty(insert(a, empty)) }
  
  lazy val genHeap: Gen[H] = for {
    k <- arbitrary[Int]
    h <- oneOf(empty, genHeap, genHeap)
  } yield insert(k, h)

  implicit lazy val arbHeap: Arbitrary[H] = Arbitrary(genHeap)

}
