import Parsing

putStr' :: String -> IO ()
putStr' [] = return ()
putStr' (x : xs) = putChar x >> putStr' xs

putStrLn' :: String -> IO ()
putStrLn' [] = putChar "\n"
putStrLn' xs = putStr' xs >> putChar' '\n'
