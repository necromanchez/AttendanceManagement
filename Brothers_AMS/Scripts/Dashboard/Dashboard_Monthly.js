
$(function () {
    var d = new Date();
    $("#BigchosenYear").prop("disabled", true);
    $("#BigchosenYear").val(GetYear());
    $("#Bigchosen").on("change", function () {
        if ($("#Bigchosen").val() == "Mon") {
            $("#BigchosenYear").prop("disabled", false);
        }
        else {
            $("#BigchosenYear").prop("disabled", true);
        }

    })
    $("#Generatetblsss").on("click", Monthly);




});

var  MYear, MAgency, MLine, MShift;

function Monthly() {

    MYear = $("#BigchosenYear").val();
    MAgency = $("#BIPH_Agency").val();
    MLine = $("#Line").val();
    MShift = $("#Shift").val();

    $("#loading_modalD").modal("show");
   
    if ($("#Bigchosen").val() == "Mon") {
        AttendanceRateMonthly();
    }
    else {
        AttendanceRate_Yearly();
    }
   
}

function GetYear() {
    var d = new Date();
    var n = d.getFullYear();
    return n;
}

function AttendanceRateMonthly() {

    //AttendanceRate
    $.ajax({
        url: '/Home/GetMonthly_AttendanceRate',
        type: 'POST',
        data: {
            Year: MYear,
            Agency: MAgency,
            Line : MLine,
            Shift:MShift
        },
        datatype: "json",
        success: function (returnData) {
            var obj = JSON.parse(returnData.data);
            graphstartMonthly_AttendanceRate(obj);
            $("#loading_modalD").modal("hide");
        }
    });

    //AbsentRate
    $.ajax({
        url: '/Home/GetMonthly_AbsentRate',
        type: 'POST',
        data: {
            Year: MYear,
            Agency: MAgency,
            Line: MLine,
            Shift: MShift
        },
        datatype: "json",
        success: function (returnData) {
            var obj = JSON.parse(returnData.data);
            graphstartMonthly_AbsentRate(obj);
        }
    });

    //AwolResignRate
    $.ajax({
        url: '/Home/GetMonthly_AwolResignRate',
        type: 'POST',
        data: {
            Year: MYear,
            Agency: MAgency,
            Line: MLine,
            Shift: MShift
        },
        datatype: "json",
        success: function (returnData) {
           
            var obj = JSON.parse(returnData.data);
            graphstartMonthly_AwolResignRate(obj);
        }
    });

    //AbsentBreakdown
    $.ajax({
        url: '/Home/GetMonthly_LeaveBreakdown',
        type: 'POST',
        data: {
            Year: MYear,
            Agency: MAgency,
            Line: MLine,
            Shift: MShift
        },
        datatype: "json",
        success: function (returnData) {
           
            var obj = JSON.parse(returnData.data);
            graphstartMonthly_LeaveBreakdown(obj);
        }
    });


    //OTHours
    $.ajax({
        url: '/Home/GetMonthly_Overtime',
        type: 'POST',
        data: {
            Year: MYear,
            Agency: MAgency,
            Line: MLine,
            Shift: MShift
        },
        datatype: "json",
        success: function (returnData) {
           
            var obj = JSON.parse(returnData.data);
            graphstartMonthly_OT(obj);
        }
    });
}


function graphstartMonthly_AttendanceRate(datahere) {

    var ticksMonth = [];
    var PresentPercent = [];
    var Present = [];
    var Absent = [];

    for (var x = 0; x < datahere.length; x++) {
        var Tickshere = [x, datahere[x].MonthName];
        var Per = [x, datahere[x].PresentPercentage];
        var Pre = [x, datahere[x].AveragePresent];
        var abs = [x, datahere[x].AverageAbsent];
        ticksMonth.push(Tickshere);
        PresentPercent.push(Per);
        Present.push(Pre);
        Absent.push(abs);
    }
    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.6,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    
    var PresentSet = {
        label: "Present",
        data: Present,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    
    var AbsentSet = {
        label: 'Absent',
        data: Absent,
        bars: bar_options
    }

    var totalSet = {
        label: 'Attendance Rate',
        data: PresentPercent,
        lines: line_options,
        formatter: function (label, series) {
            return "<div style='font-size:15pt;'>" + label + "<br>" + series.data[0][1] + " : " + series.percent.toFixed(2) + "%" + "</div>";
        },
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#ffffff",
            lineWidth: 1
        },
        yaxis: 2,
        stack: false
    }
    data = [PresentSet, AbsentSet, totalSet];
    function degreeFormatter(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxes: [
               {
                   /* First y axis */
               },
               {
                   /* Second y axis */
                   position: "right",  /* left or right */
                   tick: {
                       format: function (d) {
                           return d + "%";
                       }
                   },
                   min: 0,
                   max: 100,
                   tickFormatter: degreeFormatter
               }
        ],
        xaxis: {
            ticks: ticksMonth,
            rotateTicks: 90,

        },
        grid: {
            hoverable: true,
            clickable: false,
            borderWidth: 1,
            tickColor: '#eaeaea',
            borderColor: '#eaeaea',
        },
        series: {
            stack: true
        },
        shadowSize: 0,
        tooltip: true,
        tooltipOpts: {
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },


        colors: ['#00F033', '#6AC8FE', '#FF2020', '#FEFB6B'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend")
        }
    }

    var holder = $('#ManpowerARtbl');

   
    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }
}


function graphstartMonthly_AbsentRate(datahere) {

    var ticksMonth = [];
    var AbsPercent_Day = [];
    var AbsPercent_Night = [];
    var Abstotal = [];
 

    for (var x = 0; x < datahere.length; x++) {
        var Tickshere = [x, datahere[x].MonthName];
        var TotalPer = [x, datahere[x].AbsentPercentage];
        var Dayper = [x, datahere[x].AverageDayabsentPercentage];
        var Nightper = [x, datahere[x].NightAbsentPercentage];
        ticksMonth.push(Tickshere);
        AbsPercent_Day.push(Dayper);
        AbsPercent_Night.push(Nightper);
        Abstotal.push(TotalPer);
    }
    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var night = AbsPercent_Night
    var nightSet = {
        label: 'Night Shift Absent Rate',
        data: night,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,

            lineWidth: 1
        },
        stack: false
    }
    var day = AbsPercent_Day
    var daySet = {
        label: 'Day Shift Absent Rate',
        data: day,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,

            lineWidth: 1
        },
        stack: false
    }

    var total = Abstotal
    var totalSet = {
        label: 'Total Absent Rate',
        data: total,
        lines: line_options,
        points: {
            show: true,
            radius: 8,
            fill: true,
            fillColor: "#FF2020",
            lineWidth: 1
        },
        stack: false
    }

    data = [nightSet, daySet, totalSet];
    var tickis = ticksMonth;
    function degreeFormatter2(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxes: [

              {
                  tick: {
                      format: function (d) {
                          return d + "%";
                      }
                  },
                  min:0,
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
        colors: ['#00F033', '#6AC8FE', '#FF2020', '#FEFB6B'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend2")
        }
    }

    var holder = $('#absentrateGraph');

    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }
}


function graphstartMonthly_AwolResignRate(datahere) {


    var ticksMonth = [];
    var TotalMP = [];
    var ResignRate = [];


    for (var x = 0; x < datahere.length; x++) {
        var Tickshere = [x, datahere[x].MonthName];
        var TotalPer = [x, datahere[x].AverageTotalMP];
        var resign = [x, datahere[x].ResignedPercentage];
        ticksMonth.push(Tickshere);
        ResignRate.push(resign);
        TotalMP.push(TotalPer);
    }
   
    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var night = ResignRate
    var nightSet = {
        label: 'AWOL/Resigned Rate',
        data: night,
        lines: line_options,
        formatter: function (label, series) {
            return "<div style='font-size:15pt;'>" + label + "<br>" + series.data[0][1] + " : " + series.percent.toFixed(2) + "%" + "</div>";
        },
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#ffffff",
            lineWidth: 1
        },
        yaxis: 2,
        stack: false
    }
    var day = TotalMP
    var daySet = {
        label: 'Total MP Count',
        data: day,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#ffffff",
            lineWidth: 1
        },

     
        stack: false
    }

    data = [nightSet, daySet];
    var tickis = ticksMonth;
    function degreeFormatter3(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
        //return v + "%";
    }
    chartOptions = {
        yaxes: [
              {
                  min: 0,
                  max: 10000,
              },
              {
                  /* Second y axis */
                  position: "right",  /* left or right */
                  tick: {
                      format: function (d) {
                          return d + "%";
                      }
                  },
                  min: 0,
                  max: 100,
                  tickFormatter: degreeFormatter3
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
                if (label == 'Total MP Count') {

                    return yval + '';
                }
                else {
                    return yval.toFixed(2) + '%';
                }


            },
        },


        colors: ['#FF0000', '#00F033', '#C1C1C1', '#FEFB6B'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend3")
        }
    }

    var holder = $('#awolrateGraph');

    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }
}


function graphstartMonthly_LeaveBreakdown(datahere) {

    var groupedMonth = _.mapValues(_.groupBy(datahere, 'MonthName'),
                       clist => clist.map(Section => _.omit(Section, 'MonthName')));

    var ticksMonth = [];
    var LeavePercent = [];
    var VLLeave = [];
    var SLLeave = [];
    var MLLeave = [];
    var ELLeave = [];
    var UNKLeave = [];
    var counter = 0;
    for (var key in groupedMonth) {
        var Tickshere = [counter, key];
        ticksMonth.push(Tickshere);
        var s = key;
        var ss = groupedMonth[s];
        for (var x = 0; x < groupedMonth[s].length;x++) {
            switch (ss[x].LeaveType) {
                    case "VL":
                        var VL = [counter, ss[x].LeaveCount];
                        VLLeave.push(VL);

                        break;
                    case "SL":
                        var SL = [counter, ss[x].LeaveCount];
                        SLLeave.push(SL);
                        break;
                    case "ML":
                        var ML = [counter, ss[x].LeaveCount];
                        MLLeave.push(ML);
                        break;
                    case "EL":
                        var EL = [counter, ss[x].LeaveCount];
                        ELLeave.push(EL);
                        break;
                    case "UNK":
                        var unk = [counter, ss[x].LeaveCount];
                        UNKLeave.push(unk);
                        break;

            }
          
        }
        counter++;
    }

    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.6,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
   
    var ELSet = {
        label: "EL Rate",
        data: ELLeave,
        bars: bar_options,
        stack: true
    };
  
    var MLSet = {
        label: 'ML Rate',
        data: MLLeave,
        bars: bar_options,
        stack: true
    }
  
    var SLSet = {
        label: "SL Rate",
        data: SLLeave,
        bars: bar_options,
        stack: true
    };
    
    var VLSet = {
        label: 'VL Rate',
        data: VLLeave,
        bars: bar_options,
        stack: true
    }

    
    var UNKSet = {
        label: 'UNK Rate',
        data: UNKLeave,
        bars: bar_options,
        stack: true
    }
   
    data = [ELSet, MLSet, SLSet, VLSet, UNKSet];
    var tickis = ticksMonth;
    function degreeFormatter4(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        //yaxes: [
        //      {
        //          /* First y axis */
        //      },
        //      {
        //          /* Second y axis */
        //          position: "right",  /* left or right */
        //          tick: {
        //              format: function (d) {
        //                  return d + "%";
        //              }
        //          },
        //          min: 0,
        //          max: 100,
        //          tickFormatter: degreeFormatter4
        //      }
        //],
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
        //series: {
        //    stack: true
        //},
        shadowSize: 0,
        tooltip: true,
        tooltipOpts: {
            content: '%s: %y'
        },

        content: function (label, xval, yval, flotItem) {
            return label + ' x:' + xval + ' y: ' + yval;
        },
         legend: {
            noColumns: 7,
            container: $("#chartLegend5")
        },
        colors: ['#00F033', '#FF0000', '#C1C1C1', '#FEFB6B', '#FF0000', '#C2C2C2', '#FEFBCB'],
    }

    var holder = $('#stacked-absent-breakdown');
    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }


}


function graphstartMonthly_OT(datahere) {

    var groupedMonth = _.mapValues(_.groupBy(datahere, 'MonthName'),
                       clist => clist.map(Section => _.omit(Section, 'MonthName')));

    var ticksMonth = [];
    var DayShift = [];
    var NightShift = [];
    var TotalOT = [];
    var counter = 0;
    for (var key in groupedMonth) {
        var Tickshere = [counter, key];
        ticksMonth.push(Tickshere);
        var s = key;
        var ss = groupedMonth[s];
        for (var x = 0; x < groupedMonth[s].length; x++) {
            switch (ss[x].Type) {
                case "DayShift":
                    var ds = [counter, ss[x].Count];
                    DayShift.push(ds);

                    break;
                case "NightShift":
                    var ns = [counter, ss[x].Count];
                    NightShift.push(ns);
                    break;
                case "TotalOT":
                    var tot = [counter, ss[x].Count];
                    TotalOT.push(tot);
                    break;
            }

        }
        counter++;
    }

    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var night = NightShift
    var nightSet = {
        label: 'Night Shift Rate',
        data: night,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            lineWidth: 1
        },
        stack: false
    }
    var day = DayShift
    var daySet = {
        label: 'Day Shift Rate',
        data: day,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            lineWidth: 1
        },
        stack: false
    }

    var total = TotalOT
    var totalSet = {
        label: 'Total Rate',
        data: total,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#FF2020",
            lineWidth: 1
        },
        stack: false
    }

    data = [nightSet, daySet, totalSet];
    var tickis = ticksMonth;
   
    chartOptions = {
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

        colors: ['#00F033', '#6AC8FE', '#FF2020', '#FEFB6B'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend4")
        }
    }

    var holder = $('#stacked-Overtime');

    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }


}