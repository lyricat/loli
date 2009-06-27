module Network.Loli.Template.ConstTemplate where
  
import Network.Loli.Type

data ConstTemplate = ConstTemplate String 

instance Template ConstTemplate where
  interpolate (ConstTemplate x) _ _ = return x

const_template :: String -> ConstTemplate
const_template = ConstTemplate