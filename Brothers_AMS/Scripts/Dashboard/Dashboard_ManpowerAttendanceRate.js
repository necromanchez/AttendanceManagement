
$(function () {
    GetUser();
    Dropdown_selectD('BIPH_Agency', "/Helper/GetDropdown_Agency");
    Dropdown_select('Sectiond', "/Helper/GetDropdown_SectionAMS");


   
   

    $("#Sectiond").on("change", function () {
        $.ajax({
            url: '/Home/ChangeSection',
            type: 'POST',
            data:{Section : $(this).val()},
            datatype: "json",
            success: function (returnData) {
              
                GetManPowerGraph_Man();
                GetAttendanceRateAbsentRate();
                GetAbsentBreakdownRate();
                GetAWOLResignedRate();
                GetOVertimeRate();
            }

        });

    })
    Dropdown_selectD('MPA_BIPH_Agency', "/Helper/GetDropdown_Agency");
    $(".MPA").on("change", function () {
        month = ($("#MPA_Month").val() == "") ? month : $("#MPA_Month").val();
        year = ($("#MPA_Year").val() == "") ? year : $("#MPA_Year").val();
        agency = ($("#MPA_BIPH_Agency").val() == "") ? agency : $("#MPA_BIPH_Agency").val();
        line = ($("#MPA_Line").val() == "") ? agency : $("#MPA_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line : line,
            Shift: $("#MPA_Shift").val()
        }
        GetManPowerGraph_Man();
        //GetAttendanceRateAbsentRate();
        //GetOVertimeRate();
        //GetAWOLResignedRate();
    })
})
var d = new Date();
var month = d.getMonth() + 1;
var year = d.getFullYear();
var agency = 'BIPH';
var line = "";

function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section').val(returnData.usersection);
            Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Dropdown_select('MPA_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Dropdown_select('AR_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Dropdown_select('awol_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Dropdown_select('breakd_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Dropdown_select('overt_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());

            if (returnData.usersection != "" && returnData.usersection != null) {
                GetManPowerGraph_Man();
                GetAttendanceRateAbsentRate();
                GetAbsentBreakdownRate();
                GetAWOLResignedRate();
                GetOVertimeRate();
            }
        }
    });
}

var Filter = {
    Month: month,
    Year:year ,
    Agency: agency,
    Shift: '',
    Line : line
}
var data1 = [];
var finaldata = [];
function GetManPowerGraph_Man() {
    data1 = [];
    finaldata = [];
    $.ajax({
        url: '/Home/GeAttendanceRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
           
            var dd = new Date(year, month, 0).getDate();
            for (var key in returnData.data2) {
                var x = 0;
                for (var key1 in returnData.data2[key]) {
                    if(x == dd){break;}
                    var unitdata;
                    unitdata = [x,returnData.data2[key][key1]]
                    data1.push(unitdata)
                    x++;//console.log()
                    
                }
                finaldata.push(data1);
                data1 = [];
            }
            graphstart(finaldata);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            
        }
    });

}


function formatDate(day,month) {
   
    var monthNames = [
      "Jan", "Feb", "Mar",
      "Apr", "May", "Jun", "Jul",
      "Aug", "Sep", "Oct",
      "Nov", "Dec"
    ];

    return monthNames[month - 1] + "-" + day;// + ' ' + year;
}



function graphstart(datahere) {

    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator = 0;
    var OverallCount = [];
    var i = "";
    for (var key in datahere) {
        var x = 0;
        var y = 0;
      
        for (var key1 in datahere[key]) {
            var theday = parseInt(key1) + 1
            i = formatDate(theday, parseInt(month));
            var Tickshere = [Iterator, i];
            var dayshft = datahere[key][x];
            dayshft[1] = parseInt(dayshft[1]);
          
            //console.log(Tickshere);
            finalticks.push(Tickshere);
            shift.push(dayshft);
           
            Iterator++;
            x++;
        }
      
        finalticks2.push(finalticks);
        Datashift.push(shift)
        finalticks = [];
        shift = [];
      
    }
   

    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 3,
        //fillColor: '#FF0000'
    }
    var line_options2 = {
        show: false,
        lineWidth: 3,
        //fillColor: '#FF0000'
    }
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.5,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    var ps = Datashift[1];
    var PresentSet = {
        label: "Present",
        data: ps,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
      
    };
    var ab = Datashift[0]
    var AbsentSet = {
            label: 'Absent',
            data: ab,
            bars: bar_options
    }

    var totalSet = {
        label: 'Attendance Rate',
        data: Datashift[2],
        lines: line_options,
        //formatter: function (label, series) {
        //    return "<div style='font-size:15pt;'>" + label + "<br>" + series.data[0][1] + " : " + series.percent.toFixed(2) + "%" + "</div>";
        //},
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
    //var line = {
    //    label: '',
    //    data: Datashift[3],
    //    xaxis: 1,
    //    stack: false,
    //    lines: line_options2,
    //    points: {
    //        radius: 0,
    //        show: true
    //    },
    //    fillColor: { colors: [{ opacity: 0.4 }, { opacity: 0.4 }] }
    //};
    data = [PresentSet, AbsentSet,totalSet];
    var tickis = finalticks2[0];
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
            ticks: tickis,
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
        //tooltipOpts: {
        //    content: function() {
        //        var content = '%s: %y'
        //        return content;
        //    },
          
        //},
        //tooltipOpts: {
        //    content: '%s: %y'
    
        //},
        tooltipOpts: {
            content: function(label, xval, yval, flotItem){
                return '%s: %y'
            },
        },

       
        colors: ['#4f81bd', '#77933c', '#FF2020'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend")
        }
    }

    var holder = $('#ManpowerARtbl');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        //var adjuster = 0;
        //var asd = Datashift[2];
        $.each(p.getData()[2].data, function (i, el) {
            //var sss = p.getData()[2].data;
            var o = p.pointOffset({ x: i, y: el[1],yaxis: 2 });
            //var tops = asd[1][adjuster];
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1] + '%</div>').css({
                    position: 'absolute',
                    left: o.left,
                    top: o.top-15,
                    display: 'none',
                    color:"red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
            //adjuster++;
        });
    }
}