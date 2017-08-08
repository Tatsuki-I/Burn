module Burn where

import Data.List
import System.Random

type Img = [[Pixel]]
type Pixel = (Red, Green, Blue)
type Red = Color
type Green = Color
type Blue = Color
type Color = Int

initImg :: Int -> [Int] -> [[Int]]
initImg c xs = l c $ j xs

f    :: [Int] -> [[Int]]
f xs =  (avg (take 2 xs) : init (unfoldr g xs)) : [xs]

g :: [Int] -> Maybe (Int, [Int])
g [] =  Nothing
g xs =  Just (avg (take 3 xs), tail xs)

h :: ([Int], [Int]) -> [Int]
h t =  avg ((head . snd) t : take 2 (fst t)) : unfoldr i t

i :: ([Int], [Int]) -> Maybe (Int, ([Int], [Int]))
i (_, [_]) =  Nothing
i (l1, _ : l2) =  Just (avg (head l2 : take 3 l1), (tail l1, l2))

j :: [Int] -> [[Int]]
j xs =  h t : f xs
        where t =  ((head . f) xs, (head . tail. f) xs)

k :: [[Int]] -> [Int]
k xs =  h t
        where t =  ((head . f . head) xs, (head . tail. f . head) xs)

l :: Int -> [[Int]] -> [[Int]]
l 0 xs =  xs
l c xs =  l (c - 1) (k xs : xs)

avg :: [Int] -> Int
avg xs =  sum xs `div` length xs

--randomRs (1, 6) (mkStdGen 11)