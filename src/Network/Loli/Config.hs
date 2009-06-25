module Network.Loli.Config where

import Hack
import Hack.Contrib.Middleware.ContentLength
import Hack.Contrib.Middleware.ContentType

pre_installed_middlewares :: [Middleware]
pre_installed_middlewares = 
  [
    content_length
  , content_type default_content_type
  ]
  where
    default_content_type :: String
    default_content_type = "text/plain; charset=UTF-8"
    
loli_captures_prefix :: String
loli_captures_prefix = "loli_captures_"