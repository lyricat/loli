ANN: loli: a minimal web dev DSL

loli is a DSL built on hack. It allows you to easily define routes, build your custom template backends through a simple Template interface, and integrate with other hack middleware.

* driver

    The simplest app looks like this

        import Network.Loli
        import Hack.Handler.Happstack

        main = run . loli - get "/" (text "loli power")
        
* route

        get "/hello" - do
          text "hello"

    will route "/hello" to a controller that outputs hello.

* middleware

    using a middleware is just as declaring

        middleware lambda
        
* template

    the template interface is

        class Template a where
          interpolate :: a -> String -> Context -> IO String

    Context is just [(String, String)]

    After implementing your own template engine, you can use
    
        output - your-engine-constructor "template-name"

* demo

    I put the source of a dummy paste app on itself:

    <http://lolipaste.easymic.com/00000-lolipaste.haskell>


loli is on hackage, lolipaste is in loli repo on github:

* <http://github.com/nfjinjing/loli>

happy hacking