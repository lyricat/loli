module Network.Loli.Template.TextTemplate (text_template) where

import Control.Arrow ((***))
import Control.Monad.Reader
import Data.ByteString.Lazy.UTF8
import Data.Maybe
import MPS
import Network.Loli.Config
import Network.Loli.Type
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^), (/))
import Text.Template hiding (Context, Template, template)
import qualified Data.ByteString.Lazy.Char8 as B
import qualified Data.Map as Map
import qualified Text.Template as T

create_context :: [(String, String)] -> Map.Map B.ByteString B.ByteString
create_context = map (fromString *** fromString) > to_h

render_text_template :: String -> Context -> IO String
render_text_template x c = 
  readTemplate (x.u2b) ^ flip T.render (create_context c) ^ toString

data TextTemplate = TextTemplate String


instance Template TextTemplate where
  interpolate (TextTemplate x) c = render_text_template x c

text_template :: String -> AppUnitT TextTemplate
text_template x = do
  root <- ask ^ namespace loli_config ^ lookup loli_views ^ fromMaybe "."
  return $ TextTemplate (root / x)