module Player where
import List exposing (..)


type alias Player =
    { id: String
    , adp: Int
    , name: String
    , projPoints: Float
    , position: String
    , byeWeek: Int
    , status: String
    , draftedAt: Maybe Int
    , favorited: Bool
    }

type alias Roster =
    { qbs: List Player
    , rbs: List Player
    , wrs: List Player
    , tes: List Player
    , ks: List Player
    , defs: List Player
    }

-- Sorting --

sortPlayers : List Player -> String -> List Player
sortPlayers players prop = 
    case prop of
        "adp" -> sortBy .adp players
        "projPoints" -> reverse (sortBy .projPoints players)
        _ -> players

getDataPerPosition : String -> List Player -> List (Maybe Float)
getDataPerPosition position players = 
        let
            mapper player = 
                if player.position  ==  position then
                   Just player.projPoints
                else
                    Nothing
        in
           List.map mapper players

getNamesPerPosition : String -> List Player -> List (Maybe String)
getNamesPerPosition position players =
        let
            mapper player = 
                if player.position  ==  position then
                   Just player.name
                else
                    Nothing
        in
           List.map mapper players

draftOrderSort : List Player -> List Player
draftOrderSort players = 
    let draftPart player =
        case Maybe.withDefault 0 player.draftedAt of
            0 -> False
            _ -> 
                True
        (drafted, undrafted) = List.partition draftPart players
        getDrafted player = Maybe.withDefault 0 player.draftedAt 
        orderedList = List.append (sortBy getDrafted drafted) 
            (sortBy .adp undrafted)
    in
        orderedList




-- Favorite --

changeFavorite : String -> Bool -> List Player -> List Player
changeFavorite id addOrRemove players = 
    let fav player = 
        case player.id == id of
            True -> { player | favorited <- addOrRemove }
            False -> player
    in List.map fav players

-- Roster --

changeStatus : String -> Maybe Int -> String -> List Player -> List Player
changeStatus newStatus draftedAt id players = 
    let change player = 
        case player.id == id of
            True -> { player 
                    | status <- newStatus 
                    , draftedAt <- draftedAt
                    }
            False -> player
    in List.map change players

toRoster : List Player -> Roster
toRoster players =
    let roster = getRoster players
    in  { qbs = filterPos roster "QB"
        , rbs = filterPos roster "RB"
        , wrs = filterPos roster "WR"
        , tes = filterPos roster "TE"
        , ks = filterPos roster "K"
        , defs = filterPos roster "Def"
        }

getRoster : List Player -> List Player
getRoster players = filterByStatus players "Mine"

filterByStatus : List Player -> String -> List Player
filterByStatus players status = 
    let 
        keep player = player.status == status
    in
       filter keep players

-- Positional filters --

filterFlex : List Player -> List Player
filterFlex players = 
    let
        isFlex player = player.position == "RB" ||  player.position == "WR"
    in
        filter isFlex players

filterPos : List Player -> String -> List Player
filterPos players pos = 
    let
        isPos player = player.position == pos
    in
        filter isPos players

--VORP calculations--

valueOverNextPlayer : String -> List Player -> (String, Float)
valueOverNextPlayer position players =
   let 
        sorted = sortByBestAvailable position players
        best = head sorted
        next = head (drop 1 sorted)
        name = Maybe.withDefault "" (Maybe.map .name best)
        bestPoints = Maybe.withDefault 0.0 (Maybe.map .projPoints best) 
        nextPoints = Maybe.withDefault 0.0 (Maybe.map .projPoints next) 
    in
        (name, (bestPoints - nextPoints))

valueOverAverageReplacement : Player -> List Player -> Float
valueOverAverageReplacement player all = 
    let 
        total = map .projPoints all |> sum
        count = length all
        averageReplacement = total / (toFloat count)
    in
        player.projPoints - averageReplacement

valueOverReplacement : Player -> List Player -> Float
valueOverReplacement player all = 
    let 
        teams = 12
        nonReplacements pos = round (teams * (startersPerTeamByPos pos))
        position = (filterPos all player.position)
        replacements = List.drop (nonReplacements player.position) position
        replacement = List.head replacements
        repPoints = case replacement of
            Just player -> player.projPoints
            _-> 0
    in
        player.projPoints - repPoints

bestAvailable : String -> List Player -> Maybe Player
bestAvailable position all = 
   all
   |> (flip sortPlayers) "projPoints"
   |> (flip filterPos) position
   |> (flip filterByStatus) "Available" 
   |> List.head

sortByBestAvailable : String -> List Player -> List Player
sortByBestAvailable position all = 
       all
       |> (flip sortPlayers) "projPoints"
       |> (flip filterPos) position
       |> (flip filterByStatus) "Available"

startersPerTeamByPos : String -> Float
startersPerTeamByPos position  =
    case position of
        "QB" -> 1
        "RB" -> 2.5
        "WR" -> 2.5
        "TE" -> 1
        "K" -> 1
        "Def" -> 1

mostProjected : List Player -> Maybe Player
mostProjected players = 
    sortBy .projPoints players |> head
