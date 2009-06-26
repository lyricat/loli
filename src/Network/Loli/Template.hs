module Network.Loli.Template where

import Control.Monad.Reader
import Data.ByteString.Lazy.UTF8 (fromString)
import Hack.Contrib.Response
import MPS
import Network.Loli.Config
import Network.Loli.Engine
import Network.Loli.DSL
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^), (/))
import qualified Control.Monad.State as State
import qualified Data.ByteString.Lazy.Char8 as B
import Text.Template hiding (Context, Template, template)
import Control.Arrow ((***))
import qualified Data.Map as Map
import Data.Maybe

type Context = [(String, String)]
type Template = String -> Context -> IO B.ByteString

create_context :: [(String, String)] -> Map.Map B.ByteString B.ByteString
create_context = map (fromString *** fromString) > to_h

template :: Template -> String -> AppUnit
template f x = do
  c <- captures
  b <- bindings
  root <- ask ^ namespace loli_views ^ lookup "root" ^ fromMaybe "."
  f (root / x) (c ++ b) .io >>= set_body > update
  
text_tempalte :: Template
text_tempalte x c = readTemplate (x.u2b) ^ flip render (create_context c)

ehs :: String -> AppUnit
ehs x = template text_tempalte x