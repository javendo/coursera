sum1 :: Int -> Int -> Int
sum1 a b = a + b + 1

main :: IO()
main = putStrLn $ show $ sum1 1 2

