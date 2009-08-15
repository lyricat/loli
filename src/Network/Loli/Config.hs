module Network.Loli.Config where

import Hack
import Hack.Contrib.Middleware.Config
import Hack.Contrib.Middleware.ContentLength
import Hack.Contrib.Middleware.ContentType
import Network.Loli.Utils
import Prelude hiding ((.), (>), (^))


pre_installed_middlewares :: [Middleware]
pre_installed_middlewares = 
  [
    content_length
  , content_type default_content_type
  , config set_view_root
  ]
  where
    set_view_root = set_namespace loli_config loli_views loli_default_views
    default_content_type :: String
    default_content_type = "text/plain; charset=UTF-8"



loli_captures       :: String
loli_locals         :: String
loli_partials       :: String
loli_config         :: String
loli_layout         :: String
loli_views          :: String
loli_default_views  :: String
loli_layout_content :: String

loli_captures       = "loli-captures-"
loli_locals         = "loli-locals-"
loli_partials       = "loli-partials-"
loli_config         = "loli-config-"
loli_layout         = "layout"
loli_views          = "views"
loli_default_views  = "views"
loli_layout_content = "content"
