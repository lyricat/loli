module Network.Loli.Utils where

import Hack
import Hack.Contrib.Utils
import MPS.Light
import Prelude hiding ((.), (/), (>), (^))

namespace :: String -> Env -> [(String, String)]
namespace x env =
  env
    .custom
    .select (fst > starts_with x)
    .map_fst (drop (x.length))

set_namespace :: String -> [(String, String)] -> Env -> Env
set_namespace x xs env = 
  let adds = xs.map_fst (x ++)
      new_headers = adds.map fst
      new_hack_headers = env.custom.reject (fst > belongs_to new_headers) ++ adds
  in
  env {hackHeaders = new_hack_headers}


add_namespace :: String -> String -> String -> Env -> Env
add_namespace x k v = set_namespace x [(k,v)]

insert_last :: a -> [a] -> [a]
insert_last x xs = xs ++ [x]