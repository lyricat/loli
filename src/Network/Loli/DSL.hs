module Network.Loli.DSL where

import Control.Monad.Reader
import Control.Monad.State
import Hack
import Hack.Contrib.Middleware.Censor
import Hack.Contrib.Middleware.Config
import Hack.Contrib.Middleware.Static
import MPS
import Network.Loli.Config
import Network.Loli.Engine
import Network.Loli.Middleware.IOConfig
import Network.Loli.Type
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^))
import qualified Control.Monad.State as State


app :: Application -> AppUnit
app f = ask >>= (f > io) >>= State.put


layout :: String -> Unit
layout x = middleware $ config (set_namespace loli_config loli_layout x)

views :: String -> Unit
views x = middleware $ config (set_namespace loli_config loli_views x)

router :: Router -> Unit
router x = update $ set_router x

get, put, delete, post :: String -> AppUnit -> Unit
get    = add_route GET
put    = add_route PUT
delete = add_route DELETE
post   = add_route POST

middleware :: Middleware -> Unit
middleware = add_middleware > update

before :: (Env -> IO Env) -> Unit
before = ioconfig > middleware

after :: (Response -> IO Response) -> Unit
after = censor > middleware

mime :: String -> String -> Unit
mime k v = add_mime k v .update

public :: Maybe String -> [String] -> Unit
public r xs = middleware $ static r xs

io :: (MonadIO m) => IO a -> m a
io = liftIO

context :: Assoc -> AppUnit -> AppUnit
context = put_namespace loli_locals > local

bind :: String -> String -> AppUnit -> AppUnit
bind k v = context [(k, v)]

captures, locals :: AppUnitT Assoc
captures = ask ^ namespace loli_captures
locals   = ask ^ namespace loli_locals

