{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where
import Text.Pandoc.JSON
import Data.String.QQ
import Data.Map.Strict

frameTitleContinuation :: Pandoc -> Pandoc
frameTitleContinuation (Pandoc meta blocks) = Pandoc (frameTitleContinuation' meta) blocks

frameTitleContinuation' :: Meta -> Meta
frameTitleContinuation' meta@Meta {unMeta = metaValues} =
                        case metaValues !? key of
                             Nothing -> Meta {unMeta = mkMap beamerTemplate}
                             Just (MetaInlines inlines) -> Meta {unMeta = mkMap $ mkMeta inlines}
                             Just _  -> meta
                        where key = "header-includes"
                              header = [s|
                                \setbeamertemplate{frametitle continuation}{
                                \ifnum\insertcontinuationcount>1 
                                \insertcontinuationcountroman 
                                \fi}
                                |]
                              templateValue  = RawInline (Format "tex") header
                              beamerTemplate = MetaInlines [templateValue]
                              mkMeta inlines = MetaInlines $ templateValue:inlines
                              mkMap template = insert key template metaValues

main :: IO ()
main = toJSONFilter frameTitleContinuation
