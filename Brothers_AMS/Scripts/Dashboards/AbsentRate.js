$(function () {
    Dropdown_selectD('AR_BIPH_Agency', "/Helper/GetDropdown_Agency");
    $(".AR").on("change", function () {
        month = ($("#AR_Month").val() == "") ? month : $("#AR_Month").val();
        year = ($("#AR_Year").val() == "") ? year : $("#AR_Year").val();
        agency = ($("#AR_BIPH_Agency").val() == "") ? agency : $("#AR_BIPH_Agency").val();
        line = ($("#AR_Line").val() == "") ? agency : $("#AR_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line: line,
            Shift: $("#AR_Shift").val()
        }

        AbsentRate();

    })
   

});


function AbsentRate() {
    //$("#loading_modalD_AbsentRate").modal("show");
    $.ajax({
        url: '/Home/GET_AbsentRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
            
            GraphStartAbsentRate(returnData.list);
        }

    });
}

function AbsentRate_Department() {
    //$("#loading_modalD_AbsentRate").modal("show");
    $.ajax({
        url: '/Home/GET_AbsentRate_Department',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            GraphStartAbsentRate(returnData.list);
        }

    });
}

function GraphStartAbsentRate(datahere) {
    var finalticks = [];
    var DayAbsent = [];
    var NightAbsent = [];
    var NoSchedAbsent = [];
    var AbsentPercentDay = [];
    var AbsentPercentNight = [];
    var AbsentPercentNoSched = [];
    var NoSchedAbsent = [];
    var TOTALAbsent = [];
    var MonthDay = [];
    var Iterator = 1;
    var i = "";
    datahere.forEach(function (x) {
        var theday = parseInt(x.MonthDay);
        i = formatDate(theday, parseInt(month));
        var Tickshere = [Iterator, i];
        var DayAbsentdata = [Iterator, x.DayAbsent];
        var NightAbsentdata = [Iterator, x.NightAbsent];
        var NoSchedAbsentdata = [Iterator, x.NoSchedAbsent];
        var TOTALAbsentdata = [Iterator, x.TotalPercentage];
        var AbsentPercentDayData = [Iterator, x.AbsentPercentDay];
        var AbsentPercentNightData = [Iterator, x.AbsentPercentNight];
        var AbsentPercentNoSchedData = [Iterator, x.AbsentPercentNosched];
        MonthDay.push(x.MonthDay);
        DayAbsent.push(DayAbsentdata);
        NightAbsent.push(NightAbsentdata);
        NoSchedAbsent.push(NoSchedAbsentdata);
        AbsentPercentDay.push(AbsentPercentDayData);
        AbsentPercentNight.push(AbsentPercentNightData);
        AbsentPercentNoSched.push(AbsentPercentNoSchedData);
        TOTALAbsent.push(TOTALAbsentdata);
        finalticks.push(Tickshere);
        Iterator++;
    });




    var chartOptions;
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.6,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    var line_options = {
        show: true,
        lineWidth: 3,
        fillColor: '#FF0000'
    }
    var line_options2 = {
        show: false,
        lineWidth: 3,
        //fillColor: '#FF0000'
    }
    var night = NightAbsent
    var nightSet = {
        label: 'Night Shift Absent',
        data: night,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            lineWidth: 1
        },
        stack: false,
        yaxis:1
    }
    var day = DayAbsent
    var daySet = {
        label: 'Day Shift Absent',
        data: day,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,

            lineWidth: 1
        },
        stack: false,
        yaxis: 1
    }

    var nosched = NoSchedAbsent;
    var NoSchedSet = {
        label: 'No Shift Absent',
        data: nosched,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,

            lineWidth: 1
        },
        stack: false,
        yaxis: 1
    }

    var total = TOTALAbsent
    var totalSet = {
        label: 'Total Absent Rate',
        data: total,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "red",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,
        
    }

    var daypercent = AbsentPercentDay
    var daypercentSet = {
        label: 'Absent Day percent',
        data: daypercent,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "red",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,
       
    }

    var nightpercent = AbsentPercentNight
    var nightpercentSet = {
        label: 'Absent Night percent',
        data: nightpercent,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "red",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,
        
    }

    var noschedpercent = AbsentPercentNoSched
    var noschedpercentSet = {
        label: 'Absent Night percent',
        data: AbsentPercentNoSched,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "red",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,

    }
    var columncount = 0;
    var colored;
    var data = [];
   
    //switch ($("#AR_Shift").val()) {
    
    switch ($("#Shift").val()) {
        case "":
            data.push(totalSet);
            data.push(nightSet);
            data.push(daySet);
            data.push(NoSchedSet);
            colored = ['red', '#808000', '#4E8EFF', '#929495']
            columncount = 4;
            break;
        case "Day":
            data.push(daypercentSet);
            data.push(daySet);
            colored = ['red', '#4E8EFF']
            columncount = 2;
            break;
        case "Night":
            data.push(nightpercentSet);
            data.push(nightSet);
            colored = ['red', '#808000']
            columncount = 2;
            break;
        case "NoSched":
            data.push(noschedpercentSet);
            data.push(NoSchedSet);
            colored = ['red', '#929495']
            columncount = 2;
            break;
    }

    var tickis = finalticks;
    function degreeFormatter2(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxes: [
            {
                position: "left",  /* left or right */
              
                interval: 1
                //min: 0,
                //max: 100,
              
            },
            {
                position: "right",  /* left or right */
                tick: {
                    format: function (d) {
                        return d;
                    }
                },
                min: 0,
                max: 100,
                tickFormatter: degreeFormatter2
            }
        ],
        xaxis: {
            ticks: tickis,
            rotateTicks: 90
        },
        grid: {
            hoverable: true,
            clickable: false,
            borderWidth: 1,
            tickColor: '#eaeaea',
            borderColor: '#eaeaea',
        },
        shadowSize: 0,
        tooltip: true,
        tooltipOpts: {
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },

        //content: function (label, xval, yval, flotItem) {
        //    return label + ' x:' + xval + ' y: ' + yval;
        //},
        colors: colored,
        legend: {
            noColumns: columncount,
            container: $("#chartLegend2")
        }
    }

    var holder = $('#absentrateGraph');

    if (holder.length) {
        //$.plot(holder, data, chartOptions);
        var p = $.plot(holder, data, chartOptions);
       
            $.each(p.getData()[0].data, function (i, el) {
                var o = p.pointOffset({ x: el[0], y: el[1], yaxis: 2 });
                if (!isNaN(el[1])) {
                    $('<div class="data-point-label">' + el[1].toFixed(0) + ' %</div>').css({
                        position: 'absolute',
                        left: o.left,
                        top: o.top - 15,
                        display: 'none',
                        color: "red"
                    }).appendTo(p.getPlaceholder()).fadeIn('slow');
                }
            });
       
    }
    Graph2 = true;

    if (Graph1 == true && Graph2 == true && Graph3 == true && Graph4 == true && Graph5 == true) {
        $("#loading_modalD_AttendanceRate").modal("hide");
    }
}