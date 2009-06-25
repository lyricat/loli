import Network.Loli
import Hack.Handler.Happstack

-- default on port 3000

main = run . loli $ do

  -- simple
  get "/hello"    (text "hello world")
  
  -- io
  get "/cabal"    $ text =<< io (readFile "loli.cabal")

  -- route captures
  get "/say/:user/:verb" $ do
    text . show =<< captured

  -- html output
  get "/html"     (html "<html><body><p>loli power!</p></body></html>")

  -- default
  get "/"         (text "at root")

  -- public serve, only allows /src
  public (Just ".") ["/src"]
  
  -- treat .hs extension as text/plain
  mime "hs" "text/plain"