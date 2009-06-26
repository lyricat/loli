{-# LANGUAGE NamedFieldPuns #-}

module Network.Loli.Engine where

import Control.Monad.Reader hiding (join)
import Control.Monad.State hiding (join)
import Data.Default
import Data.List (find)
import Data.Maybe
import Hack
import Hack.Contrib.Middleware.NotFound
import Hack.Contrib.Response
import Hack.Contrib.Utils hiding (get, put)
import MPS
import Network.Loli.Config
import Network.Loli.Utils
import Prelude hiding ((.), (/), (>), (^))


type RoutePath      = (RequestMethod, String, AppUnit)
type EnvFilter      = Env -> Env
type ResponseFilter = Response -> Response
type Param          = (String, String)
type AppState       = Response
type AppReader      = Env

type AppUnitT a     = ReaderT AppReader (StateT AppState IO) a
type AppUnit        = AppUnitT ()


run_app :: AppUnit -> Application
run_app unit = \env -> runReaderT unit env .flip execStateT def

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
    Just (_, template, app_state) -> do
      let (location, params) = parse_params template path .fromJust
      run_app app_state (mod_env location .merge_captured params)
  where
    match_route env' (method, template, _) = 
      env'.request_method.is method 
        && env'.path_info.parse_params template .isJust
    merge_captured params env' = 
      env'.set_namespace loli_captures params 

parse_params :: String -> String -> Maybe (String, [(String, String)])
parse_params "/" s = Just (s, [])
parse_params t s =
  let template_tokens = t.split "/"
      url_tokens = s.split "/"
  in
  if url_tokens.length < template_tokens.length
    then Nothing
    else 
      let rs = zipWith capture template_tokens url_tokens
      in
      if rs.all isJust
        then 
          let location = url_tokens.take (template_tokens.length).join "/"
          in
          Just $ (location, rs.map fromJust.filter isJust.map fromJust)
        else Nothing
  
  where
    capture x y 
      | x.starts_with ":" = Just $ Just (x.tail, y)
      | x == y = Just Nothing
      | otherwise = Nothing
    
  

data Loli = Loli
  {
    routes :: [RoutePath]
  , middlewares :: [Middleware]
  , mimes :: [(String, String)]
  }

instance Default Loli where
  def = Loli def [dummy_middleware] def

type UnitT a = State Loli a
type Unit    = UnitT ()



loli :: Unit -> Application
loli unit = run unit (not_found empty_app)
  where
    run :: Unit -> Middleware
    run unit' = 
      let s           = execState unit' def
          paths       = s.routes
          
          loli_app    = router paths
          mime_filter = lookup_mime (s.mimes)
          stack       = s.middlewares.use
          pre         = pre_installed_middlewares.use
      in
      use [pre, mime_filter, stack, loli_app]

update :: (MonadState a m, Functor m) => (a -> a) -> m ()
update f = get ^ f >>= put

add_route :: RoutePath -> Loli -> Loli
add_route r s = let xs = s.routes in s {routes = xs.insert_last r}

route :: RequestMethod -> String -> AppUnit -> Unit
route r s u = update $ add_route (r, s, u)

add_middleware :: Middleware -> Loli -> Loli
add_middleware x s = 
  let xs = s.middlewares in s {middlewares = xs.insert_last x}

add_mime :: String -> String -> Loli -> Loli
add_mime k v s = let xs = s.mimes in s {mimes = xs.insert_last (k, v)}

-- middleware
lookup_mime :: [(String, String)] -> Middleware
lookup_mime h app env = do
  r <- app env
  case h.only_fst.find mime >>= flip lookup h of
    Nothing -> return r
    Just v -> return $ r.set_content_type v
  where mime x = env.path_info.ends_with ('.' : x)