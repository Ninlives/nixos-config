{-# LANGUAGE OverloadedStrings #-}

module Main where

import Text.Pandoc.JSON

allowFrameBreaks :: Block -> Block
allowFrameBreaks header@(Header 2 (name, classes, attributes) inlines) = 
                 if "allowframebreaks" `elem` classes then header
                 else Header 2 (name, "allowframebreaks":classes, attributes) inlines
allowFrameBreaks x = x

main :: IO ()
main = toJSONFilter allowFrameBreaks
