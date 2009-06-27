{-# LANGUAGE NamedFieldPuns #-}

module Network.Loli.Engine where

import Control.Monad.Reader hiding (join)
import Control.Monad.State hiding (join)
import Data.Default
import Hack
import Hack.Contrib.Middleware.NotFound
import Hack.Contrib.Utils hiding (get, put)
import MPS
import Network.Loli.Config
import Network.Loli.Middleware.LoliRouter
import Network.Loli.Middleware.UserMime
import Network.Loli.Type
import Network.Loli.Utils
import Prelude hiding ((.), (/), (>), (^))

run_app :: AppUnit -> Application
run_app unit = \env -> runReaderT unit env .flip execStateT def

loli :: Unit -> Application
loli unit = run unit (not_found empty_app)
  where
    run :: Unit -> Middleware
    run unit' = 
      let loli_state  = execState unit' def
          paths       = loli_state.routes
          
          loli_app    = loli_router loli_captures run_app paths 
          mime_filter = user_mime (loli_state.mimes)
          stack       = loli_state.middlewares.use
          pre         = pre_installed_middlewares.use
      in
      use [pre, mime_filter, stack, loli_app]

add_route :: RoutePath -> Loli -> Loli
add_route r s = let xs = s.routes in s {routes = xs.insert_last r}

route :: RequestMethod -> String -> AppUnit -> Unit
route r s u = update $ add_route (r, s, u)

add_middleware :: Middleware -> Loli -> Loli
add_middleware x s = 
  let xs = s.middlewares in s {middlewares = xs.insert_last x}

add_mime :: String -> String -> Loli -> Loli
add_mime k v s = let xs = s.mimes in s {mimes = xs.insert_last (k, v)}


