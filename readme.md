### Example

    import Network.Loli
    import Hack.Handler.Happstack

    main = run . loli $ do

      get "/hello" (text "hello")
      get "/" (html "<html><body><p>world</p></body></html>")

      public Nothing ["/src"]

      mime "hs" "text/plain"