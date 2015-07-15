const fs = require("fs")
const csv = require("papaparse")
const path = require("path")

const projections = fs.readFileSync(
    path.join(__dirname, "../data/SeasonCSVProjections.csv")
).toString()

function importer(){
    const parsed = csv.parse(projections, {header: true, dynamicTyping: true})
    const players = parsed.data
    .map((player)=>{
        return {
            id: player.PlayerID.toString(),
            adp: player.ADP,
            name: `${player.FirstName} ${player.LastName}`,
            position: player.Pos,
            byeWeek: player.Bye || null,
            projPoints: player.FantasyPts,
            status: "Available",
            draftedAt: null,
            favorited: false
        }
    })
    .filter((player)=> 
            (player.position === "Def" 
            || player.position === "QB"
            || player.position === "RB"
            || player.position === "WR"
            || player.position === "TE"
            || player.position === "K")
            && player.adp !== ""
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
        }
    }
}
export default importer
