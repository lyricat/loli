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

### Verb

    get "/" $ do
      -- something for a get request

    post "/" $ do
      -- for a post request
    
    put "/" $ do
      -- put ..
    
    delete "/" $ do
      -- ..
### Captures

    get "/say/:user/:something" $ do
      text . show =<< captures

    -- /say/jinjing/hello will output
    -- [("user","jinjing"),("something","hello")]


## Static

    -- public serve, only allows /src
    public (Just ".") ["/src"]

## Views

    -- in `./views`, can be changed by
    views "template"

### TextTemplate

    import Network.Loli.Template.TextTemplate
    
    -- template
    get "/hi/:user" $ text_template "hello.html"
    
    -- in hello.html
    <html>
    <title>hello</title>
    <body>
      <p>hello $user</p>
    </body>
    </html>

### Local bindings

    get "/local-binding" $ do
      bind "user" "alice" (text_template "hello.html")

### Batched local bindings

    get "/batched-local-binding" $ do
      context [("user", "alice"), ("password", "foo")] $ 
        text . show =<< bindings


## Mime types

    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

## Note

If you see this, use the git version!