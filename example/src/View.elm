module View exposing (view)

import Html exposing (Html, div, text)
import PivotView as Pivot
import Types exposing (Model, Msg(..), Taco)


view : Model -> Html Msg
view state =
    Pivot.view config viewConfig state


config : Pivot.Config Taco
config =
    Pivot.newConfig [ .name ] [ .period ] (.km >> toFloat)


viewConfig : Pivot.ViewConfig Msg
viewConfig =
    Pivot.defaultViewConfig
