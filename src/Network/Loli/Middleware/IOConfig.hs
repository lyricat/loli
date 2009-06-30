module Network.Loli.Middleware.IOConfig (ioconfig) where

import Hack

ioconfig :: (Env -> IO Env) -> Middleware
ioconfig before app = \env -> before env >>= app