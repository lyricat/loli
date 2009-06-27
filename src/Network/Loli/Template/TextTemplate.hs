module Network.Loli.Template.TextTemplate where

import Control.Arrow ((***))
import Data.ByteString.Lazy.UTF8
import MPS
import Network.Loli.Type
import Prelude hiding ((.), (>), (^), (/))
import Text.Template hiding (Context, Template, template)
import qualified Text.Template as T

render_TextTemplate :: String -> Context -> IO String
render_TextTemplate x c = 
  readTemplate (x.u2b) ^ flip T.render (create_context c) ^ toString
  where
    create_context = map (fromString *** fromString) > to_h

data TextTemplate = TextTemplate String

instance Template TextTemplate where
  interpolate (TextTemplate x) r = render_TextTemplate (r ++ x)

text_template :: String -> TextTemplate
text_template = TextTemplate