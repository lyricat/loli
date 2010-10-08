# loli

A minimum web dev DSL

## Example

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

## Quick reference

<http://github.com/nfjinjing/loli/blob/master/src/Test/Test.hs>


## Routes

### Verbs

    -- use - instead of $ for clarity
    import MPS.Light ((-))
    import Prelude hiding ((-))
    
    import Network.Loli
    import Hack.Handler.Happstack
    
    main = run . loli - do

      get "/" - do
        -- output string as text/html
        html "<p>hello</p>"

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

## Note

* It's recommended to use your own html combinator / template engine, loli's template system is for completeness rather then usefulness... The author has removed the section on view from this readme. Try DIY with, e.g. [moe](http://github.com/nfjinjing/moe). The template code will stay for, say, a few years, but will eventually fade away.
    
## Reference

* loli is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).


