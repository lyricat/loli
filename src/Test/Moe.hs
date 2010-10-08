import qualified Network.Loli as Loli
import Network.Loli (get, loli)
import Hack.Handler.Happstack
import Text.HTML.Moe2

import Prelude hiding ((/), (-), head, (>), (.), div)
import MPS.Env ((-))


hello_page :: String
hello_page = render -
  html - do
    head - do
      meta ! [http_equiv "Content-Type", content "text/html; charset-utf-8"] - (/)
      title - str "my title"

    body - do
      div ! [_class "container"] - do
        str "hello world"
        
        
main = do
  putStrLn - "server started..."
  
  run - loli - do
    get "/" - do
      Loli.html - hello_page