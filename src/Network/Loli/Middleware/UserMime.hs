module Network.Loli.Middleware.UserMime (user_mime) where

import Data.List (find)
import Hack
import Hack.Contrib.Response
import Hack.Contrib.Utils
import MPS.Light
import Prelude hiding ((.), (-))


user_mime :: [(String, String)] -> Middleware
user_mime h app env = do
  r <- app env
  case h.only_fst.find mime >>= flip lookup h of
    Nothing -> return r
    Just v -> return - r.set_content_type v
  where mime x = env.path_info.ends_with ('.' : x)
