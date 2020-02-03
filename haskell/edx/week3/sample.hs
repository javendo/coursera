halve1 xs = splitAt (length xs `div` 2) xs

halve2 xs = (take (n `div` 2) xs, drop (n `div` 2) xs)
    where n = length xs

halve3 xs = splitAt (div (length xs) 2) xs

halve4 xs = (take n xs, drop n xs)
    where n = length xs `div` 2

x1 = halve4 [1, 2, 3, 4, 5, 6]

safetail [x] = [x]
safetail (_ : xs) = xs

x = null (safetail [])

main = do putStrLn (show x)

