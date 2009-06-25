import Network.Loli
import Hack.Handler.Happstack

main = run . loli $ do
  
  get "/hello" (text "hello world")
  get "/" (html "<html><body><p>loli power!</p></body></html>")

  public (Just ".") ["/src"]
    
  mime "hs" "text/plain"