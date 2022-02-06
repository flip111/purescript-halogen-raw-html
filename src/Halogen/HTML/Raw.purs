module Halogen.HTML.Raw
  ( rawComponent
  , Slot
  , raw
  ) where

import Prelude

import Data.Const (Const)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Web.DOM (Element)
import Web.HTML.HTMLElement (toElement)
import Type.Row (type (+))
import Type.Proxy (Proxy(Proxy))

foreign import replaceElement :: Element -> String -> Effect Unit

data Action
  = Initialize
  | Receive String

rawComponent :: forall m. MonadEffect m => H.Component (Const Void) String Void m
rawComponent = H.mkComponent
  { initialState: identity
  , render
  , eval: H.mkEval H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    , receive  = Just <<< Receive
    }
  }

handleAction :: forall m. MonadEffect m => Action -> H.HalogenM String Action () Void m Unit
handleAction = case _ of
  Receive input -> H.modify_ (const input)
  Initialize -> do
    s <- H.get
    H.getHTMLElementRef (H.RefLabel "") >>= case _ of
      Nothing -> pure unit
      Just html_element -> do
        liftEffect $ replaceElement (toElement html_element) s
  
-- the div with style inline-block will be completely be replaced
-- it's just the most generic element with display flow i could think of
render :: forall m. String -> H.ComponentHTML Action () m
render _ = HH.div [HP.style "display: inline-block", HP.ref (H.RefLabel "")] []

type Slot i r = (raw :: H.Slot (Const Void) Void i | r)

raw :: forall action m r. MonadEffect m => String -> H.ComponentHTML action (Slot Unit + r) m
raw html = HH.slot_ (Proxy :: Proxy "raw") unit rawComponent html
