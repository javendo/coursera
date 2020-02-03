import Data.Char

evens :: [Integer] -> [Integer]
evens [] = []
evens (x: xs)
   | even x = x : evens xs
   | otherwise = evens xs

squares :: Integer -> [Integer]
squares 0 = []
squares n = n ^ 2 : squares (n - 1)

sumSquares :: Integer -> Integer
sumSquares n = sum (squares n)

squares' :: Integer -> Integer -> [Integer]
squares' m n = take (fromIntegral m) (squares (m + n))

sumSquares' :: Integer -> Integer
sumSquares' x = sum . uncurry squares' $ (x, x)

coords :: Integer -> Integer -> [(Integer, Integer)]
coords m n = [(x, y) | x <- [0..m], y <- [0..n]] 
