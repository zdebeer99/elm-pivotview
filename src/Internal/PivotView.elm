module Internal.PivotView exposing (buildDataView)

{-| Group and calculates values for display in a pivot.
-}

import Internal.PivotMatrix exposing (..)
import Internal.PivotTypes exposing (..)


buildDataView : Config a -> List a -> DataView
buildDataView config data =
    let
        dataView =
            newDataView

        -- keyMapList - define how the values should be gathered for each column.
        keyMapList =
            List.concat
                [ List.map (keyMapMeta GroupRows) config.groupRows
                , List.map (keyMapMeta GroupColumns) config.groupColumns
                ]
    in
    List.foldl (addItem config keyMapList) dataView data
        |> (\dv -> { dv | columnList = buildColumnList dv dv.columnH })


{-| add a item to the dataview
-}
addItem : Config a -> List (KeyMap a) -> a -> DataView -> DataView
addItem config keyMapList item dataView =
    genHGroup config keyMapList [] dataView item


{-| Recursively loop trough a key map list and build a hierarchy of keys for a item.
-}
genHGroup : Config a -> List (KeyMap a) -> List String -> DataView -> a -> DataView
genHGroup config keyMapList path dataView item =
    case keyMapList of
        keymap :: keyMapTail ->
            let
                -- get group by key
                key =
                    keymap.map item

                -- initialize hgroup for storing key
                ( hgroup, hgroup_ ) =
                    hgMergeGet keymap.keyType key dataView.hgroup

                -- initialize columnH for storing column key
                ( columnH, columnH_ ) =
                    if keymap.keyType == GroupColumns then
                        hgMergeGet GroupColumns key dataView.columnH

                    else
                        ( dataView.columnH, dataView.columnH )

                -- recursively get next key
                dataView2 =
                    genHGroup config
                        keyMapTail
                        (if isColumn hgroup then
                            key :: path

                         else
                            path
                        )
                        { dataView | hgroup = hgroup_, columnH = columnH_ }
                        item

                -- update hgroup index with new key structure
                hgroup4 =
                    hgInsert keymap.keyType key dataView2.hgroup hgroup

                -- update columnH index with new key structure
                columnH2 =
                    if keymap.keyType == GroupColumns then
                        hgInsert GroupColumns key dataView2.columnH columnH

                    else
                        dataView2.columnH
            in
            { dataView | hgroup = hgroup4, columnH = columnH2, totals = dataView2.totals }

        _ ->
            let
                val1 =
                    config.values item

                -- add value to hgroup and sum if value already exists
                agr =
                    hgAdd (HGValue val1) dataView.hgroup

                -- update the dataView.totals field
                totals =
                    hgAddTotal path dataView.totals val1
            in
            { dataView | hgroup = agr, columnH = hgEmpty, totals = totals }
