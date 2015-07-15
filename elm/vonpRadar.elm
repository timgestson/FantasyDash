module VonpRadar where
--Value Over Next Player

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Player exposing (..)
import Signal exposing (Signal, Address)
import Chart exposing (..)
import Color exposing (..)

createData data =
    let 
        baseColor = toRgba green
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
    let (qb, qbpoints) = valueOverNextPlayer "QB" model.players
        (rb, rbpoints) = valueOverNextPlayer "RB" model.players
        (wr, wrpoints) = valueOverNextPlayer "WR" model.players
        (te, tepoints) = valueOverNextPlayer "TE" model.players
    in
        { command = "Render"
        , selector = "vonpRadar"
        , chart = 
            Just ({ chartType = "Radar" 
            , options = 
                  { legendTemplate = Nothing }
            , labels = 
                [qb,rb,wr,te]
            , datasets = 
                [(createData [qbpoints,rbpoints,wrpoints,tepoints])]   
            })
        }
   
view address model = 
    Chart.view "Value Over Next Avail." "vonpRadar"

