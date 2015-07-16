import "./overviewChart"


Chart.defaults.global.animation = false;

function renderChart(chartList){
    chartList.forEach((chart)=>{
        console.log(chart)
        var canvas = document.getElementById(chart.selector)
        var ctx = canvas.getContext("2d")
        $(canvas).width($(canvas).parent().width())
        $(canvas).height($(canvas).parent().height())
        
        switch (chart.chart.chartType){
            case "Line" : 
                new Chart(ctx).Line(chart.chart)
                break
            case "Bar" :
                new Chart(ctx).Line(chart.chart)
                break
            case "Radar":
                new Chart(ctx).Radar(chart.chart)
                break
            case "Overview":
                new Chart(ctx).Overview(chart.chart)
                break
            default :
                new Chart(ctx).Line(chart.chart)
                break
        }
    
    })
}


export default renderChart
