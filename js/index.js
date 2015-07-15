import importer from  "./importer"
import renderChart from "./charts"


const storedState = localStorage.getItem("draftState")
const startingState = storedState ? JSON.parse(storedState) : importer()

const app = Elm.fullscreen(Elm.DraftDash, 
        { 
            getState: startingState 
        })

const ports = app.ports

ports.renderChart.subscribe(renderChart)

ports.setState.subscribe((state)=>{
    localStorage.setItem("draftState", JSON.stringify(state));
})

