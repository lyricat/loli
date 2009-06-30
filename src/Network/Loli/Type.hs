module Network.Loli.Type where

import Control.Monad.Reader
import Control.Monad.State
import Data.Default
import Hack
import Hack.Contrib.Utils

type RoutePathT a   = (RequestMethod, String, a)
type RoutePath      = RoutePathT AppUnit
type Assoc          = [(String, String)]
type AppState       = Response
type AppReader      = Env

type AppUnitT       = ReaderT AppReader (StateT AppState IO)
type AppUnit        = AppUnitT ()
type Context        = Assoc

data Loli = Loli
  {
    routes      :: [RoutePath]
  , middlewares :: [Middleware]
  , mimes       :: Assoc
  }

instance Default Loli where
  def = Loli def [dummy_middleware] def


type UnitT a = State Loli a
type Unit    = UnitT ()

class Template a where
  -- the only interface for template
  interpolate :: a -> String -> Context -> IO String