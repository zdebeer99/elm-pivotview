module Main exposing (..)

import Browser
import Types exposing (Model, Msg(..), Taco)
import Update
import View



--# app skeleton


main : Program () Model Msg
main =
    Browser.sandbox { init = mockup, view = View.view, update = Update.update }


mockup : List Taco
mockup =
    [ { name = "PA01"
      , cat1 = "superlink"
      , make = "volvo"
      , period = "2020-01-01"
      , km = 1340
      , overtime = 3
      }
    , { name = "PA02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-01-01"
      , km = 1091
      , overtime = 6
      }
    , { name = "PA03"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-01-01"
      , km = 1838
      , overtime = 1
      }
    , { name = "NHT01"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-01-01"
      , km = 1890
      , overtime = 0
      }
    , { name = "NHT02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-01-01"
      , km = 359
      , overtime = 5
      }
    , { name = "NHT03"
      , cat1 = "hyper loader"
      , make = "scuderia"
      , period = "2020-01-01"
      , km = 1843
      , overtime = 6
      }
    , { name = "PA01"
      , cat1 = "superlink"
      , make = "volvo"
      , period = "2020-02-01"
      , km = 657
      , overtime = 5
      }
    , { name = "PA02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-02-01"
      , km = 227
      , overtime = 0
      }
    , { name = "PA03"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-02-01"
      , km = 1635
      , overtime = 7
      }
    , { name = "NHT01"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-02-01"
      , km = 1521
      , overtime = 2
      }
    , { name = "NHT02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-02-01"
      , km = 346
      , overtime = 6
      }
    , { name = "NHT03"
      , cat1 = "hyper loader"
      , make = "scuderia"
      , period = "2020-02-01"
      , km = 2000
      , overtime = 5
      }
    , { name = "PA01"
      , cat1 = "superlink"
      , make = "volvo"
      , period = "2020-03-01"
      , km = 1936
      , overtime = 3
      }
    , { name = "PA02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-03-01"
      , km = 1523
      , overtime = 0
      }
    , { name = "PA03"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-03-01"
      , km = 859
      , overtime = 1
      }
    , { name = "NHT01"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-03-01"
      , km = 501
      , overtime = 1
      }
    , { name = "NHT02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-03-01"
      , km = 1437
      , overtime = 6
      }
    , { name = "NHT03"
      , cat1 = "hyper loader"
      , make = "scuderia"
      , period = "2020-03-01"
      , km = 1968
      , overtime = 1
      }
    , { name = "PA01"
      , cat1 = "superlink"
      , make = "volvo"
      , period = "2020-04-01"
      , km = 1286
      , overtime = 7
      }
    , { name = "PA02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-04-01"
      , km = 1111
      , overtime = 2
      }
    , { name = "PA03"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-04-01"
      , km = 1915
      , overtime = 0
      }
    , { name = "NHT01"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-04-01"
      , km = 402
      , overtime = 1
      }
    , { name = "NHT02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-04-01"
      , km = 174
      , overtime = 1
      }
    , { name = "NHT03"
      , cat1 = "hyper loader"
      , make = "scuderia"
      , period = "2020-04-01"
      , km = 1998
      , overtime = 5
      }
    , { name = "PA01"
      , cat1 = "superlink"
      , make = "volvo"
      , period = "2020-05-01"
      , km = 1579
      , overtime = 5
      }
    , { name = "PA02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-05-01"
      , km = 1004
      , overtime = 2
      }
    , { name = "PA03"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-05-01"
      , km = 310
      , overtime = 5
      }
    , { name = "NHT01"
      , cat1 = "superlink"
      , make = "man"
      , period = "2020-05-01"
      , km = 1849
      , overtime = 0
      }
    , { name = "NHT02"
      , cat1 = "8 tonner"
      , make = "volvo"
      , period = "2020-05-01"
      , km = 641
      , overtime = 6
      }
    , { name = "NHT03"
      , cat1 = "hyper loader"
      , make = "scuderia"
      , period = "2020-05-01"
      , km = 1379
      , overtime = 1
      }
    ]
