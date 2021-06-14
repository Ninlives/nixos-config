module Neovim.DynSyntax.Implementation where

import Neovim
import Neovim.API.String
import Text.Regex.PCRE
import Control.Monad

dynamicSyntax :: Neovim env ()
dynamicSyntax = do 
    buffer <- vim_get_current_buffer
    lines <- nvim_buf_get_lines buffer 0 (-1) True
    let matches = concatMap ((=~ "^.*<<<([^<>]+)>>>") :: String -> [[String]]) lines
    void $ forM matches $ 
        \match -> case match of
                    [content, syntax] -> void $ vim_call_function "SyntaxRange#Include" (map toObject [ content, ">>>" ++ syntax ++ "<<<", syntax])
                    _ -> return ()
