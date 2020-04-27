# Pivot view

Elm library for displaying data in a cross tab view.

## Example

```elm
import PivotView as Pivot

view : State -> Html Msg
view state =
    Pivot.view (config state) viewConfig state.data

config : State -> P.Config SalesItem
config state =
    P.defaultConfig [ .grouping1 ] [ .colGrouping ] .value

viewConfig : P.ViewConfig Msg
viewConfig =
    P.defaultViewConfig

type alias SalesItem =
  { grouping1 : String
  , colGrouping : String
  , value : Float  
  }
  
```
