module Network.Loli.Middleware.LoliRouter (loli_router) where

import Data.List (find)
import Data.Maybe
import Hack
import Hack.Contrib.Utils
import Hack.Contrib.Utils hiding (get, put)
import MPS
import Network.Loli.Utils
import Prelude hiding ((.))


type RoutePathT a   = (RequestMethod, String, a)
type Assoc          = [(String, String)]

loli_router :: String -> (a -> Application) -> [RoutePathT a] -> Middleware
loli_router prefix runner h app' = \env'' ->
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
      runner app_state (mod_env location .merge_captured params)
  where
    match_route env' (method, template, _) = 
      env'.request_method.is method 
        && env'.path_info.parse_params template .isJust
    merge_captured params env' = 
      env'.put_namespace prefix params 


parse_params :: String -> String -> Maybe (String, Assoc)
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