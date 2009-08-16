import Network.Loli
import Hack.Handler.Happstack

main = run . loli - get "/" (text "loli power")