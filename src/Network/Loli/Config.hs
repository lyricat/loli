module Network.Loli.Config where

import Hack
import Hack.Contrib.Middleware.ContentLength
import Hack.Contrib.Middleware.ContentType
import Hack.Contrib.Middleware.Config
import MPS.Light
import Prelude hiding ((.), (>), (^))

pre_installed_middlewares :: [Middleware]
pre_installed_middlewares = 
  [
    content_length
  , content_type default_content_type
  , config set_view_root
  ]
  where
    set_view_root env =
      let hack_headers = env.hackHeaders
          view_root = (loli_views ++ "root", "views")
      in
      env {hackHeaders = hack_headers ++ [view_root]}
    default_content_type :: String
    default_content_type = "text/plain; charset=UTF-8"
    
loli_captures :: String
loli_captures = "loli_captures_"

loli_bindings :: String
loli_bindings = "loli_bindings_"

loli_views :: String
loli_views = "loli_views_"