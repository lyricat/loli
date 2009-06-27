module Network.Loli.Template where

import Control.Monad.Reader
import Data.ByteString.Lazy.UTF8
import Hack
import Hack.Contrib.Constants
import Hack.Contrib.Response
import MPS
import Network.Loli.Config
import Network.Loli.DSL
import Network.Loli.Template.TextTemplate
import Network.Loli.Type
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^), (/))
import qualified Control.Monad.State as State

-- simple
text :: String -> AppUnit
text x = do
  update $ set_content_type _TextPlain
  update $ set_body (x.fromString)
  render_layout

html :: String -> AppUnit
html x = do
  update $ set_content_type _TextHtml
  update $ set_body (x.fromString)
  render_layout


-- template
partial_locals ::  AppUnitT Context
partial_locals = ask ^ namespace loli_partials

template_locals :: AppUnitT Context
template_locals = do
  c <- captures
  b <- locals
  p <- partial_locals
  return (c ++ b ++ p)

render :: (Template a) => AppUnitT a -> AppUnitT String
render x = do
  template <- x
  context' <- template_locals
  interpolate template context' .io
  
output :: (Template a) => AppUnitT a -> AppUnit
output x = render x >>= fromString > set_body > update

render_layout :: AppUnit
render_layout = do
    use_layout <- ask ^ namespace loli_config ^ lookup loli_layout
    case use_layout of
      Nothing -> return ()
      Just layout_template -> do
        s <- State.get ^ body ^ toString
        local (set_namespace loli_partials loli_layout_content s) $ do
          render (text_template layout_template) 
            >>= fromString > set_body > update



partial :: (Template a) => String -> AppUnitT a -> AppUnit -> AppUnit
partial s x = partials [(s, x)]

partials :: (Template a) => [(String, AppUnitT a)] -> AppUnit -> AppUnit
partials xs unit = do
   let ps = xs.only_snd
   rs <- ps.mapM render
   let ns = zip (xs.only_fst) rs
   
   local (put_namespace loli_partials ns) unit


with_layout :: String -> AppUnit -> AppUnit
with_layout x = 
  local (set_namespace loli_config loli_layout x)

no_layout :: AppUnit -> AppUnit
no_layout =
  local (delete_namespace loli_config loli_layout)