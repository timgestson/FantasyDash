
const overview = 
    Chart.types.Line.extend({
        name: "Overview",
        initialize: function(data){
            this.line = data.extras.line
            console.log(data)
            console.log(this)
            this.options.tooltipTemplate = 
                "<%= value %>: <%= names[value] =>"
            Chart.types.Line.prototype.initialize.apply(this, arguments) 
        },
        draw: function(data){
            Chart.types.Line.prototype.draw.apply(this, arguments)
            if(this.line > 2)
                drawLine(this.scale, this.line - 2)
        }

    })

function drawLine(chart, index){
    let ctx = chart.ctx
    const x = chart.calculateX(index)
    const first = chart.calculateX(0)
    console.log(x, first)
    ctx.strokeStyle = 'rgb(220,220,220)'
    ctx.lineWidth = 3
    ctx.beginPath()
    ctx.moveTo(x, chart.startPoint)
    ctx.lineTo(x, chart.endPoint)
    ctx.stroke()
    ctx.closePath()
    ctx.fillStyle = "rgba(220,220,220,.6)"
    ctx.fillRect(first, chart.startPoint, x - first, chart.endPoint - chart.startPoint)
}

export default overview
