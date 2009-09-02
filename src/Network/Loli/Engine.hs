{-# LANGUAGE NamedFieldPuns #-}

module Network.Loli.Engine where

import Control.Monad.Reader hiding (join)
import Control.Monad.State hiding (join)
import Data.Default
import Hack
import Hack.Contrib.Middleware.UserMime
import Hack.Contrib.Middleware.NotFound
import Hack.Contrib.Utils hiding (get, put)
import MPS
import Network.Loli.Config
import Network.Loli.Middleware.LoliRouter ()
import Network.Loli.Type
import Network.Loli.Utils
import Prelude hiding ((.), (/), (>), (^), (-))

run_app :: AppUnit -> Application
run_app unit = \env -> runReaderT unit env .flip execStateT def {status = 200}

loli :: Unit -> Application
loli unit = run unit not_found_app
  where
    not_found_app = not_found dummy_app
    run_route x = (x.router) loli_captures run_app (x.route_path)
    
    run :: Unit -> Middleware
    run unit' = 
      let loli_state    = execState unit' def
          route_configs = loli_state.routes
          route         = route_configs.map run_route .use
          mime_filter   = user_mime (loli_state.mimes)
          stack         = loli_state.middlewares.use
          pre           = pre_installed_middlewares.use
      in
      use [pre, mime_filter, stack, route]

add_route_config :: RouteConfig -> Loli -> Loli
add_route_config r s = let xs = s.routes in s {routes = xs.insert_last r}

add_route :: RequestMethod -> String -> AppUnit -> Unit
add_route r s u = do
  c <- get ^ current_router
  update - add_route_config RouteConfig { route_path = (r, s, u), router = c }

set_router :: Router -> Loli -> Loli
set_router r x = x { current_router = r }

add_middleware :: Middleware -> Loli -> Loli
add_middleware x s = 
  let xs = s.middlewares in s {middlewares = xs.insert_last x}

add_mime :: String -> String -> Loli -> Loli
add_mime k v s = let xs = s.mimes in s {mimes = xs.insert_last (k, v)}


