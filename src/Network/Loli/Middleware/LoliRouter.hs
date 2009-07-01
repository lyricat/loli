module Network.Loli.Middleware.LoliRouter (loli_router) where

import Data.Maybe
import Hack
import Hack.Contrib.Utils
import Hack.Contrib.Utils hiding (get, put)
import MPS
import Prelude hiding ((.), (>), (/))


type RoutePathT a = (RequestMethod, String, a)
type Assoc        = [(String, String)]


loli_router :: String -> (a -> Application) -> RoutePathT a -> Middleware
loli_router prefix runner route_path app' = \env ->
  let path             = env.path_info
      script           = env.script_name
      mod_env location = env 
        { scriptName  = script ++ location
        , pathInfo    = path.drop (location.length)
        }
  in
  if route_path.match_route env.not
    then app' env
    else do
      let (_, template, app_state) = route_path
          (location, params) = parse_params template path .fromJust
      runner app_state (mod_env location .merge_captured params)
  where
    match_route env' (method, template, _) = 
      env'.request_method.is method 
        && env'.path_info.parse_params template .isJust
    merge_captured params env' = 
      env'.put_namespace prefix params 


parse_params :: String -> String -> Maybe (String, Assoc)
parse_params "" ""  = Just ("", [])
parse_params "" _   = Nothing
parse_params "/" "" = Nothing
parse_params "/" _  = Just ("/", [])

parse_params t s = 
  let template_tokens = t.split "/"
      url_tokens      = s.split "/"
  in
  if url_tokens.length < template_tokens.length
    then Nothing
    else 
      let rs = zipWith capture template_tokens url_tokens
      in
      if rs.all isJust
        then 
          let token_length = template_tokens.length
              location     = "/" / url_tokens.take token_length .join "/"
          in
          Just $ (location, rs.map fromJust.filter isJust.map fromJust)
        else Nothing
  
  where
    capture x y 
      | x.starts_with ":" = Just $ Just (x.tail, y)
      | x == y = Just Nothing
      | otherwise = Nothing
      
-- copy from loli utils
put_namespace :: String -> Assoc -> Env -> Env
put_namespace x xs env = 
  let adds             = xs.map_fst (x ++)
      new_headers      = adds.map fst
      new_hack_headers = 
        env.custom.reject (fst > belongs_to new_headers) ++ adds
  in
  env {hackHeaders = new_hack_headers}
