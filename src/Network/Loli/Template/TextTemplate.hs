module Network.Loli.Template.TextTemplate where

import Control.Arrow ((***))
import Data.ByteString.Lazy.UTF8 (fromString)
import MPS
import Network.Loli.Engine
import Network.Loli.Template
import Prelude hiding ((.), (>), (^), (/))
import Text.Template hiding (Context, Template, template)
import qualified Data.ByteString.Lazy.Char8 as B
import qualified Data.Map as Map


create_context :: [(String, String)] -> Map.Map B.ByteString B.ByteString
create_context = map (fromString *** fromString) > to_h

backend :: Template
backend x c = readTemplate (x.u2b) ^ flip render (create_context c)

text_template :: String -> AppUnit
text_template = template backend