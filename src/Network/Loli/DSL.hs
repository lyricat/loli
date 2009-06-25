module Network.Loli.DSL where


import Data.ByteString.Lazy.UTF8 (fromString)
import Hack
import Hack.Contrib.Constants
import Hack.Contrib.Middleware.Static
import Hack.Contrib.Response
import MPS
import Network.Loli.Engine
import Prelude hiding ((.), (>), (^))
import Control.Monad.State


app :: Application -> AppUnit
app = set_application > update

text :: String -> AppUnit
text x = do
  response $ set_content_type _TextPlain
  response $ set_body (x.fromString)

html :: String -> AppUnit
html x = do
  response $ set_content_type _TextHtml
  response $ set_body (x.fromString)

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