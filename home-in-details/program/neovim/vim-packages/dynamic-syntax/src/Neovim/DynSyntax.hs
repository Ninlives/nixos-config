{-# LANGUAGE TemplateHaskell #-}
-- Template Haskell is used to remove a lot of manual boiler-plate from
-- declaring the functions you want to export.
module Neovim.DynSyntax
    ( plugin
    ) where

import Neovim
import Neovim.DynSyntax.Implementation

plugin :: Neovim () NeovimPlugin
plugin = do
    wrapPlugin Plugin
        { environment = ()
        , exports =
            [ $(function' 'dynamicSyntax) Async ]
        }
