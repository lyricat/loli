module Network.Loli.Middleware.Cascade (cascade) where

import Hack
import MPS.Light
import Prelude hiding ((.), (-), (>))
import Data.Default

{-
def initialize(apps, catch=404)
  @apps = []; @has_app = {}
  apps.each { |app| add app }

  @catch = {}
  [*catch].each { |status| @catch[status] = true }
end

def call(env)
  result = NotFound

  @apps.each do |app|
    result = app.call(env)
    break unless @catch.include?(result[0].to_i)
  end

  result
end
-}

cascade :: [Application] -> Application
cascade xs = \env -> do
  ys <- xs.mapM (send_to env)
  let zs = ys.filter(status > is_not 404)
  print zs
  case zs of
    x:_ -> return x
    _ -> return def {status = 404}
  