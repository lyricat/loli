module Network.Loli.Config where

import Hack
import Hack.Contrib.Middleware.Config
import Hack.Contrib.Middleware.ContentLength
import Hack.Contrib.Middleware.ContentType
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
          pre_config = [(loli_config ++ loli_views, loli_default_views)]
      in
      env {hackHeaders = hack_headers ++ pre_config}
    default_content_type :: String
    default_content_type = "text/plain; charset=UTF-8"
    
loli_captures :: String
loli_captures = "loli-captures-"

loli_locals :: String
loli_locals = "loli-locals-"

loli_partials :: String
loli_partials = "loli-partials-"

loli_config :: String
loli_config = "loli-config-"

loli_layout :: String
loli_layout = "layout"

loli_views :: String
loli_views = "views"

loli_default_views :: String
loli_default_views = "views"

loli_layout_content :: String
loli_layout_content = "content"