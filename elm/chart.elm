module Chart where
import Signal exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Color exposing (..)

type alias ChartCommand = 
    { command : String
    , selector : String
    , chart : Maybe Chart
    }


maybeMapper value = Just value

type alias ChartOptions =
    { legendTemplate : Maybe String } 

type alias Chart =
    { chartType : String
    , options : ChartOptions
    , labels : List String
    , datasets : List (DataSet1)
    , extras: Maybe Extra
    }

type alias Extra =
    { line: Int 
    , names: List String
    }


type alias DataSet1 = 
    { label : String 
    , fillColor : String
    , pointColor : String
    , pointStrokeColor : String
    , pointHighlightFill : String
    , pointHighlightStroke : String
    , data : List (Maybe Float)
    }



type alias Overview = 
    { label : String 
    , fillColor : String
    , pointColor : String
    , pointStrokeColor : String
    , pointHighlightFill : String
    , pointHighlightStroke : String
    , data : List (Maybe Float)
    , names : List (Maybe String)
    }

type alias DataSet2 = 
    { label : String 
    , color : String
    , highlight : String
    , value : Float
    }

type Action 
    = NoOp
    | Render String Chart
    | Clear String

update : Action -> (Maybe ChartCommand)
update action =
    case action of
        Render selector chart ->
           Just { command = "Render"
            , selector = selector
            , chart = Just chart
            }
        Clear selector ->
            Just { command = "Clear"
            , selector = selector
            , chart = Nothing
            }
        NoOp ->
            Nothing

view : String -> String ->  Html
view title name = 
    div [ class "col-lg-4 well shadow-z-2" 
        , style [("margin-left", "15px")
                , ("width", "30%")]
        ]
        [ h3 [style [("text-align", "center")]] [ text title ]
        , div [class "canvas-wrapper"]
            [ canvas [id name] []]
        ]

viewLarge : String -> String -> Html
viewLarge title name = 
    div [ class "col-lg-9 well shadow-z-2"
        , style [("margin-left", "15px")
                , ("width", "93%")]
        ]
        [ h3 [style [("text-align", "center")]] [ text title ]
        , div [class "canvas-wrapper"
               , style [("height", "300px")]  ]
            [ canvas 
                [id name] []
            ]
        ]


toRgba : Color -> Float -> String
toRgba color alpha =
    let rgb = toRgb color
    in "rgba(" ++ (toString rgb.red) ++ "," ++ (toString rgb.green) 
       ++ "," ++ (toString rgb.blue) ++ "," ++ (toString alpha) ++ ")"

chartMailbox : Signal.Mailbox Action
chartMailbox = Signal.mailbox NoOp
