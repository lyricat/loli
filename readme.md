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

    -- note both etag and lambda middleware are removed ... for somce ghc 7.0 compatability ><
    
    import Hack.Contrib.Middleware.ETag
    import Hack.Contrib.Middleware.Lambda
    
    middleware etag
    middleware lambda

### Convert loli into a hack application

    -- in Network.Loli.Engine
    
    loli :: Unit -> Application


## Hints

* It's recommended to use your own html combinator / template engine, loli's template system is for completeness rather then usefulness... The author has removed the section on view from this readme. Examples can still be found in `src/Test/Test.hs`. Try DIY with, e.g. [moe](http://github.com/nfjinjing/moe). The template code will stay for, say, a few years, but will eventually fade away.
* [Example view using custom html combinator (moe in this case)](http://github.com/nfjinjing/loli/blob/master/src/Test/Moe.hs)
* When inspecting the request, use `ask` defined in `ReaderT` monad to get the `Hack.Environment`, then use helper method defined in `Hack.Contrib.Request` to query it.
* `Response` is in `StateT`, `html` and `text` are simply helper methods that update the state, i.e. setting the response body, content-type, etc.
* You do need to understand monad transformers to reach the full power of `loli`.
* For mac users, use `GHC 6.12.1` if you have trouble running the server.
    
## Reference

* loli is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).


<br/>
<br/>


<a href="http://en.wikipedia.org/wiki/Shinryaku!_Ika_Musume"><img src="http://github.com/nfjinjing/loli/raw/master/Ita.jpg"/></a>