import "./overviewChart"


Chart.defaults.global.animation = false;
var renderedCharts = []

function renderChart(chartList){
    //deactivate old charts
    renderedCharts.forEach(function(chart){
        chart.destroy()
    })
    //render charts
    renderedCharts = chartList.map((chart)=>{
        var canvas = document.getElementById(chart.selector)
        var ctx = canvas.getContext("2d")
        $(canvas).width($(canvas).parent().width())
        $(canvas).height($(canvas).parent().height())
        
        switch (chart.chart.chartType){
            case "Line" : 
                return new Chart(ctx).Line(chart.chart)
                break
            case "Bar" :
                return new Chart(ctx).Line(chart.chart)
                break
            case "Radar":
                return new Chart(ctx).Radar(chart.chart)
                break
            case "Overview":
                return new Chart(ctx).Overview(chart.chart)
                break
            default :
                return new Chart(ctx).Line(chart.chart)
                break
        }
    
    })
}


export default renderChart
