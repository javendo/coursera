fun is_older (date1 : int * int * int, date2 : int * int * int) =
    #1 date1 < #1 date2 orelse (#1 date1 = #1 date2 andalso #2 date1 < #2 date2) orelse (#1 date1 = #1 date2 andalso #2 date1 = #2 date2 andalso #3 date1 < #3 date2)

fun number_in_month (dates : (int * int * int) list, month : int) =
    if null dates
    then 0
    else
	let val acc = if #2(hd dates) = month then 1 else 0
	in acc + number_in_month(tl dates, month)
	end

fun number_in_months (dates : (int * int * int) list, months : int list) =
    if null months
    then 0
    else number_in_month(dates, hd months) + number_in_months(dates, tl months)

fun dates_in_month (dates : (int * int * int) list, month : int) =
    if null dates
    then []
    else
	if #2(hd dates) = month
	then hd dates :: dates_in_month(tl dates, month)
	else dates_in_month(tl dates, month)

fun dates_in_months (dates : (int * int * int) list, months : int list) =
    if null months
    then []
    else dates_in_month(dates, hd months) @ dates_in_months(dates, tl months)

fun get_nth (strs : string list, nth : int) =
    if nth = 1
    then hd strs
    else get_nth(tl strs, nth - 1) 

fun date_to_string (date : int * int * int) =
    get_nth(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], #2 date) ^ " " ^ Int.toString(#3 date) ^ ", " ^ Int.toString(#1 date)

fun number_before_reaching_sum (sum : int, ints : int list) =
    if null ints
    then 0
    else
	if sum > hd(ints)
	then 1 + number_before_reaching_sum(sum - hd(ints), tl ints)
	else 0

fun what_month (nth_day : int) =
    number_before_reaching_sum(nth_day, [31,28,31,30,31,30,31,31,30,31,30,31]) + 1

fun month_range (day1 : int, day2 : int) =
    if day1 > day2
    then []
    else what_month(day1) :: month_range(day1 + 1, day2)

fun oldest (dates : (int * int * int) list) =
    if null dates
    then NONE
    else
	let
	    fun oldest_with_acc(max : int * int * int, dates : (int * int * int) list) =
		if null dates
		then max
		else
		    let val new_max = if is_older(max, hd dates) then max else hd dates
		    in oldest_with_acc(new_max, tl dates)
		    end
	in SOME(oldest_with_acc(hd dates, tl dates))
	end

fun remove_duplicates (months : int list) =
    let
	fun remove_duplicates_that_match (months : int list, month : int) =
	    if null months
	    then []
	    else
		if hd(months)=month
		then remove_duplicates_that_match(tl months, month)
		else hd(months) :: remove_duplicates_that_match(tl months, month)
    in
	if null months
	then []
	else hd(months) :: remove_duplicates(remove_duplicates_that_match(tl months, hd months))
    end

fun dates_in_months_challenge (dates : (int * int * int) list, months : int list) =
    dates_in_months(dates, remove_duplicates(months))

fun number_in_months_challenge (dates : (int * int * int) list, months : int list) =
    number_in_months(dates, remove_duplicates(months))

fun reasonable_date (date : int * int * int) =
    let
	fun leap_year (year : int) =
	    year mod 4 = 0 andalso (year mod 100 <> 0 orelse year mod 400 = 0)
	fun get_days_of_month (days_in_month : int list, nth : int) =
	    if nth = 1
	    then hd days_in_month
	    else get_days_of_month(tl days_in_month, nth - 1) 
	fun get_days_of_month_with_leap (year : int, month : int) =
	    let val lead_add = if month=2 andalso leap_year(year) then 1 else 0
	    in get_days_of_month([31,28,31,30,31,30,31,31,30,31,30,31], month) + lead_add
	    end
    in
	#1(date) > 0 andalso #2(date) > 0 andalso #2(date) < 13 andalso #3(date) > 0 andalso #3(date) <= get_days_of_month_with_leap(#1(date), #2(date))
    end
