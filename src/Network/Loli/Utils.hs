module Network.Loli.Utils where

import Control.Monad.State
import Hack
import MPS.Light
import Prelude hiding ((.), (/), (>), (^))
import Data.ByteString.UTF8 (fromString, toString)

namespace :: String -> Env -> [(String, String)]
namespace x env =
  env
    .hackCache
    .map_fst toString
    .map_snd toString
    .select (fst > starts_with x)
    .map_fst (drop (x.length))

put_namespace :: String -> [(String, String)] -> Env -> Env
put_namespace x xs env = 
  let adds             = xs.map_fst (x ++) .map_fst fromString .map_snd fromString
      new_headers      = adds.map fst
      new_hack_headers = 
        env.hackCache.reject (fst > belongs_to new_headers) ++ adds
  in
  env {hackCache = new_hack_headers}


set_namespace :: String -> String -> String -> Env -> Env
set_namespace x k v = put_namespace x [(k,v)]

delete_namespace :: String -> String -> Env -> Env
delete_namespace x k env = 
  let new_hack_headers = env.hackCache.reject (fst > is (fromString (x ++ k)))
  in
  env {hackCache = new_hack_headers}

insert_last :: a -> [a] -> [a]
insert_last x xs = xs ++ [x]

update :: (MonadState a m, Functor m) => (a -> a) -> m ()
update f = get ^ f >>= put

