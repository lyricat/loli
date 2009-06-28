{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE QuasiQuotes #-}

import Control.Monad.Reader hiding (join)
import Hack.Contrib.Constants
import Hack.Contrib.Response
import Hack.Contrib.Middleware.Lambda
import Hack.Contrib.Middleware.ShowStatus
import Hack.Contrib.Middleware.ContentType
import Hack.Handler.Happstack
import Network.Loli
import Network.Loli.Engine
import Network.Loli.Template.ConstTemplate (const_template)
import Network.Loli.Template.TextTemplate
import Network.Loli.Utils
import Data.Maybe
import MPS
import MPS.TH
import Prelude hiding ((^), (.), (>), (/), read)
import qualified Prelude as P
import Hack.Contrib.Request hiding (content_type)
import Hack.Contrib.Utils hiding (get, now)
import Data.Default
import System.Directory

-- Config
db = "db"
sep = "-"

-- Model

data Paste = Paste
  {
    no :: Int
  , user :: String
  , lang :: String
  , src :: String
  }
  deriving (Eq, Show)

instance Default Paste where
  def = Paste def def def def

-- CRUD

create :: Paste -> IO ()
create x = x.src.writeFile (db / name)
  where
    valid_name = if x.user.null then "foo" else x.user
    name = 
      [ x.no.format_no
      , sep
      , valid_name
      , "."
      , x.lang
      ] .concat


list :: IO [Paste]
list = ls db ^ rsort >>= mapM read

read :: String -> IO Paste
read x =  do
  src <- readFile (db / x)
  return $ def {no, lang, user, src}
  where
    no = x.split sep .first .P.read :: Int
    lang = x.split "\\." .last
    user = x
      .reverse
      .drop (lang.length + 1)
      .reverse
      .split sep
      .tail
      .join sep

-- Model helper
format_no :: Int -> String
format_no x = x.show.ljust 5 '0'

exist :: String -> IO Bool
exist x = doesFileExist (db / x)
   
name x = x.no.format_no ++ sep ++ x.user ++ "." ++ x.lang
link x = "/" ++ x.name



-- Controller
main = run $ loli $ do

  middleware lambda
  middleware show_status
  middleware $ content_type _TextHtml
  
  views "views/loli_paste"
  layout "layout.html"
  
  public (Just "public") ["/css", "/js"]
  
  get "/create" $ do
    output $ text_template "create.html"
  
  get "/:paste" $ do
    name <- captures ^ lookup "paste" ^ fromJust
    paste_exists <- exist name .io
    if paste_exists
      then read name .io >>=  display > html
      else html "paste missing"

  post "/" $ do
    form <- ask ^ inputs
    let src'  = form.lookup "src"
        user' = form.lookup "user"
        lang' = form.lookup "lang"
    
    if [src', user', lang'] .any isNothing 
      || (lang'.isJust && lang'.fromJust.null)
      then do
        print "form failed" .io
        html "post param missing"
      else do
        let src   = src'.fromJust.take 8096
            user  = user'.fromJust.take 30
            lang  = lang'.fromJust
            paste = def { src, user, lang }
        
        pastes <- ls db .io
        
        if pastes.null
          then paste.create.io
          else do
            let get_id = split sep > first > P.read
            no <- ls db .io ^ rsort ^ first ^ get_id ^ (+1)
            paste { no } .create .io
        
        update $ redirect "/" Nothing
              
  -- default
  get "/" $ do
    pastes <- list .io
    let rows = pastes.map row .concat
    bind "rows" rows $ do
      output $ text_template "list.html"





-- View snippets

row x = [$here|
<div class="row">
  <h3>
  <a href="#{x.link}">
    #{x.name}
  </a>
  </h3>
</div>
|]

display x = [$here|
<div class="paste">
  <h3>
    #{x.name}
  </h3>
  <pre><code>
  #{x.src}
  </code></pre>
</div>
|]
