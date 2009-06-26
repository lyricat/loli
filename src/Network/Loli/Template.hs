module Network.Loli.Template where

import Control.Monad.Reader
import Data.Maybe
import Hack.Contrib.Response
import MPS
import Network.Loli.Config
import Network.Loli.DSL
import Network.Loli.Engine
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^), (/))
import qualified Data.ByteString.Lazy.Char8 as B


type Context = [(String, String)]
type Template = String -> Context -> IO B.ByteString

template :: Template -> String -> AppUnit
template f x = do
  c <- captures
  b <- bindings
  root <- ask ^ namespace loli_views ^ lookup "root" ^ fromMaybe "."
  f (root / x) (c ++ b) .io >>= set_body > update
