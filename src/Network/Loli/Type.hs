module Network.Loli.Type where

import Control.Monad.Reader
import Control.Monad.State
import Data.Default
import Hack
import Hack.Contrib.Utils
import Network.Loli.Middleware.LoliRouter

type RoutePathT a = (RequestMethod, String, a)
type RoutePath    = RoutePathT AppUnit

type Assoc        = [(String, String)]

type AppState     = Response
type AppReader    = Env

type AppUnitT     = ReaderT AppReader (StateT AppState IO)
type AppUnit      = AppUnitT ()
type Context      = Assoc

type RouterT a = String -> (a -> Application) -> RoutePathT a -> Middleware
type Router    = RouterT AppUnit

data RouteConfig = RouteConfig
  {
    route_path :: RoutePath
  , router     :: Router
  }

data Loli = Loli
  {
    current_router  :: Router
  , routes          :: [RouteConfig]
  , middlewares     :: [Middleware]
  , mimes           :: Assoc
  }


instance Default Loli where
  def = Loli loli_router def [dummy_middleware] def


type UnitT a = State Loli a
type Unit    = UnitT ()

class Template a where
  -- the only interface for template
  interpolate :: a -> String -> Context -> IO String