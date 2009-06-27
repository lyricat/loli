module Network.Loli.Template.ConstTemplate where
  
import Network.Loli.Type

data ConstTemplate = ConstTemplate String

instance Template ConstTemplate where
  interpolate (ConstTemplate x) _ = return x

const_template :: String -> AppUnitT ConstTemplate
const_template x = return $ ConstTemplate x