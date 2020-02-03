(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string (s1 : string, s2 : string) =
    s1 = s2

fun all_except_option (s : string, l : string list) =
    let
	exception NotFoundCondition
	fun aux (s : string, l : string list) =
	    case l of
		[] => raise NotFoundCondition
	      | head :: tail => if same_string(s, head) then tail else head :: aux(s, tail)
    in
	SOME(aux(s, l)) handle NotFoundCondition => NONE
    end

fun get_substitutions1 (l : string list list, s : string) =
    case l of
	[] => []
      | head :: tail => getOpt(all_except_option(s, head), []) @ get_substitutions1(tail, s)

fun get_substitutions2 (l : string list list, s : string) =
    let
	fun aux (l : string list list, s : string, acc : string list) =
	    case l of
		[] => acc
	      | head :: tail => aux(tail, s, acc @ getOpt(all_except_option(s, head), []))
    in
	aux(l, s, [])
    end

fun similar_names (l : string list list, fullname : {first : string, middle : string, last : string}) =
    let
	fun aux (acc, synonym, middle, last) =
	    case synonym of
		[] => acc
	      | head::tail => aux(acc @ [{first=head, middle=middle, last=last}], tail, middle, last)
    in
	case fullname of
	    {first=first, middle=middle, last=last} => aux([{first=first, middle=middle, last=last}], get_substitutions2(l, first), middle, last)
    end

(* you may assume that Num is always used with values 2, 3, ..., 9
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

(* put your solutions for problem 2 here *)

fun card_color (c : card) =
    case c of
	(Diamonds, _) => Red
      | (Hearts, _) => Red
      | _ => Black

fun card_value (c : card) =
    case c of
	(_, Ace) => 11
      | (_, Jack) => 10
      | (_, Queen) => 10
      | (_, King) => 10
      | (_, Num n) => n

fun remove_card (cs : card list, c : card, e : exn) =
    let
	fun aux (acc : card list, cs : card list) =
	    case cs of
		[] => raise e
	      | head::tail => if head=c then acc @ tail else aux(acc @ [head], tail)
    in
	aux([], cs)
    end

fun all_same_color (cs : card list) =
    case cs of
	[] => true
      | _::[] => true
      | c1::c2::tail => if card_color(c1)=card_color(c2) then all_same_color(c2::tail) else false


fun sum_cards (cs : card list) =
    let
	fun aux (acc : int, cs : card list) =
	    case cs of
		[] => acc
	      | head::tail => aux(acc + card_value(head), tail)
    in
	aux(0, cs)
    end

fun score (hs : card list, goal : int) =
    let
	val sum = sum_cards(hs)
	val same_color = all_same_color(hs)
	val preliminary = if sum > goal then 3 * (sum - goal) else goal - sum
    in
	if all_same_color(hs)
	then preliminary div 2
	else preliminary
    end

fun officiate (cs : card list, ms : move list, goal : int) =
    let
	fun aux (hs : card list, cs : card list, ms : move list) =
	    case (hs, cs, ms) of
		(_, [], _) => hs
	      | (_, _, []) => hs
	      | (h, c::ct, m::mt) => if sum_cards(h) > goal then hs else (case m of
						 			      Draw => aux(c::h, ct, mt)
						 			    | Discard card => aux(remove_card(h, card, IllegalMove), c::ct, mt))
    in
	score(aux([], cs, ms), goal)
    end

(*
fun score_challenge (hs : card list, goal : int) =
    let
	fun best_score (sum : int, goal : int) =
	    if (sum - 10) > goal
	    then best_score(sum - 10, goal)
	    else if sum > goal andalso 3 * (sum - goal) > goal - (sum - 10) then sum - 10 else sum
	val sum = best_score(sum_cards(hs), goal)
	val same_color = all_same_color(hs)
	val preliminary = if sum > goal then 3 * (sum - goal) else goal - sum
    in
	if all_same_color(hs)
	then preliminary div 2
	else preliminary
    end
*)
fun officiate_challenge (cs : card list, ms : move list, goal : int) =
    let
	fun aux (hs : card list, cs : card list, ms : move list) =
	    case (hs, cs, ms) of
		(h, [], _) => h::[]
	      | (h, _, []) => h::[]
	      | (h, c::ct, m::mt) => if sum_cards(h) > goal then h::[] else (case m of
						 			      Draw => aux(c::h, ct, mt)
						 			    | Discard card => aux(remove_card(h, card, IllegalMove), c::ct, mt))
    in
	aux([], cs, ms)
    end

