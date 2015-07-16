module Sidebar where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Player exposing (..)
import Signal exposing (Signal, Address)

type alias Model = 
    { sort : Maybe String
    , filter : Maybe String
    , status : Maybe String 
    }

emptyModel : Model
emptyModel = 
    { sort = Nothing
    , filter = Nothing
    , status = Nothing
    }

type Action
    = NoOp
    | Draft Bool String
    | Undraft String
    | Favorite String
    | Unfavorite String
    | Status (Maybe String)
    | Select Player
    | Sort String
    | Filter String

update action model = 
    case action of
        NoOp -> model    
        Sort sort -> updateSort sort model
        Filter filter -> updateFilter filter model
        Draft bool id -> draft bool id model  
        Undraft id -> undraft id model
        Favorite id -> favorite id model
        Unfavorite id -> unfavorite id model
        Status string -> statusFilter string model

statusFilter status model =
    let side = model.sidebar
    in { model | sidebar <- { side | status <- status } }

favorite id model =
    { model | players <- (changeFavorite id True model.players) }

unfavorite id model =
    { model | players <- (changeFavorite id False model.players) }

draft mine id model =
    let status = 
        case mine of
            True -> "Mine"
            False -> "Thiers"
    in { model | players <- (changeStatus status (Just model.draftPosition)
                                id model.players)
               , draftPosition <- model.draftPosition + 1 }

undraft id model =
    { model | players <- (changeStatus "Available" Nothing 
                            id model.players) 
            , draftPosition <- model.draftPosition - 1 }

updateSort sortString model = 
    let side = model.sidebar
    in { model | sidebar <- { side | sort <- Just sortString } }

updateFilter filterString model = 
    let side = model.sidebar
    in { model | sidebar <- { side | filter <- Just filterString } }

view address model = 
    table [ class "table table-striped table-hover" ]
       ((playerHeader address) :: [(playerTableBody model address)])
    
playerHeader address =    
    thead []
        [ tr [] 
            [ th [] [ menu address ]
            , th [] [ text "Name" ] 
            , th [] [ (sortHeader "Adp" "adp" address) ]
            , th [] [ (sortHeader "Projected" "projPoints" address) ]
            , th [] [ filterDropdown address ]
            ]
        ]

menu address =
    div [ class "btn-group"
        , style [("margin", "0")]
        ]
        [ a [ class "btn btn-default btn-xs dropdown-toggle"
            , attribute "data-target" "#"
            , attribute "data-toggle" "dropdown"
            , attribute "aria-expanded" "false"
            , style [ ("padding", "0 5px 0 5px") ]
            ] 
            [ span [ class "mdi-image-dehaze" ] []
            , div  [ class "ripple-wrapper" ] []
            ]
        , ul [ class "dropdown-menu" ]
             [ li [] 
                [ statusChange "All" Nothing address ]
             , li [] 
                [ statusChange "Available" (Just "Available") address ]
             , li [] 
                [ statusChange "My Team" (Just "Mine") address ]
             ]
        ]

statusChange label status address =
    a [ onClick address (Status status) 
      , style [("cursor", "pointer")]] 
      [ text label ]

sortHeader heading sorter address =
    a [ onClick address (Sort sorter)  
      , style [("cursor", "pointer")]] 
      [ text heading ]

playerTableBody model address = 
    tbody [] (playerViewList model address)

playerViewList model address =
    let mapper player = playerItem player address 
    in List.map mapper
        ( model.players
        |>  (flip sortPlayers) (Maybe.withDefault "adp" model.sidebar.sort)
        |>  (flip filterPlayers) 
            (Maybe.withDefault "all" model.sidebar.filter)
        |> (flip filterStatus) model.sidebar.status
        )

filterStatus : List Player -> Maybe String -> List Player
filterStatus players status =
    case status of
        Nothing -> players
        Just stat -> filterByStatus players stat

filterPlayers : List Player -> String -> List Player
filterPlayers players filter =
    case filter of
        "all" -> players
        position -> filterPos players position

playerItem player address = 
     tr [ class (getPlayerPositionClass player) ] 
        [ td [centered] [ favoritePlayer player ]
        , td [] [ text player.name ]
        , td [centered] [ text (toString player.adp) ]
        , td [centered] [ text (toString player.projPoints) ]
        , td [] [ actionDropdown player address ]
        ]

favoritePlayer : Player -> Html
favoritePlayer player =
    case player.favorited of
        True -> span [class "mdi-action-grade"] []
        False -> span [] []

centered : Attribute
centered = style [("text-align", "center")]

actionDropdown player address =
    div [ class "btn-group"
        , style [("margin", "0")]
        ]
        [ a [ class "btn btn-default btn-xs dropdown-toggle"
            , attribute "data-target" "#"
            , attribute "data-toggle" "dropdown"
            , attribute "aria-expanded" "false"
            ] 
            [ span [ class "caret" ] []
            , div  [ class "ripple-wrapper" ] []
            ]
        , ul [ class "dropdown-menu" ]
            ((li [] [ favoriteLink player address]) ::
             draftLink player address)
        ]

draftLink player address =
    case player.status of
        "Available" ->
             [ li [] 
                [ draftPlayer True player.id address  "Draft (My Squad)" ]
             , li []
                [ draftPlayer False player.id address  
                    "Draft (Other Squad)" ]
             ]
        _ ->
            [ li []
                [ undraftPlayer player.id address ]
            ]

favoriteLink player address =
    let signal = case player.favorited of
            False -> Favorite player.id
            True -> Unfavorite player.id
        label = case player.favorited of
            False -> "Favorite"
            True -> "Unfavorite"
    in
        a [ onClick address signal 
          , style [("cursor", "pointer")]] 
          [ text label ] 

draftPlayer bool id address label =
    a [ onClick address (Draft bool id) 
      , style [("cursor", "pointer")]] 
      [ text label ] 

undraftPlayer id address =
    a [ onClick address (Undraft id) 
      , style [("cursor", "pointer")]] 
      [ text "Undraft" ] 

filterDropdown address =
    div [ class "btn-group"
        , style [("margin", "0")]
        ]
        [ a [ class "btn btn-default btn-xs dropdown-toggle"
            , attribute "data-target" "#"
            , attribute "data-toggle" "dropdown"
            , attribute "aria-expanded" "false"
            ] 
            [ span [ class "caret" ] []
            , div  [ class "ripple-wrapper" ] []
            ]
        , ul [ class "dropdown-menu" ]
             [ li [] 
                [ (filterSidebar address "All" "all") ]
             , li []
                [ (filterSidebar address "QB" "QB") ]
             , li [] 
                [ (filterSidebar address "RB" "RB") ]
             , li [] 
                [ (filterSidebar address "WR" "WR") ]
             , li [] 
                [ (filterSidebar address "TE" "TE") ]
             , li [] 
                [ (filterSidebar address "K" "K") ]
             , li [] 
                [ (filterSidebar address "Def" "Def") ]
             ]
        ]

filterSidebar address label filter =
    a [ onClick address (Filter filter)
      , style [("cursor", "pointer")]] 
      [ text label ]

getPlayerPositionClass : Player -> String
getPlayerPositionClass player =
    case player.position of
        "QB" -> "danger"
        "RB" -> "info"
        "WR" -> "success"
        "TE" -> "warning"
        _ -> ""
        

