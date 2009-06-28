import Control.Monad.Reader
import Hack.Contrib.Response
import Hack.Contrib.Middleware.Lambda
import Hack.Contrib.Middleware.ShowStatus
import Hack.Handler.Happstack
import Network.Loli
import Network.Loli.Engine
import Network.Loli.Template.ConstTemplate (const_template)
import Network.Loli.Template.TextTemplate
import Network.Loli.Utils

-- default on port 3000

main = run . loli $ do

  middleware lambda
  middleware show_status

  -- simple
  get "/hello"    (text "hello world")
  
  get "/debug"    (text . show =<< ask)
  
  -- io
  get "/cabal"    $ text =<< io (readFile "loli.cabal")

  -- route captures
  get "/say/:user/:message" $ do
    text . show =<< captures

  -- html output
  get "/html"     (html "<html><body><p>loli power!</p></body></html>")

  -- template
  get "/hi/:user"        $ output (text_template "hello.html")

  -- manually tweak the reponse body
  get "/hi-html/:user" $ do
    update $ set_content_type "text/html"
    output $ text_template "hello.html"

  -- add local binding
  get "/local-binding" $ do
    bind "user" "alice" $ output (text_template "hello.html")
    
  
  -- batched local locals
  get "/batched-local-binding" $ do
    context [("user", "alice"), ("password", "foo")] $ 
      text .show =<< locals
  
  get "/const-template" $ do
    output (const_template "const-string")
  
  get "/partial-template" $ do
    partial "user" (const_template "const-user") $ do
      text . show =<< template_locals
  
  get "/partial-context" $ do
    partials 
      [ ("user", const_template "alex")
      , ("password", const_template "foo")
      ] $ do
        output (text_template "hello.html")
  
  get "/with-layout" $ do
    with_layout "layout.html" $ do
      text "layout?"
  
  get "/without-layout" $ do
    no_layout $ do
      text "no-layout"
  
  -- default
  -- get "/"         (text "at root")

  -- public serve, only allows /src
  public (Just ".") ["/src"]
  
  -- treat .hs extension as text/plain
  mime "hs" "text/plain"

