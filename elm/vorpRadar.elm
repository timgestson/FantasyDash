module VorpRadar where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Player exposing (..)
import Signal exposing (Signal, Address)
import Chart exposing (..)
import Color exposing (..)

createData data =
    let 
        baseColor = toRgba blue
        fillColor = baseColor 0.1
        otherColor = baseColor 1
    in
         { label = ""
          , fillColor = fillColor
          , pointColor = otherColor
          , pointStrokeColor = otherColor
          , pointHighlightColor = otherColor
          , pointHighlightStrokeColor = otherColor
          , data = data
          }     

chartData model = 
    let qb = bestAvailable "QB" model.players
        rb = bestAvailable "RB" model.players
        wr = bestAvailable "WR" model.players
        te = bestAvailable "TE" model.players
        list = [qb, rb, wr, te]
        namesMaybe = List.map (Maybe.map .name) list
        names = List.map (Maybe.withDefault "") namesMaybe
        vorpMaybe = List.map (Maybe.map 
            ((flip valueOverReplacement) model.players)) list
        vorp = List.map (Maybe.withDefault 0) vorpMaybe
    in
        { command = "Render"
        , selector = "vorpRadar"
        , chart = 
            Just ({ chartType = "Radar" 
            , options = 
                  { legendTemplate = Nothing }
            , labels = 
                names
            , datasets = 
                [(createData vorp)]   
            })
        }
   
view address model = 
    Chart.view "Value Over Replacement" "vorpRadar"

