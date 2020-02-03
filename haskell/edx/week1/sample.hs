n = a `div` length xs
    where a = 10
          xs = [1, 2, 3, 4, 5]

last1 xs = drop (length xs - 1) xs
last2 xs = head (drop (length xs - 1) xs)
last3 xs = tail (reverse xs)
last4 xs = reverse (head xs)
last5 xs = xs !! (length xs - 1)
last6 xs = head (drop (length xs) xs)
last7 xs = head (reverse xs)
last8 xs = reverse xs !! (length xs - 1)

init1 xs = tail (reverse xs)
init2 xs = reverse (head (reverse xs))
init3 xs = reverse (tail xs)
init4 xs = take (length xs) xs
init5 xs = reverse (tail (reverse xs))
init6 xs = take (length xs - 1) (tail xs)
init7 xs = drop (length xs - 1) xs

qsort [] = [] 
qsort (x : xs) = qsort ys ++ [x] ++ qsort zs
    where 
      ys = [a | a <- xs, a <= x]
      zs = [b | b <- xs, b > x]

qsort1 [] = []
qsort1 (x : xs) = qsort1 larger ++ [x] ++ qsort1 smaller
                  where smaller = [a | a <- xs, a <= x]
                        larger = [b | b <- xs, b > x]

qsort2 [] = []
qsort2 (x : xs) = reverse (qsort2 smaller ++ [x] ++ qsort2 larger)
                  where smaller = [a | a <- xs, a <= x]
                        larger = [b | b <- xs, b > x]

qsort3 [] = []
qsort3 xs = qsort3 larger ++ qsort3 smaller ++ [x]
                  where x = minimum xs
                        smaller = [a | a <- xs, a <= x]
                        larger = [b | b <- xs, b > x]

qsort4 [] = []
qsort4 (x : xs) = reverse (qsort4 larger) ++ [x] ++ reverse(qsort4 smaller)
                  where smaller = [a | a <- xs, a <= x]
                        larger = [b | b <- xs, b > x]

qsort5 [] = []
qsort5 (x : xs) = qsort5 larger ++ [x] ++ qsort5 smaller
                  where larger = [a | a <- xs, a > x || a == x]
                        smaller = [b | b <- xs, b < x]

qsort6 [] = []
qsort6 (x : xs) = qsort6 larger ++ [x] ++ qsort6 smaller
                  where smaller = [a | a <- xs, a < x]
                        larger = [b | b <- xs, b > x]

qsort7 [] = []
qsort7 (x : xs) = reverse (reverse (qsort7 smaller) ++ [x] ++ reverse(qsort7 larger))
                  where smaller = [a | a <- xs, a <= x]
                        larger = [b | b <- xs, b > x]

qsort8 [] = []
qsort8 xs = x : qsort8 larger ++ qsort8 smaller
                  where x = maximum xs
                        smaller = [a | a <- xs, a < x]
                        larger = [b | b <- xs, b >= x]
