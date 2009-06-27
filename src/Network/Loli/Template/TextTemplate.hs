module Network.Loli.Template.TextTemplate where

import Control.Arrow ((***))
import Data.ByteString.Lazy.UTF8
import MPS
import Network.Loli.Type
import Prelude hiding ((.), (>), (^), (/))
import Text.Template hiding (Context, Template, template)
import qualified Data.ByteString.Lazy.Char8 as B
import qualified Data.Map as Map
import qualified Text.Template as T

create_context :: [(String, String)] -> Map.Map B.ByteString B.ByteString
create_context = map (fromString *** fromString) > to_h

render_TextTemplate :: String -> Context -> IO String
render_TextTemplate x c = 
  readTemplate (x.u2b) ^ flip T.render (create_context c) ^ toString

data TextTemplate = TextTemplate String

instance Template TextTemplate where
  interpolate (TextTemplate x) r c = render_TextTemplate (r ++ x) c

text_template :: String -> TextTemplate
text_template x = TextTemplate x