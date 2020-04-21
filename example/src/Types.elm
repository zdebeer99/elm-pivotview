module Types exposing (Model, Msg(..), Taco)


type Msg
    = Msg


type alias Model =
    List Taco


type alias Taco =
    { name : String
    , cat1 : String
    , make : String
    , period : String
    , km : Int
    , overtime : Int
    }
