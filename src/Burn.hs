module Burn where

import Data.List
import System.Random

type Img = [[Pixel]]
type Pixel = (Red, Green, Blue)
type Red = Color
type Green = Color
type Blue = Color
type Color = Int

burn :: Int -> Int -> FilePath -> Int -> IO ()
burn x y path c =  do rndNum <- rnd
                      burn' y (take x $ randomRs (0, 255) (mkStdGen rndNum)) path c

burn' :: Int -> [Int] -> FilePath -> Int -> IO ()
burn' _ _ _ 0 = return ()
burn' y l path c =  do img <- initImg' y l
                       exportImg (path ++ (replicate (4 - ((length . show) c)) '0') ++ (show c)) img
                       rndNum <- rnd
                       burn' y
                             (zipWith (+)
                                      (last img)
                                      $ take (length $ last img) $ randomRs (-5, 5) (mkStdGen rndNum))
                             path
                             (c - 1)


initRndImg :: Int -> Int -> Int -> [[Int]]
initRndImg x y rnd =  initImg y $ take x $ randomRs (0, 255) (mkStdGen rnd)

initRndImg' :: Int -> Int -> Int -> IO [[Int]]
initRndImg' x y rnd =  initImg' y $ take x $ randomRs (0, 255) (mkStdGen rnd)

initImg :: Int -> [Int] -> [[Int]]
initImg =  l

initImg' :: Int -> [Int] -> IO [[Int]]
initImg' =  m

toPGM :: [[Int]] -> String
toPGM xs =  unlines $ [ "P2"
                      , (show . length . head) xs
                        ++ " "
                        ++ (show . length) xs
                      , "255" ]
                      ++ map (unwords . map show) xs

exportImg :: FilePath -> [[Int]] -> IO ()
exportImg path xs =  writeFile (path ++ ".pgm") $ toPGM xs

exportImg' :: FilePath -> IO [[Int]] -> IO ()
exportImg' path xs =  do nxs <- xs
                         writeFile (path ++ ".pgm") $ toPGM nxs

f    :: [Int] -> [[Int]]
f xs =  (avg (last xs : take 2 xs)
        : (init . init) (unfoldr g xs)
        ++ [avg (head xs : take 2 (reverse xs))])
        : [xs]

g :: [Int] -> Maybe (Int, [Int])
g [] =  Nothing
g xs =  Just (avg (take 3 xs), tail xs)

h :: ([Int], [Int]) -> [Int]
h t =  avg ((head . snd) t : (last . fst) t : take 2 (fst t))
       : init (unfoldr i t)
       ++ [avg ((last . snd) t : (head . fst) t : take 2 (reverse $ fst t))]

i :: ([Int], [Int]) -> Maybe (Int, ([Int], [Int]))
i (_, [_]) =  Nothing
i (l1, _ : l2) =  Just (avg (head l2 : take 3 l1), (tail l1, l2))

j :: [Int] -> [[Int]]
j xs =  h t : f xs
        where t =  ((head . f) xs, (head . tail. f) xs)

k :: [[Int]] -> [Int]
k xs =  h t
        where t =  ((head) xs, (head . tail) xs)

k' :: [[Int]] -> IO [Int]
k' xs =  do l1 <- (mkRndNoise . head) xs
            l2 <- (mkRndNoise . head . tail) xs
            return $ h (l1, l2)

l :: Int -> [Int] -> [[Int]]
l c xs =  l' (c - 3) $ j xs

m :: Int -> [Int] -> IO [[Int]]
m c xs =  l'' (c - 3) $ j xs

l' :: Int -> [[Int]] -> [[Int]]
l' 0 xs =  xs
l' c xs =  l' (c - 1) (k xs : xs)

l'' :: Int -> [[Int]] -> IO [[Int]]
l'' 0 xs =  return xs
l'' c xs =  do nxs <- k' xs
               l'' (c - 1) (nxs : xs)

mkNoise :: Int -> [Int] -> [Int]
mkNoise rnd xs =  zipWith (+) xs $ take (length xs) $ randomRs (-15, 15) (mkStdGen rnd)

mkRndNoise :: [Int] -> IO [Int]
mkRndNoise xs =  do rndNum <- rnd
                    return $ mkNoise rndNum xs

rnd :: IO Int
rnd =  do rndNum <- getStdRandom random
          return $ abs rndNum

avg :: [Int] -> Int
avg xs =  round $ (fromIntegral (sum xs) :: Double) / (fromIntegral (length xs) :: Double)
--avg xs =  $ sum xs `div` length xs

