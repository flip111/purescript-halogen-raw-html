# Halogen raw HTML support

Just import this
```purescript
import Halogen.HTML.Raw as Raw
import Type.Row (type (+))
```

Add the `Raw.Slot Unit` slot to your slot type and you can immediately begin to use the `Raw.raw` function.

example
```purescript
module Main where

import Prelude
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.HTML.Raw as Raw
import Halogen.VDom.Driver (runUI)
import Type.Row (type (+))

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body

component :: forall q i o m. MonadEffect m => H.Component q i o m
component = H.mkComponent
  { initialState: \_ -> unit
  , render: \_ -> template
  , eval: H.mkEval $ H.defaultEval { handleAction = \_ -> pure unit }
  }

type CustomChildSlotsA = ( custom1 :: H.Slot (Const Void) Unit Unit, custom2 :: H.Slot (Const Void) Unit Unit )
type CustomChildSlotsB = ( custom2 :: H.Slot (Const Void) Unit Unit, custom3 :: H.Slot (Const Void) Unit Unit )

-- H.ComponentHTML action slots m ~ HH.HTML (H.ComponentSlot slots m action) action
template :: forall action m. MonadEffect m => H.ComponentHTML action (CustomChildSlotsA + CustomChildSlotsB + Raw.Slot Unit + ()) m
template = HH.div [ Raw.raw "<b>hello world</b>" ]
```

## History
Related issue: https://github.com/purescript-halogen/purescript-halogen/issues/324

1. https://gist.github.com/ibrahimsag/e142652bcad3c8ade14a727ae952937a
2. https://gist.github.com/prathje/7422e49b7c809fe8236bb2f213e7076e
3. https://github.com/rnons/purescript-html-parser-halogen
4. this repository

These are all pieces of code based around the same idea.

As far as i know there is no reason why halogen and underlying virtual dom implementation could not support a raw html element. At the moment this is not the case though. One difficulty of trying to manipulating this situation with foreign function interface is that halogen renders before it applies any actions which you can hook into. That means your own component would need extra code to run any further dom manipulation functions.

The solution chosen here works because halogen components take the place of "widget" in the virtual dom implementation. Each widget gets to control it's own life cycle and thus can perform actions on initialization. You can imagine the sequence of events going like:

1. Parent start render
2. child start render
3. child actions (initialize)
4. parent render complete
5. parent actions (initialize)
