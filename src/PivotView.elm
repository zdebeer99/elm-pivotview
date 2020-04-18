module PivotView exposing
    ( view, render, ViewConfig
    , Config, newConfig, buildDataView, Matrix
    , defaultViewConfig, defaultRowAttributes, defaultRowHeaderAttributes, defaultValueCellAttributes
    , setRowHeaderTemplate, setColumnHeaderTemplate, setValueTemplate, showTotals, setTotalsTemplate, setRowAttributes, setValueCellAttributes
    , setRowHeaderAttributes, stickyHeading
    , valueDefaultTemplate
    , viewStructure
    , emptyMatrix
    )

{-|


# Draw a pivot table from a list of records.

Currently this library only supports.

  - One Heading Group
  - One Value
  - Sum Values Only


# View

@docs view, render, ViewConfig


# Config

@docs Config, newConfig, buildDataView, Matrix


# View Config

@docs defaultViewConfig, defaultRowAttributes, defaultRowHeaderAttributes, defaultValueCellAttributes


# View Properties

@docs setRowHeaderTemplate, setColumnHeaderTemplate, setValueTemplate, showTotals, setTotalsTemplate, setRowAttributes, setValueCellAttributes

@docs setRowHeaderAttributes, stickyHeading


# Templates

@docs valueDefaultTemplate


# Debugging

@docs viewStructure


# Example

    import PivotView.ViewFiori as Pivot

    view : State -> Html Msg
    view state =
        Pivot.view (config state) viewConfig state.data

    config : State -> P.Config SalesItem
    config state =
        P.newConfig [ .grouping1 ] [ .colGrouping ] .value

    viewConfig : P.ViewConfig Msg
    viewConfig =
        P.defaultViewConfig

-}

import Dict
import Html exposing (Attribute, Html, div, h2, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, colspan, rowspan, style)
import Internal.PivotMatrix as Internal exposing (Cell(..), getContent, getRowCount, isFirstRow)
import Internal.PivotTypes as Internal exposing (GroupType(..), HGroup(..), countLessOne)
import Internal.PivotView as Internal



--# Config


{-| configure the pivot view layout.

  - groupRows : List (a -> String)
  - groupColumns : List (a -> String)
  - values : a -> Float

-}
type alias Config a =
    Internal.Config a


{-| ViewConfig

The view config is specific to the view and can be customized for your style sheets or needs.

-}
type alias ViewConfig msg =
    { showTotals : Bool
    , stickyHeading : Bool
    , rowHeaderTemplate : String -> Html msg
    , columnHeaderTemplate : String -> Html msg
    , valueTemplate : Float -> Html msg
    , totalsTemplate : Float -> Html msg
    , rowAttributes : List (Attribute msg)
    , rowHeaderAttributes : String -> List (Attribute msg)
    , valueCellAttributes : Float -> List (Attribute msg)
    }


{-| Matrix

The matrix contains all the rendered data required to generate the view. The matrix type is seperated to allow for prerendering in the update function.

-}
type alias Matrix a =
    { config : Config a
    , columns : List (List String)
    , totals : HGroup
    , body : List (List Cell)
    }


{-| emptyMatrix
-}
emptyMatrix : Matrix a
emptyMatrix =
    { config = newConfig [] [] (always 0)
    , columns = []
    , totals = HGValue 0
    , body = []
    }


{-| newConfig
-}
newConfig : List (a -> String) -> List (a -> String) -> (a -> Float) -> Config a
newConfig groupRows groupColumns values =
    { groupRows = groupRows
    , groupColumns = groupColumns
    , values = values
    }


{-| defaultViewConfig
-}
defaultViewConfig : ViewConfig msg
defaultViewConfig =
    { showTotals = False
    , stickyHeading = False
    , rowHeaderTemplate = rowHeaderDefaultTemplate
    , columnHeaderTemplate = columnHeaderDefaultTemplate
    , valueTemplate = valueDefaultTemplate
    , totalsTemplate = valueDefaultTemplate
    , rowAttributes = defaultRowAttributes
    , rowHeaderAttributes = defaultRowHeaderAttributes
    , valueCellAttributes = defaultValueCellAttributes
    }


{-| buildDataView
-}
buildDataView : Config a -> List a -> Matrix a
buildDataView config data =
    let
        dataView =
            Internal.buildDataView config data
    in
    { config = config
    , columns = dataView.columnList
    , totals = dataView.totals
    , body = Internal.buildMatrix dataView dataView.hgroup
    }


{-| defaultRowAttributes
-}
defaultRowAttributes : List (Attribute msg)
defaultRowAttributes =
    []


{-| defaultRowHeaderAttributes \_
-}
defaultRowHeaderAttributes : String -> List (Attribute msg)
defaultRowHeaderAttributes _ =
    []


{-| defaultValueCellAttributes \_
-}
defaultValueCellAttributes : Float -> List (Attribute msg)
defaultValueCellAttributes _ =
    [ csCellValue ]


{-| setRowHeaderTemplate val1 config
-}
setRowHeaderTemplate : (String -> Html msg) -> ViewConfig msg -> ViewConfig msg
setRowHeaderTemplate val1 config =
    { config | rowHeaderTemplate = val1 }


{-| setColumnHeaderTemplate val1 config
-}
setColumnHeaderTemplate : (String -> Html msg) -> ViewConfig msg -> ViewConfig msg
setColumnHeaderTemplate val1 config =
    { config | columnHeaderTemplate = val1 }


{-| setValueTemplate val1 config
-}
setValueTemplate : (Float -> Html msg) -> ViewConfig msg -> ViewConfig msg
setValueTemplate val1 config =
    { config | valueTemplate = val1 }


{-| setTotalsTemplate val1 config
-}
setTotalsTemplate : (Float -> Html msg) -> ViewConfig msg -> ViewConfig msg
setTotalsTemplate val1 config =
    { config | totalsTemplate = val1 }


{-| showTotals val1 config
-}
showTotals : Bool -> ViewConfig msg -> ViewConfig msg
showTotals val1 config =
    { config | showTotals = val1 }


{-| stickyHeading val1 config
-}
stickyHeading : Bool -> ViewConfig msg -> ViewConfig msg
stickyHeading val1 config =
    { config | stickyHeading = val1 }


{-| setRowAttributes val1 config
-}
setRowAttributes : List (Attribute msg) -> ViewConfig msg -> ViewConfig msg
setRowAttributes val1 config =
    { config | rowAttributes = val1 }


{-| setRowHeaderAttributes val1 config
-}
setRowHeaderAttributes : (String -> List (Attribute msg)) -> ViewConfig msg -> ViewConfig msg
setRowHeaderAttributes val1 config =
    { config | rowHeaderAttributes = val1 }


{-| setValueCellAttributes val1 config
-}
setValueCellAttributes : (Float -> List (Attribute msg)) -> ViewConfig msg -> ViewConfig msg
setValueCellAttributes val1 config =
    { config | valueCellAttributes = val1 }



--# View


{-| render a pivot table from a list of records according to the config
{-| view config viewConfig data -}
-}
view : Config a -> ViewConfig msg -> List a -> Html msg
view config viewConfig data =
    render viewConfig (buildDataView config data)


{-| render viewConfig matrix
-}
render : ViewConfig msg -> Matrix a -> Html msg
render viewConfig matrix =
    let
        countGroupRows =
            countLessOne matrix.config.groupRows

        headerAttr =
            if viewConfig.stickyHeading then
                [ csCellColumnHeaderSticky1 ]

            else
                []
    in
    table [ csTable ]
        [ thead [ csTableHeader ]
            (if viewConfig.showTotals then
                [ renderColumnHeader headerAttr countGroupRows matrix.columns
                , renderTotals countGroupRows viewConfig matrix.columns matrix.totals
                ]

             else
                [ renderColumnHeader headerAttr countGroupRows matrix.columns ]
            )
        , renderBody viewConfig matrix.body
        ]


{-| rowHeaderDefaultTemplate val1
-}
rowHeaderDefaultTemplate : String -> Html msg
rowHeaderDefaultTemplate val1 =
    text val1


{-| columnHeaderDefaultTemplate val1
-}
columnHeaderDefaultTemplate : String -> Html msg
columnHeaderDefaultTemplate val1 =
    text val1


{-| valueDefaultTemplate val1
-}
valueDefaultTemplate : Float -> Html msg
valueDefaultTemplate val1 =
    text (String.fromFloat val1)



--# Helper Functions


{-| renderColumnHeader attr countGroupRows columnList
-}
renderColumnHeader : List (Attribute msg) -> Int -> List (List String) -> Html msg
renderColumnHeader attr countGroupRows columnList =
    let
        list1 =
            List.repeat countGroupRows ""

        list2 =
            List.map
                (\key ->
                    String.concat key
                )
                columnList
    in
    tr (csRow :: attr)
        (List.append list1 list2 |> List.map (\caption -> th [ csCellColumnHeader ] [ text caption ]))


{-| renderTotals countGroupRows viewConfig columnList totals
-}
renderTotals : Int -> ViewConfig msg -> List (List String) -> HGroup -> Html msg
renderTotals countGroupRows viewConfig columnList totals =
    List.filterMap
        (\path ->
            Maybe.map (\total -> td [ csCellTotal ] [ viewConfig.totalsTemplate total ]) (Internal.getHValue path totals)
        )
        columnList
        |> (::) (td [ colspan (countGroupRows + 1), csCellTotalHeading ] [ text "Totals" ])
        |> tr [ csRow ]


{-| renderBody config matrix
-}
renderBody : ViewConfig msg -> List (List Cell) -> Html msg
renderBody config matrix =
    tbody [ csBody ]
        (List.map (renderRow config) matrix)



--# Parts


{-| renderCell config cell1
-}
renderCell : ViewConfig msg -> Cell -> Html msg
renderCell config cell1 =
    let
        tdAttr =
            if getRowCount cell1 > 1 then
                [ rowspan (getRowCount cell1) ]

            else
                []
    in
    case cell1 of
        CellRow header1 ->
            td (config.rowHeaderAttributes header1.content ++ tdAttr) [ config.rowHeaderTemplate (getContent cell1) ]

        CellValue val1 ->
            td (config.valueCellAttributes val1) [ config.valueTemplate val1 ]


{-| renderRow config row1
-}
renderRow : ViewConfig msg -> List Cell -> Html msg
renderRow config row1 =
    tr config.rowAttributes (List.filter isFirstRow row1 |> List.map (renderCell config))



-- Debug views


{-| viewStructure config data
-}
viewStructure : Config a -> List a -> Html msg
viewStructure config data =
    let
        dataView =
            Internal.buildDataView config data
    in
    div []
        [ h2 [] [ text "Column Hierarchy" ]
        , div [] (viewPivotHGroup dataView.columnH)
        , h2 [] [ text "Data Hierarchy" ]
        , div [] (viewPivotHGroup dataView.hgroup)
        ]


{-| viewPivotHGroup data
-}
viewPivotHGroup : HGroup -> List (Html msg)
viewPivotHGroup data =
    case data of
        HGIndex index ->
            div [] [ text (indexType index) ]
                :: (Dict.map
                        (\key val ->
                            div []
                                [ div [] [ text key ]
                                , div [ style "margin-top" "2px", style "margin-left" "1em" ] (viewPivotHGroup val)
                                ]
                        )
                        index.data
                        |> Dict.values
                   )

        HGValue val ->
            [ div [] [ text ("Value: " ++ String.fromFloat val) ] ]


{-| indexType ix
-}
indexType : { m | indexType : GroupType } -> String
indexType ix =
    case ix.indexType of
        GroupColumns ->
            "GroupColumns"

        GroupRows ->
            "GroupRows"

        GroupValues ->
            "GroupValues"



--# Styles


{-| csTable
-}
csTable : Attribute msg
csTable =
    class "table"


{-| csTableHeader
-}
csTableHeader : Attribute msg
csTableHeader =
    class ""


{-| csRow
-}
csRow : Attribute msg
csRow =
    class ""


{-| csCellColumnHeader
-}
csCellColumnHeader : Attribute msg
csCellColumnHeader =
    class "ui-pivot--column-heading"


{-| csCellColumnHeaderSticky1
-}
csCellColumnHeaderSticky1 : Attribute msg
csCellColumnHeaderSticky1 =
    class "ui-pivot--column-heading--sticky"


{-| csCellValue
-}
csCellValue : Attribute msg
csCellValue =
    class "ui-pivot--cell"


{-| csCellTotal
-}
csCellTotal : Attribute msg
csCellTotal =
    class "ui-pivot-totals"


{-| csCellTotalHeading
-}
csCellTotalHeading : Attribute msg
csCellTotalHeading =
    class "ui-pivot-totals_heading"


{-| csBody
-}
csBody : Attribute msg
csBody =
    class ""
