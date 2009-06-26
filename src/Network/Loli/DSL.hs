module Network.Loli.DSL where

import Control.Monad.Reader
import Control.Monad.State
import Data.ByteString.Lazy.UTF8 (fromString)
import Hack
import Hack.Contrib.Constants
import Hack.Contrib.Middleware.Config
import Hack.Contrib.Middleware.Static
import Hack.Contrib.Response
import MPS
import Network.Loli.Config
import Network.Loli.Engine
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^))
import qualified Control.Monad.State as State


app :: Application -> AppUnit
app f = ask >>= (f > io) >>= State.put

text :: String -> AppUnit
text x = do
  update $ set_content_type _TextPlain
  update $ set_body (x.fromString)

html :: String -> AppUnit
html x = do
  update $ set_content_type _TextHtml
  update $ set_body (x.fromString)

views :: String -> Unit
views x = middleware $ config (set_namespace loli_views [("root", x)])

get, put, delete, post :: String -> AppUnit -> Unit
get    = route GET
put    = route PUT
delete = route DELETE
post   = route POST

middleware :: Middleware -> Unit
middleware x = add_middleware x .update

mime :: String -> String -> Unit
mime k v = add_mime k v .update

public :: Maybe String -> [String] -> Unit
public r xs = middleware $ static r xs

io :: (MonadIO m) => IO a -> m a
io = liftIO

context :: [(String, String)] -> AppUnit -> AppUnit
context = set_namespace loli_bindings > local

bind :: String -> String -> AppUnit -> AppUnit
bind k v = context [(k, v)]

captures, bindings :: AppUnitT [(String, String)]
captures = ask ^ namespace loli_captures
bindings = ask ^ namespace loli_bindings
