import Network.Loli
import Hack.Handler.Happstack

main = run . loli $ do
  
  get "/hello"    (text "hello world")
  get "/cabal"    $ text =<< io (readFile "loli.cabal")
  
  get "/say/:user/:verb" $ do
    text . show =<< captured

  get "/html"     (html "<html><body><p>loli power!</p></body></html>")
  
  get "/"         (text "at root")
  
  public (Just ".") ["/src"]
  mime "hs" "text/plain"