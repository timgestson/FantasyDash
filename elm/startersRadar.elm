module StartersRadar where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Player exposing (..)
import Signal exposing (Signal, Address)
import Chart exposing (..)
import Color exposing (..)

chartData model = 
    let color = toRgba red
        data = getStarters (toRoster model.players)
    in
        { command = "Render"
        , selector = "roster"
        , chart = 
            Just ({ chartType = "Radar" 
            , options = 
                  { legendTemplate = Nothing }
            , labels = 
                ["QB","RB1", "RB2", "WR1", 
                "WR2", "RB/WR", "TE","K", "Def" ]
            , datasets = 
                [ { label = "Roster"
                  , fillColor = color 0.1
                  , pointColor = color 1
                  , pointStrokeColor = color 1
                  , pointHighlightColor = color 0.6
                  , pointHighlightStrokeColor = color 0.6
                  , data = data
                } ]    
            })
        }
   
getStarters : Roster -> List Float
getStarters roster =
    let 
        pointsOrZero list = case List.head list of
            Just player -> player.projPoints
            _-> 0
        qb = pointsOrZero roster.qbs
        rb1 = pointsOrZero roster.rbs
        rb2 = pointsOrZero (List.drop 1 roster.rbs)
        rb3 = pointsOrZero (List.drop 2 roster.rbs)
        wr1 = pointsOrZero roster.wrs
        wr2 = pointsOrZero (List.drop 1 roster.wrs)
        wr3 = pointsOrZero (List.drop 2 roster.wrs)
        te = pointsOrZero roster.tes
        k = pointsOrZero roster.ks
        def = pointsOrZero roster.defs
        flex = Basics.max rb3 wr3
    in
       [qb, rb1, rb2, wr1, wr2, flex, te, k, def]

view address model = 
    Chart.view "Starting Roster" "roster"

