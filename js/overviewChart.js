
const overview = 
    Chart.types.Line.extend({
        name: "Overview",
        initialize: function(data){
            console.log("here", data)
            Chart.types.Line.prototype.initialize.apply(this, arguments) 
        },
        draw: function(data){
            drawLine(this.scale, 2)
            Chart.types.Line.prototype.draw.apply(this, arguments)

        }

    })

function drawLine(chart, index){
    let ctx = chart.ctx
    const x = chart.calculateX(index)
    const first = chart.calculateX(0)
    ctx.strokeStyle = 'rgb(220,220,220)'
    ctx.lineWidth = 3
    ctx.beginPath()
    ctx.moveTo(x, chart.startPoint)
    ctx.lineTo(x, chart.endPoint)
    ctx.stroke()
    ctx.closePath()
    ctx.fillStyle = "rgba(220,220,220,.3)"
    ctx.fillRect(first, chart.startPoint, x - first, chart.endPoint - chart.startPoint)
}

export default overview
