{-# LANGUAGE OverloadedStrings #-}

module IambicLine where

-- | A test for the pronouncing API

import Text.Pronounce
import Text.Pronounce.ParseDict
import Control.Monad.Reader
import System.Console.Haskeline
import qualified Data.Text as T

-- | Test if a stress pattern is (loosely) in iambic meter
isIambic :: Stress -> Bool
isIambic [] = True
isIambic [_] = True
isIambic (x:y:xs) = (x,y) `elem` [(2,2),(1,1),(2,1),(0,1),(0,2)]  && isIambic xs

-- | Test if a line of text is iambic
isIambicLine :: T.Text -> DictComp Bool
isIambicLine = pure . isIambic . concat <=< mapM stressesForEntry . T.words

-- | A simple repl using haskeline that tells us whether or not what we type is
-- iambic
main :: IO ()
main = do
    putStrLn "Type something, and I'll tell you if it's in iambic meter..."
    dict <- stdDict
    runInputT defaultSettings (loop dict)
        where
            loop :: CMUdict -> InputT IO ()
            loop cmu = do
                line <- getInputLine "# "
                case line of
                    Nothing -> return ()
                    Just "" -> loop cmu
                    Just input -> do
                        outputStrLn . show . or . runPronounce (isIambicLine . T.toUpper . T.pack $ input) $ cmu
                        loop cmu
