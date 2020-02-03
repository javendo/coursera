(* Coursera Programming Languages, Homework 3, Provided Code *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = Anything
	     | UnitT
	     | IntT
	     | TupleT of typ list
	     | Datatype of string

(**** you can put all your code here ****)

fun only_capitals (ss : string list) =
    List.filter (fn s => Char.isUpper(String.sub(s, 0))) ss;

fun longest_string1 (ss : string list) =
     List.foldl (fn (s, acc) => if String.size(s) > String.size(acc) then s else acc) "" ss

fun longest_string2 (ss : string list) =
     List.foldl (fn (s, acc) => if String.size(s) >= String.size(acc) then s else acc) "" ss

fun longest_string_helper f ss = List.foldl (fn (s, acc) => if f(String.size(s), String.size(acc)) then s else acc) "" ss

val longest_string3 = longest_string_helper (fn (val1, val2) => val1 > val2)
    
val longest_string4 = longest_string_helper (fn (val1, val2) => val1 >= val2)

val longest_capitalized = longest_string1 o only_capitals

val rev_string = String.implode o List.rev o String.explode

fun first_answer f list =
    case list of
	[] => raise NoAnswer
      | head::tail => case f(head) of
			  NONE => first_answer f tail
			| SOME v => v

fun all_answers f list =
    let
	fun aux (acc, remainder) =
	   case remainder of
	       [] => acc
	     | head::tail => case f(head) of
				 NONE => raise NoAnswer
			       | SOME v => aux(acc @ v, tail)
    in
	SOME(aux([], list)) handle NoAnswer => NONE
    end

val count_wildcards = g (fn () => 1) (fn x => 0)

val count_wild_and_variable_lengths = g (fn () => 1) (fn x => String.size(x))

fun count_some_var (s : string, p : pattern) = g (fn () => 0) (fn x => if s = x then 1 else 0) p

fun list_of_variable p =
    case p of
	Variable x        => [x]
      | TupleP ps         => List.foldl (fn (p, acc) => acc @ list_of_variable(p)) [] ps
      | ConstructorP(_,p) => list_of_variable p
      | _                 => []

fun repeat_variables (list : string list) =
    case list of
	[] => true
      | head::tail => if List.exists (fn x => x = head) tail then false else repeat_variables tail

val check_pat = repeat_variables o list_of_variable

fun match (vp : valu * pattern) =
    let
	fun aux (vp : valu * pattern) =
	    case vp of
		(_, Wildcard) => []
	      | (v, Variable s) => [(s, v)]
	      | (Unit, UnitP) => []
	      | (Const v1, ConstP v2) => if v1=v2 then [] else raise NoAnswer
	      | (Tuple v, TupleP p) => List.foldl (fn (item, acc) => acc @ aux item) [] (ListPair.zip (v, p))
	      | (Constructor(s1, v), ConstructorP(s2, p)) => if s1=s2 then aux(v, p) else raise NoAnswer
	      | _ => raise NoAnswer
    in
	SOME(aux vp) handle NoAnswer => NONE
    end

fun first_match v lp =
    SOME(first_answer (fn p => match(v, p)) lp) handle NoAnswer => NONE
