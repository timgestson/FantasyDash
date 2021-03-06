module DraftDash where

import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing(..)
import Task exposing (..)
import Player exposing (..)
import Signal exposing (..)
import Sidebar exposing (..)
import Maybe exposing (..)
import Chart exposing (..)
import StartersRadar exposing (..)
import VorpRadar exposing (..)
import VonpRadar exposing (..)
import Overview exposing (..)

type alias Model = 
    { players: List Player
    , sidebar: Sidebar.Model
    , draftPosition: Int
    }

emptyModel : Model
emptyModel = 
    { players = []
    , sidebar = Sidebar.emptyModel
    , draftPosition = 1
    }

actions : Signal.Mailbox Action
actions =
      Signal.mailbox NoOp

type Action 
    = NoOp
    | SidebarAction Sidebar.Action
    | RenderChart String Chart

update action model =
    case action of
        NoOp -> model
        SidebarAction sideAction ->
            Sidebar.update sideAction model
        _-> model

view address model =
    div [] 
        [ nav [ class "header-panel shadow-z-2" ] []
        , div [ class "container-fluid main"][ 
            div [ class "row" ]
                [ nav [ class "col-xs-3 menu"]
                    [ Sidebar.view 
                    (Signal.forwardTo address SidebarAction) 
                    model ] 
                , div [ class "col-xs-9 pages"
                      , margin  
                      ]
                  [ div [] 
                    [ (StartersRadar.view address model) 
                    , (VorpRadar.view address model) 
                    , (VonpRadar.view address model) ]
                  , div []
                    [ (Overview.view address model) ]
                  ]
                ]
            ]
        ]

margin : Attribute
margin = style [("margin-top", "10px")]

main : Signal Html
main = Signal.map (view actions.address) model

model : Signal Model
model =
    Signal.foldp update initialModel actions.signal

initialModel : Model
initialModel =  Maybe.withDefault emptyModel getState

dashboard : Model -> List ChartCommand
dashboard model =
    [ StartersRadar.chartData model
    , VorpRadar.chartData model
    , VonpRadar.chartData model
    , Overview.chartData model
    ]

port getState : Maybe Model

port renderChart : Signal (List ChartCommand)
port renderChart = Signal.map dashboard render

render = 
    Signal.merge
        (Signal.sampleOn startAppMailbox.signal model)
        model

port setState : Signal Model
port setState = model

startAppMailbox = Signal.mailbox ()

port startApp : Signal (Task error ())
port startApp = 
    Signal.constant (Signal.send startAppMailbox.address ())

