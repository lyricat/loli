{-
  This Demo file is licenced under GPL !
  
  - Jinjing Wang
-}

{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE QuasiQuotes #-}

{- cabal install highlighting-kate
 - cabal install utf8-prelude
 - cabal install hack-handler-happstack
 -}

import Control.Monad.Reader hiding (join)
import Data.Default
import Data.List
import Data.Maybe
import Hack.Contrib.Constants
import Hack.Contrib.Middleware.ContentType
import Hack.Contrib.Middleware.Lambda
import Hack.Contrib.Middleware.ShowStatus
import Hack.Contrib.Request hiding (content_type, port)
import Hack.Contrib.Response
import Hack.Contrib.Utils (unescape_uri, escape_html)
import Hack.Handler.Happstack
import MPS.Heavy
import MPS.TH
import MPSUTF8
import Network.Loli
import Network.Loli.Engine
import Network.Loli.Template.TextTemplate
import Network.Loli.Utils
import System.Directory
import Text.Highlighting.Kate (highlightAs, formatAsXHtml)
import Text.XHtml.Strict (renderHtmlFragment)
import UTF8Prelude hiding ((^), (.), (>), (/), read)
import qualified Prelude as P
import qualified Text.Highlighting.Kate as Kate (languages)

-- Config
db, sep :: String
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
list = ls db ^ reject (starts_with ".") ^ rsort >>= mapM read

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
exist x = doesFileExist (db / (x.u2b))
   
paste_id :: Paste -> String
paste_id x = x.no.format_no ++ sep ++ x.user ++ "." ++ x.lang

link :: Paste -> String
link x = "/" ++ x.paste_id



-- Controller
main :: IO ()
main = runWithConfig def {port = 5000}  $ loli $ do

  public (Just "public") ["/css", "/js"]
  
  middleware lambda
  middleware show_status
  middleware $ content_type _TextHtml
  
  views "views/loli_paste"
  layout "layout.html"
  
  
  get "/create" $ do
    bind "options" options $ do
      output $ text_template "create.html"
  
  get "/:paste" $ do
    name <- captures ^ lookup "paste" ^ fromJust ^ unescape_uri ^ b2u
    if ".." `isInfixOf` name
      then html "no permission"
      else do
        paste_exists <- exist name .io
        if paste_exists
          then do
            paste <- read name .io
            raw <- ask ^ params ^ lookup "raw"
            case raw of
              Just "true" -> no_layout $ text (paste.src)
              _ -> do
                context 
                  [ ("paste_id", paste.paste_id)
                  , ("src", paste.src.kate (paste.lang.guess_lang))
                  ] $ output $ text_template "view.html"
        
          else html "paste missing"

  post "/" $ do
    form <- ask ^ inputs ^ map_snd unescape_unicode_xml
    let src'  = form.lookup "src"
        user' = form.lookup "user"
        lang' = form.lookup "lang"
    
    if [src', user', lang'] .any isNothing 
      || (lang'.isJust && lang'.fromJust.null)
      || (src'.isJust && src'.fromJust.null)
      then do
        print "form failed" .io
        html "post param missing"
      else do
        let src   = src'.fromJust.take 8096
            user  = user'.fromJust.take 30
            lang  = lang'.fromJust.take 20
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
    pastes <- list .io ^ take 50
    let rows = pastes.map row .concat
    bind "rows" rows $ do
      output $ text_template "list.html"

-- View helper

kate :: String -> String -> String
kate language code = 
  case highlightAs language code of
    Right result -> renderHtmlFragment $ 
        formatAsXHtml [] language result
    Left  _    -> "<pre><code>" ++ code ++ "</pre></code>"


guess_lang :: String -> String
guess_lang s = languages.find (is s).fromMaybe "txt"

languages :: [String]
languages = Kate.languages.map lower

options :: String
options = languages.map make_option .join "\n"
  where
    make_option x = [$here|<option value="#{x}">#{x}</option>|]

h :: String -> String
h = escape_html

row :: Paste -> String      
row x = "<div class=\"row\"><h3><a href=\"" ++ x.link.h ++ "\">"
  ++ x.paste_id.h ++ "</a></h3></div>"

