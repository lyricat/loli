-- import Network.Loli hiding (app)
import Hack.Handler.Happstack
import Data.ByteString.Lazy.Char8 
import Hack
import Prelude hiding ((.), (>), (/), (^))
import MPS.Light
import Hack.Contrib.Response
import Data.Default

app :: Application
app = \env -> do
  -- let r = def.set_body (pack "pure_hack")
  let r = def.set_status 200
  return r


-- main' = run . loli $ get "/" (text "loli power")

main = run app