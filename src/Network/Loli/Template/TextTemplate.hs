module Network.Loli.Template.TextTemplate where

import Control.Arrow ((***))
import Data.ByteString.Lazy.UTF8
import MPS
import Network.Loli.Type
import Prelude hiding ((.), (>), (^), (-), (/))
import Text.Template hiding (Context, Template, template)
import qualified Text.Template as T

render_text_template :: String -> Context -> IO String
render_text_template x c = 
  readTemplate (x.u2b) ^ flip T.render (create_context c) ^ toString
  where
    create_context = map (fromString *** fromString) > to_h

data TextTemplate = TextTemplate String

instance Template TextTemplate where
  interpolate (TextTemplate x) r = render_text_template (r / x)

text_template :: String -> TextTemplate
text_template = TextTemplate