import Hack
import Hack.Handler.Happstack
import Data.ByteString.Lazy.Char8 (pack)

app :: Application
app = \env -> return $
  Response 200 [ ("Content-Type", "text/plain") ] (pack "Hello, universe!")

main = run app