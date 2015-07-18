module Overview where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Player exposing (..)
import Signal exposing (Signal, Address)
import Chart exposing (..)
import Color exposing (..)

getColorByPosition position = 
    case position of
        "QB" -> red
        "RB" -> blue
        "WR" -> green
        "TE" -> yellow
        "K" -> lightGrey
        "Def" -> grey

createData : List Player -> String -> DataSet1
createData items position =
    let 
        baseColor = toRgba (getColorByPosition position)
        fillColor = baseColor 0.1
        otherColor = baseColor 1
        data = getDataPerPosition position items
    in
         { label = position
          , fillColor = fillColor
          , pointColor = otherColor
          , pointStrokeColor = "#fff"
          , pointHighlightFill = otherColor
          , pointHighlightStroke = otherColor
          , data = data
          }     

chartData model = 
    let allitems = draftOrderSort model.players
        start = if model.draftPosition < 30 then
                    0
                else
                    model.draftPosition - 30
        items = List.take 60 (List.drop start allitems)
        names = List.map .name allitems
        positions = ["QB","RB","WR","TE","K","Def"]
        labels =  
            (List.map fst (List.indexedMap (,) items))
            |> List.map ((+) 1)
            |> List.map ((+) start)
            |> List.map toString
    in
        { command = "Render"
        , selector = "overview"
        , chart = 
            Just ({ chartType = "Overview" 
            , options = 
                  { legendTemplate = Nothing }
            , labels = 
                labels
            , datasets = 
                List.map (createData items) positions
            , extras = Just {
                line = model.draftPosition - start
                , names = names
                }
            })
        }
   
view address model = 
    Chart.viewLarge "Draft Overview" "overview"

