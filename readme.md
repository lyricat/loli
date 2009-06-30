# loli

A minimum web dev DSL

## Example

First app

    -- myloli.hs
    
    import Network.Loli
    import Hack.Handler.Happstack
    
    main = run . loli $ get "/" (text "loli power")

Install and compile:

    cabal update
    cabal install loli
    cabal install hack-handler-happstack
    
    ghc --make myloli.hs
    ./myloli

check: <http://localhost:3000>


## Routes

### Verbs

    get "/" $ do
      -- something for a get request

    post "/" $ do
      -- for a post request
    
    put "/" $ do
      -- put ..
    
    delete "/" $ do
      -- ..
### Captures

    get "/say/:user/:message" $ do
      text . show =<< captures

    -- /say/jinjing/hello will output
    -- [("user","jinjing"),("message","hello")]


## Static

    -- public serve, only allows /src
    public (Just ".") ["/src"]

## Views root

    -- in `./views`, can be changed by
    views "template"

## Template

### Text Template

    import Network.Loli.Template.TextTemplate
    
    -- template
    get "/hi/:user" $ output (text_template "hello.html")
    
    -- in hello.html
    <html>
    <title>hello</title>
    <body>
      <p>hello $user</p>
    </body>
    </html>

### Local binding

    get "/local-binding" $ do
      bind "user" "alice" $ output (text_template "hello.html")

### Batched local bindings

    get "/batched-local-binding" $ do
      context [("user", "alice"), ("password", "foo")] $ 
        text . show =<< locals

## Partials

Partials are treated the same as user supplied bindings, i.e. the rendered text is available to the rest of templates, referenced by user supplied keywords.

### with single partial

    get "/single-partial" $ do
      partial "user" (const_template "const-user") $ do
        text . show =<< template_locals

### with batched partials

    get "/group-partial" $ do
      partials 
        [ ("user", const_template "alex")
        , ("password", const_template "foo")
        ] $ output (text_template "hello.html")

## Layout

### Local

    get "/with-layout" $ do
      with_layout "layout.html" $ do
        text "layout?"
    
    -- in layout.html
    <html>
    <body>
      <h1>using a layout</h1>
      $content
    </body>
    </html>

### Global

    layout "layout.html"

### By passed

    get "/no-layout" $ do
      no_layout $ do
        text "no-layout"


## Mime types

    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

## Hack integration

### Use hack middleware

    import Hack.Contrib.Middleware.ETag
    import Hack.Contrib.Middleware.ShowStatus
    
    middleware etag
    middleware show_status

### Convert loli into a hack application

    -- in Network.Loli.Engine
    
    loli :: Unit -> Application

## Note

If you see this, use the git version!

## Reference

* loli is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).

* About the naming: It's not that serious since I'm a manga fan / otaku. But if you insist I can make this library GPL3 + (18+).