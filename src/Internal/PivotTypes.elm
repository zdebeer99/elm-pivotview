module Internal.PivotTypes exposing
    ( Config
    , DataView
    , GroupType(..)
    , HGroup(..)
    , Index
    , KeyMap
    , countLessOne
    , hgAdd
    , hgAddTotal
    , hgEmpty
    , hgInsert
    , hgMergeGet
    , indexGet
    , indexInsert
    , isColumn
    , keyMapMeta
    , newDataView
    , newIndex
    )

import Dict exposing (Dict)



--# Config


type alias Config a =
    { groupRows : List (a -> String)
    , groupColumns : List (a -> String)
    , values : a -> Float
    }


countLessOne : List a -> Int
countLessOne listToCount =
    List.length listToCount - 1



--# Dataview


type alias DataView =
    { columnH : HGroup -- column hierarchy
    , hgroup : HGroup -- value hierarchy
    , columnList : List (List String)
    , totals : HGroup
    }


newDataView : DataView
newDataView =
    { columnH = HGIndex (newIndex GroupColumns)
    , hgroup = hgEmpty
    , columnList = []
    , totals = hgEmpty
    }


type HGroup
    = HGIndex Index
    | HGValue Float


hgEmpty : HGroup
hgEmpty =
    HGValue 0


type GroupType
    = GroupColumns
    | GroupRows
    | GroupValues


{-| hierarchy structure, keeping column name as key
-}
type alias Index =
    { data : Dict String HGroup
    , indexType : GroupType
    }


isColumn : HGroup -> Bool
isColumn hGroup =
    case hGroup of
        HGIndex index ->
            index.indexType == GroupColumns

        HGValue _ ->
            False


type alias KeyMap a =
    { map : a -> String
    , keyType : GroupType
    }


keyMapMeta : GroupType -> (a -> String) -> KeyMap a
keyMapMeta keyType keyMap =
    { map = keyMap
    , keyType = keyType
    }


newIndex : GroupType -> Index
newIndex indexType =
    { data = Dict.empty, indexType = indexType }


indexInsert : String -> HGroup -> Index -> Index
indexInsert key hgroup index =
    { index | data = Dict.insert key hgroup index.data }


{-| returns the value of a key if hgroup is a index, else returns a empty value.
-}
indexGet : String -> HGroup -> HGroup
indexGet key hgroup =
    case hgroup of
        HGIndex index ->
            case Dict.get key index.data of
                Just value ->
                    value

                _ ->
                    hgEmpty

        HGValue _ ->
            hgroup


{-| inserts a key into the hgroup, if hgroup is not a index,
create one and replace hgroup with a index type.

the function returns two hgroups (hgroup1, hgroup2) where hgroup1 is the
updated parent hgroup and the second is the child group found.

-}
hgMergeGet : GroupType -> String -> HGroup -> ( HGroup, HGroup )
hgMergeGet groupType key hgroup =
    case hgroup of
        HGIndex index ->
            case indexGet key hgroup of
                HGIndex val ->
                    ( hgroup, HGIndex val )

                HGValue val ->
                    ( HGIndex (indexInsert key (HGValue val) index), HGValue val )

        HGValue val ->
            ( HGIndex (indexInsert key (HGValue val) (newIndex groupType)), HGValue val )


{-| Inserts a hgroup into a target hgroup and returns the updated target.
-}
hgInsert : GroupType -> String -> HGroup -> HGroup -> HGroup
hgInsert groupType key child target =
    case target of
        HGIndex index ->
            HGIndex (indexInsert key child index)

        HGValue _ ->
            HGIndex (indexInsert key child (newIndex groupType))


hgAdd : HGroup -> HGroup -> HGroup
hgAdd hGValue hGValue2 =
    case ( hGValue, hGValue2 ) of
        ( HGValue val1, HGValue val2 ) ->
            HGValue (val1 + val2)

        ( HGValue val1, _ ) ->
            HGValue val1

        ( _, HGValue val2 ) ->
            HGValue val2

        _ ->
            HGValue 0


hgAddTotal : List String -> HGroup -> Float -> HGroup
hgAddTotal valPath totals value =
    case valPath of
        key :: keyTail ->
            let
                ( group1, group2 ) =
                    hgMergeGet GroupColumns key totals

                group2_ =
                    hgAddTotal keyTail group2 value
            in
            hgInsert GroupColumns key group2_ group1

        _ ->
            hgAdd totals (HGValue value)
