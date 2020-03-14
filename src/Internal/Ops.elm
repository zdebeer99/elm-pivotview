module Internal.Ops exposing (pushItem)


pushItem : List a -> a -> List a
pushItem aList a =
    a :: aList
