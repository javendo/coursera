{-#LANGUAGE InstanceSigs #-}
module Parsing where

import Data.Char
import Control.Monad

newtype Parser a = P (String -> [(a, String)])

instance MonadPlus Parser where
         mzero = P (\ inp -> [])
         p `mplus` q =  P (\inp -> case parse p inp of
                              [] -> parse q inp
                              [(v,out)] -> [(v,out)])

failure :: Parser a
failure = mzero

item :: Parser Char
item = P (\ inp -> case inp of
             [] -> []
             (x:xs) -> [(x,xs)])

parse :: Parser a -> String -> [(a, String)]
parse (P p) inp =  p inp

sat :: (Char -> Bool) -> Parser Char
sat p = do
        x <- item
        if p x then return x else failure

(+++) :: Parser a -> Parser a -> Parser a
p +++ q = p `mplus` q

digit :: Parser Char
digit = sat isDigit

lower :: Parser Char
lower = sat isLower

char :: Char -> Parser Char
char x = sat (== x)

string :: String -> Parser String
string [] = return []
string (x:xs) =  do
                 char x
                 string xs
                 return (x:xs)

alphanum :: Parser Char
alphanum = sat isAlphaNum

many :: Parser a -> Parser [a]
many p = many1 p +++ return []

many1 :: Parser a -> Parser [a]
many1 p = do v  <- p
             vs <- many p
             return (v:vs)

ident :: Parser String
ident = do x  <- lower
           xs <- many alphanum
           return (x:xs)

nat :: Parser Int
nat = do xs <- many1 digit
         return (read xs)

int :: Parser Int
int = do char '-'
         n <- nat
         return (-n)
      +++ nat

space :: Parser ()
space = do many (sat isSpace)
           return ()

token :: Parser a -> Parser a
token p =  do space
              v <- p
              space
              return v

identifier :: Parser String
identifier = token ident

natural :: Parser Int
natural = token nat

integer :: Parser Int
integer = token int

symbol :: String -> Parser String
symbol xs =  token (string xs)

instance Monad Parser where
    return :: a -> Parser a
    return v = P (\ inp -> [(v, inp)])
    (>>=) :: Parser a -> (a -> Parser b) -> Parser b
    p >>= f = P (\ inp ->
                  case parse p inp of
                    [] -> []
                    [(v, out)] -> parse (f v) out)

expr :: Parser Int
expr = do n <- natural
          ns <- many
                (do symbol "-"
                    natural)
          return (foldl (-) n ns)


putStr' :: String -> IO ()
putStr' [] = return ()
putStr' (x : xs) = putChar x >> putStr' xs

putStrLn' :: String -> IO ()
putStrLn' [] = putChar '\n'
putStrLn' xs = putStr' xs >> putStrLn' ""

getLine' :: IO String
getLine' = get []

get :: String -> IO String
get xs = do x <- getChar
            case x of
                 '\n' -> return xs
                 _ -> get (xs ++ [x])

interact' :: (String -> String) -> IO ()
interact' f = do input <- getLine'
                 putStrLn' (f input)

sequence_' :: Monad m => [m a] -> m ()
sequence_' [] = return ()
sequence_' (m : ms) = (foldl (>>) m ms) >> return ()

sequence1_' :: Monad m => [m a] -> m ()
sequence1_' ms = foldr (>>) (return ()) ms

sequence2_' :: Monad m => [m a] -> m ()
sequence2_' [] = return ()
sequence2_' (m : ms) = m >> sequence2_' ms

sequence3_' :: Monad m => [m a] -> m ()
sequence3_' [] = return ()
sequence3_' (m : ms) = m >>= \ _ -> sequence2_' ms

sequence1' :: Monad m => [m a] -> m [a]
sequence1' (m : ms) = m >>= \ a -> do as <- sequence1' ms
                                      return (a : as)

sequence5' :: Monad m => [m a] -> m [a]
sequence5' ms = foldr func (return []) ms
   where func :: (Monad m) => m a -> m [a] -> m [a]
         func m acc = do x <- m
                         xs <- acc
                         return (x : xs)

sequence7' :: Monad m => [m a] -> m [a]
sequence7' [] = return []
sequence7' (m : ms) = do a <- m
                         as <- sequence1' ms
                         return (a : as)

mapM1' :: Monad m => (a -> m b) -> [a] -> m [b]
mapM1' f as = sequence5' (map f as)

mapM2' :: Monad m => (a -> m b) -> [a] -> m [b]
mapM2' f [] = return []
mapM2' f (a : as) = f a >>= \ b -> mapM2' f as >>= \ bs -> return (b : bs)

mapM6' :: Monad m => (a -> m b) -> [a] -> m [b]
mapM6' f [] = return []
mapM6' f (a : as) = do b <- f a
                       bs <- mapM6' f as
                       return (b : bs)

mapM7' :: Monad m => (a -> m b) -> [a] -> m [b]
mapM7' f [] = return []
mapM7' f (a : as) = f a >>= \ b -> do bs <- mapM7' f as
                                      return (b : bs)


filterM2' :: Monad m => (a -> m Bool) -> [a] -> m [a]
filterM2' _ [] = return []
filterM2' p (x : xs) = do flag <- p x
                          ys <- filterM2' p xs
                          if flag then return (x : ys) else return ys


