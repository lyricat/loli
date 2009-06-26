import Network.Loli
import Hack.Handler.Happstack
import Hack.Contrib.Response
import Hack.Contrib.Utils (dummy_middleware)
import Network.Loli.Template.TextTemplate
import Network.Loli.Engine

-- default on port 3000

main = run . loli $ do

  -- simple
  get "/hello"    (text "hello world")
  
  -- io
  get "/cabal"    $ text =<< io (readFile "loli.cabal")

  -- route captures
  get "/say/:user/:something" $ do
    text . show =<< captures

  -- html output
  get "/html"     (html "<html><body><p>loli power!</p></body></html>")

  -- template
  get "/hi/:user"        $ text_template "hello.html"

  -- manually tweak the reponse body
  get "/hi-html/:user" $ do
    update $ set_content_type "text/html"
    text_template "hello.html"

  -- add local binding
  get "/local-binding" $ do
    bind "user" "alice" (text_template "hello.html")
    
  
  -- batched local bindings
  get "/batched-local-binding" $ do
    context [("user", "alice"), ("password", "foo")] $ 
      text .show =<< bindings
  
  
  -- default
  get "/"         (text "at root")

  -- public serve, only allows /src
  public (Just ".") ["/src"]
  
  -- treat .hs extension as text/plain
  mime "hs" "text/plain"

