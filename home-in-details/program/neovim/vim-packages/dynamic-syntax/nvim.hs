import Neovim

import qualified Neovim.DynSyntax as P

main :: IO ()
main = do
    neovim defaultConfig
        { plugins = plugins defaultConfig ++ [ P.plugin ]
        }
