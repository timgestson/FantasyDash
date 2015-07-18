const fs = require("fs")
const csv = require("papaparse")
const path = require("path")

const projections = fs.readFileSync(
    path.join(__dirname, 
        "../data/SeasonCSVProjections.csv")
    ).toString()

let adp = fs.readFileSync(
    path.join(__dirname, 
        "../data/FantasyPros_2015_Overall_ADP_Rankings.xls")
    ).toString()

//Cut off header so it will parse
let lines = adp.split('\n');
lines.splice(0,5);
adp = lines.join('\n');

function importer(){
    const parsed = csv.parse(projections, {header: true, dynamicTyping: true})
    const parsedAdp = csv.parse(adp, {header: true, dynamicTyping: true})
    let adpMap = {}
    parsedAdp.data.forEach(function(player){
        adpMap[player[" Player Name "]] = player["ADP "]
    })

    const players = parsed.data
    .map((player)=>{
        let parsedPlayer =  {
            id: player.PlayerID.toString(),
            name: `${player.FirstName} ${player.LastName}`,
            position: player.Pos == "PK" ? "K" : player.Pos,
            byeWeek: player.Bye || null,
            projPoints: player.FantasyPts,
            status: "Available",
            draftedAt: null,
            favorited: false
        }
        parsedPlayer.adp = adpMap[parsedPlayer.name]
        if(parsedPlayer.name == "Odell Beckham")
            parsedPlayer.adp = adpMap["Odell Beckham Jr."]
        return parsedPlayer
    })
    .filter((player)=> 
            (player.position === "Def" 
            || player.position === "QB"
            || player.position === "RB"
            || player.position === "WR"
            || player.position === "TE"
            || player.position === "K")
            && player.adp
            && player.id
            && player.byeWeek
          
    )
    return {
        players: players,
        sidebar: {
            sort: "adp",
            filter: null,
            players: players,
            status: null
        },
        draftPosition: 1
    }
}
export default importer
