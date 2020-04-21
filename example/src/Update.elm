module Update exposing (update)

import Types exposing (Model, Msg(..), Taco)


update : Msg -> Model -> Model
update msg model =
    model
