fun o_test1 () = (* correct behavior: raise IllegalMove *)
    let val cards = [(Clubs,Jack),(Spades,Num(8))]
	val moves = [Draw,Discard(Hearts,Jack)]
    in
	officiate(cards,moves,42)
    end


fun o_test2 () = (* correct behavior: return 3 *)
    let val cards = [(Clubs,Ace),(Spades,Ace),(Clubs,Ace),(Spades,Ace)]
	val moves = [Draw,Draw,Draw,Draw,Draw]
    in
 	officiate(cards,moves,42)
    end

(*
fun oc_test1 () =
    let val cards = [(Spades, Ace), (Diamonds, Num(10)), (Clubs, Queen), (Hearts, Num(9)), (Spades, Num(5)), (Diamonds, Num(3))]
        val moves = [Draw, Draw, Draw, Draw, Draw, Draw]
    in
        officiate_challenge(cards, moves, 42)
    end

fun oc_test2 () =
    let val cards = [(Spades, Ace), (Diamonds, Num(10)), (Clubs, Queen), (Hearts, Num(9)), (Spades, Num(5)), (Diamonds, Num(3)), (Hearts, Ace), (Hearts, Jack), (Diamonds, Ace), (Clubs, Num(8))]
        val moves = [Draw, Draw, Draw, Draw, Draw, Draw, Discard(Spades, Ace), Draw, Draw, Draw]
    in
        officiate_challenge(cards, moves, 42)
    end

fun oc_test3 () =
    let val cards = [(Spades, Ace), (Diamonds, Num(10)), (Clubs, Queen), (Hearts, Num(9)), (Spades, Num(5)), (Diamonds, Num(3)), (Hearts, Ace), (Hearts, Jack), (Diamonds, Ace), (Clubs, Num(8))]
        val moves = [Draw, Draw, Draw, Draw, Draw, Draw, Discard(Diamonds, Num(10)), Discard(Clubs, Queen), Draw, Draw, Draw]
    in
        officiate_challenge(cards, moves, 42)
    end

fun oc_test4 () =
    let val cards = [(Spades, Ace), (Diamonds, Num(10)), (Clubs, Queen), (Hearts, Num(9)), (Spades, Num(5)), (Diamonds, Num(3)), (Hearts, Ace), (Hearts, Jack), (Diamonds, Ace), (Clubs, Num(8))]
        val moves = [Draw, Draw, Draw, Draw, Draw, Draw, Discard(Spades, Ace), Discard(Spades, Num(5)), Draw, Draw, Draw, Draw]
    in
        officiate_challenge(cards, moves, 42)
    end

val officiate_challenge_test1 = oc_test1() = 4;
val officiate_challenge_test2 = oc_test2() = 18;
val officiate_challenge_test3 = oc_test3() = 2;
val officiate_challenge_test4 = oc_test4() = 3;
*)

val all_except_option_test1 = getOpt(all_except_option("F", ["Freddie","Fred","F"]), []) <> [];
val all_except_option_test2 = hd(getOpt(all_except_option("F", ["Freddie","Fred","F"]), [])) = "Freddie";
val all_except_option_test3 = hd(tl(getOpt(all_except_option("F", ["Freddie","Fred","F"]), []))) = "Fred";

val get_substitutions1_test1 = hd(get_substitutions1([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff")) = "Jeffrey";
val get_substitutions1_test2 = hd(tl(get_substitutions1([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff"))) = "Geoff";
val get_substitutions1_test3 = hd(tl(tl(get_substitutions1([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff")))) = "Jeffrey";

val get_substitutions2_test1 = hd(get_substitutions2([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff")) = "Jeffrey";
val get_substitutions2_test2 = hd(tl(get_substitutions2([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff"))) = "Geoff";
val get_substitutions2_test3 = hd(tl(tl(get_substitutions2([["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]],"Jeff")))) = "Jeffrey";

val officiate_test1 = (o_test1() handle IllegalMove => 0) = 0;
val officiate_test2 = o_test2() = 3;
