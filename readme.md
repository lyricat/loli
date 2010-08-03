# loli

A minimum web dev DSL

## Example

First app

    import Network.Loli
    import Hack.Handler.Happstack
    
    main = run . loli $ get "/" (text "loli power")

## Installation

    cabal update
    cabal install loli
    cabal install hack-handler-happstack
    
    -- copy and paste the above example to myapp.hs
    
    ghc --make myapp.hs
    ./myapp

check: <http://localhost:3000>


## Routes

### Verbs

    -- use - instead of $ for clarity
    import MPS.Light ((-))
    import Prelude hiding ((-))
    
    import Network.Loli
    import Hack.Handler.Happstack
    
    main = run . loli - do

      get "/" - do
        -- something for a get request

      post "/" - do
        -- for a post request
    
      put "/" - do
        -- put ..
    
      delete "/" - do
        -- ..

### Captures

    get "/say/:user/:message" - do
      text . show =<< captures

    -- /say/jinjing/hello will output
    -- [("user","jinjing"),("message","hello")]


## Static

    -- public serve, only allows `./src`
    public (Just ".") ["/src"]

## Views root

    -- in `./views`, can be changed by
    views "template"

## Template

### Text Template

    import Network.Loli.Template.TextTemplate
    
    get "/hi/:user" - output (text_template "hello.html")
    
    -- in hello.html
    <html>
    <title>hello</title>
    <body>
      <p>hello $user</p>
    </body>
    </html>

### Local binding

    get "/local-binding" - do
      bind "user" "alice" - output (text_template "hello.html")

### Batched local bindings

    get "/batched-local-binding" - do
      context [("user", "alice"), ("password", "foo")] - 
        text . show =<< locals

## Partials

Partials are treated the same as user supplied bindings, i.e. the rendered text is available to the rest of templates, referenced by user supplied keywords.

### with single partial

    import Network.Loli.Template.ConstTemplate

    get "/single-partial" - do
      partial "user" (const_template "const-user") - do
        text . show =<< template_locals

### with batched partials

    get "/group-partial" - do
      partials 
        [ ("user", const_template "alex")
        , ("password", const_template "foo")
        ] - output (text_template "hello.html")

## Layout

### Local

    get "/with-layout" - do
      with_layout "layout.html" - do
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

    get "/no-layout" - do
      no_layout - do
        text "no-layout"


## Mime types

    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

## Filters

    -- before takes a function of type (Env -> IO Env)
    before - \e -> do
      putStrLn "before called"
      return e
    
    -- after takes that of type (Response -> IO Response)
    after return

## Hack integration

### Use hack middleware

    import Hack.Contrib.Middleware.ETag
    import Hack.Contrib.Middleware.Lambda
    
    middleware etag
    middleware lambda

### Convert loli into a hack application

    -- in Network.Loli.Engine
    
    loli :: Unit -> Application

## Hints

* use the git version ...
* it's recommended to use your own html combinator / template engine, loli's template system is for completeness rather then usefulness... there are lots of choices, your are in IO, go nuts.

## Reference

* loli is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).

## Loli ??

<a href="http://en.wikipedia.org/wiki/The_Familiar_of_Zero#Main_characters">
  <img src="http://github.com/nfjinjing/loli/raw/master/louise.jpg" alt="louise" />
</a>

