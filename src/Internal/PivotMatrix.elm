module Internal.PivotMatrix exposing
    ( Cell(..)
    , buildColumnList
    , buildMatrix
    , countRows
    , getContent
    , getHValue
    , getRowCount
    , getValue
    , isFirstRow
    )

{- Converts a pivot data view to an array of array to make it easier for the
   drawing algo to draw the pivot.
-}

import Dict
import Internal.Ops exposing (pushItem)
import Internal.PivotTypes
    exposing
        ( DataView
        , GroupType(..)
        , HGroup(..)
        , countLessOne
        , isColumn
        )
import Tuple


{-| Cell represents a cell on a table
-}
type Cell
    = CellValue Float
    | CellRow RowHeader


type alias RowHeader =
    { content : String
    , rowCount : Int
    , firstRow : Bool
    , ownerPos : Int
    }


isFirstRow : Cell -> Bool
isFirstRow cell1 =
    case cell1 of
        CellRow row1 ->
            row1.firstRow

        _ ->
            True


getRowCount : Cell -> Int
getRowCount cell1 =
    case cell1 of
        CellRow row1 ->
            row1.rowCount

        _ ->
            0


getContent : Cell -> String
getContent cell1 =
    case cell1 of
        CellRow row1 ->
            row1.content

        _ ->
            "#Val"


getValue : Cell -> Float
getValue cell1 =
    case cell1 of
        CellValue val1 ->
            val1

        _ ->
            0


rowHeader : Int -> Int -> String -> Cell
rowHeader ownerPos rowCount1 content1 =
    CellRow
        { content = content1
        , rowCount = rowCount1
        , firstRow = True
        , ownerPos = ownerPos
        }


buildMatrix : DataView -> HGroup -> List (List Cell)
buildMatrix dataView hGroup =
    rMatrix 0 dataView.columnList hGroup [ [] ] []
        |> List.filter (\list -> countLessOne list > 0)
        |> List.reverse


{-| Build a matrix of values to display in a table.

a recursive function that builds a matrix of the hierarchy data structure.

-}
rMatrix : Int -> List (List String) -> HGroup -> List (List Cell) -> List Cell -> List (List Cell)
rMatrix rowN columnList hGroup matrix row1 =
    if isColumn hGroup then
        -- Iterate all defined columns and get a value for that row, column combination
        List.filterMap (\keyL -> Maybe.map CellValue (getHValue keyL hGroup)) columnList
            |> List.append (List.reverse row1)
            |> pushItem matrix

    else
        -- Iterate rows and append row headers
        case hGroup of
            HGIndex index ->
                Dict.foldl
                    (\key childHGroup ( matrix2, cnt ) ->
                        ( appendHeaderRowCell cnt (countRows childHGroup) key row1
                            |> rMatrix cnt columnList childHGroup matrix2
                        , cnt + 1
                        )
                    )
                    ( matrix, rowN )
                    index.data
                    |> Tuple.first

            HGValue _ ->
                row1 :: matrix


{-| appendHeaderRowCell ownerPos rowCount keyValue row1 =

This function appends the row header cell to the table row.

-}
appendHeaderRowCell : Int -> Int -> String -> List Cell -> List Cell
appendHeaderRowCell ownerPos rowCount keyValue row1 =
    let
        cell1 =
            rowHeader ownerPos rowCount keyValue

        --hide extra cells for row span.
        row2 =
            List.map
                (\cellValue1 ->
                    case cellValue1 of
                        CellRow headerCell ->
                            -- if the cell does not belong on this row, hide it. firstRow = false.
                            CellRow { headerCell | firstRow = headerCell.ownerPos == ownerPos }

                        _ ->
                            cellValue1
                )
                row1
    in
    cell1 :: row2


countRows : HGroup -> Int
countRows hGroup =
    if isColumn hGroup then
        1

    else
        case hGroup of
            HGIndex index ->
                Dict.foldl
                    (\_ childHGroup total ->
                        countRows childHGroup + total
                    )
                    0
                    index.data

            HGValue _ ->
                1


{-| get the value in a group from a list of keys
-}
getHValue : List String -> HGroup -> Maybe Float
getHValue keyList hgroup =
    case hgroup of
        HGIndex index ->
            case keyList of
                key :: tail ->
                    case Dict.get key index.data of
                        Just value1 ->
                            case value1 of
                                HGIndex _ ->
                                    getHValue tail value1

                                HGValue val ->
                                    Just val

                        _ ->
                            Just 0

                _ ->
                    Nothing

        HGValue val ->
            Just val


{-| create a list of column key for ordering and placing values in the matrix.
-}
buildColumnList : DataView -> HGroup -> List (List String)
buildColumnList dataView hGroup =
    buildColumnListIter dataView hGroup [] [ [] ]
        |> List.reverse


{-| recursive function of buildColumnList
-}
buildColumnListIter : DataView -> HGroup -> List String -> List (List String) -> List (List String)
buildColumnListIter dataView hGroup list matrix =
    case hGroup of
        HGIndex index ->
            Dict.foldl
                (\key value1 matrix2 ->
                    buildColumnListIter dataView value1 (key :: list) matrix2
                )
                matrix
                index.data

        HGValue _ ->
            list :: matrix
