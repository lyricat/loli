{-# LANGUAGE NamedFieldPuns #-}

module Network.Loli.Engine where

import Control.Monad.State
import Data.Default
import Data.List (find)
import Data.Maybe
import Hack
import Hack.Contrib.Middleware.Censor
import Hack.Contrib.Middleware.Config
import Hack.Contrib.Middleware.NotFound
import Hack.Contrib.Utils hiding (get, put)
import Hack.Contrib.Response
import MPS
import Prelude hiding ((.), (/), (>), (^))

type RoutePath = (RequestMethod, String, AppUnit)

type EnvFilter = Env -> Env
type ResponseFilter = Response -> Response
type Param = (String, String)
data AppState = AppState
  {
    application :: Application
  , env_filters :: [EnvFilter]
  , response_filters :: [ResponseFilter]
  , path :: String
  }

instance Default AppState where
  def = AppState def [id] [id] def

type AppUnit = State AppState ()

run_app :: String -> AppUnit -> Application
run_app path unit = 
  let state = execState unit def {path}
      before = state.env_filters.map config
      after = state.response_filters.map (to_io_filter > censor)
  in
  state.application.use (before ++ after)
  where
    to_io_filter f = \x -> return (f x)

router :: [RoutePath] -> Middleware
router h app' = \env'' ->
  let path             = env''.path_info
      script           = env''.script_name
      mod_env location = env'' 
        { scriptName  = script ++ location
        , pathInfo    = path.drop (location.length)
        }
  in
  case h.find (match_route env'') of
    Nothing -> app' env''
    Just (_, location, app_state) -> 
      run_app location app_state (mod_env location)
  where
    match_route env' (method, path, _) = 
      env'.request_method.is method && env'.path_info.starts_with path


data Loli = Loli
  {
    routes :: [RoutePath]
  , middlewares :: [Middleware]
  , mimes :: [(String, String)]
  }

instance Default Loli where
  def = Loli def def def

type Unit = State Loli ()



loli :: Unit -> Application
loli unit = run unit (not_found empty_app)
  where
    run :: Unit -> Middleware
    run unit = 
      let s           = execState unit def
          paths       = s.routes
          
          loli_app    = router paths
          mime_filter = lookup_mime (s.mimes)
          stack       = s.middlewares.use
      in
      use [mime_filter, stack, loli_app]

set_application :: Application -> AppState -> AppState
set_application application x = x { application }

update :: (MonadState a m, Functor m) => (a -> a) -> m ()
update f = get ^ f >>= put

insert_last :: a -> [a] -> [a]
insert_last x xs = xs ++ [x]

add_route :: RoutePath -> Loli -> Loli
add_route r s = let xs = s.routes in s {routes = xs.insert_last r}

route :: RequestMethod -> String -> AppUnit -> Unit
route r s u = update $ add_route (r, s, u)

add_middleware :: Middleware -> Loli -> Loli
add_middleware x s = 
  let xs = s.middlewares in s {middlewares = xs.insert_last x}

add_mime :: String -> String -> Loli -> Loli
add_mime k v s = let xs = s.mimes in s {mimes = xs.insert_last (k, v)}

add_env_filter :: EnvFilter -> AppState -> AppState
add_env_filter x s = 
  let xs = s.env_filters in s {env_filters = xs.insert_last x}

add_response_filter :: ResponseFilter -> AppState -> AppState
add_response_filter x s = 
  let xs = s.response_filters in s {response_filters = xs.insert_last x}


request :: EnvFilter-> AppUnit
request x = add_env_filter x .update

response :: ResponseFilter -> AppUnit
response x = add_response_filter x .update


-- middleware
lookup_mime :: [(String, String)] -> Middleware
lookup_mime h app env = do
  r <- app env
  case h.only_fst.find mime >>= flip lookup h of
    Nothing -> return r
    Just v -> return $ r.set_content_type v
  where mime x = env.path_info.ends_with ('.' : x)