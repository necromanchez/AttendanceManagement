
$(function () {
    //GetAbsentBreakdownRate();
    //Dropdown_select('BIPH_Agency', "/Helper/GetDropdown_Agency");
   
    Dropdown_selectD('breakd_BIPH_Agency', "/Helper/GetDropdown_Agency");
    $(".breakd").on("change", function () {
        month = ($("#breakd_Month").val() == "") ? month : $("#breakd_Month").val();
        year = ($("#breakd_Year").val() == "") ? year : $("#breakd_Year").val();
        agency = ($("#breakd_BIPH_Agency").val() == "") ? agency : $("#breakd_BIPH_Agency").val();
        line = ($("#breakd_Line").val() == "") ? agency : $("#breakd_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line:line,
            Shift: $("#breakd_Shift").val()
        }


        GetAbsentBreakdownRate();

    })
})
function GetAbsentBreakdownRate() {
    
    var absentBreakdownData = [];
    var finaldata = [];

    $.ajax({
        url: '/Home/GetAbsentBreakdownRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var d = new Date(year, month, 0).getDate();
            for (var key in returnData.data2) {
                var x = 0;
                for (var key1 in returnData.data2[key]) {
                    if (x == d+1) { break; }
                    var unitdata;
                    unitdata = [x, returnData.data2[key][key1]]
                    absentBreakdownData.push(unitdata)
                    x++;//console.log()

                }
                finaldata.push(absentBreakdownData);
                absentBreakdownData = [];
            }
            //console.log(finaldata);

            graphstart2(finaldata);
        },
        error: function (xhr, ajaxOptions, thrownError) {

        }
    });

}




function graphstart2(datahere) {
  
    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator = 1;

    var ticksMonth = [];
    var TotalPercent = [];
    var VLLeave = [];
    var SLLeave = [];
    var MLLeave = [];
    var ELLeave = [];
    var UNKLeave = [];
    var zOverallTotalLeave = [];
    var counter = 0;

    var i = "";
    var groups = ["SL", "EL", "VL", "ML","UNK", "zOverallTotal", "Total"];
    var g = "";
    month = ($("#breakd_Month").val() == "") ? month : $("#breakd_Month").val();
    year = ($("#breakd_Year").val() == "") ? year : $("#breakd_Year").val();
    for (var key in datahere) {
        var x = 0;
        for (var key1 in datahere[key]) {
           
           
            var dayshft = datahere[key][x];
            if (groups.includes(dayshft[1])) {
                g = dayshft[1];
                //console.log(Tickshere);
                //finalticks.push(Tickshere);
                shift.push(dayshft);
               
              
            }
            else {
                var theday = parseInt(key1);
                i = formatDate(theday, parseInt(month));
                var Tickshere = [Iterator, i];
                switch (g) {
                    case "SL":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        SLLeave.push(dayshft);
                        break;
                    case "EL":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        ELLeave.push(dayshft);
                        break;
                    case "VL":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        VLLeave.push(dayshft);
                        break;
                    case "ML":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        MLLeave.push(dayshft);
                        break;
                    case "UNK":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        UNKLeave.push(dayshft);
                        break;
                    case "Total":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        TotalPercent.push(dayshft);
                        break;
                    case "zOverallTotal":
                        dayshft[1] = parseInt(dayshft[1]);
                        //console.log(Tickshere);
                        finalticks.push(Tickshere);
                        zOverallTotalLeave.push(dayshft);
                        break;
                }

                Iterator++;
               
            }
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
        fillColor: '#FF0000'
    }
    var line_options2 = {
        show: false,
        lineWidth: 0,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    }
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.5,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    var el = ELLeave;
    var ELSet = {
        label: "EL Rate",
        data: el,
        bars: bar_options,
        stack: true
    };
    var ml = MLLeave
    var MLSet = {
        label: 'ML Rate',
        data: ml,
        bars: bar_options,
        stack: true
    }
    var sl = SLLeave
    var SLSet = {
        label: "SL Rate",
        data: sl,
        bars: bar_options,
        stack: true
    };
    var vl = VLLeave
    var VLSet = {
        label: 'VL Rate',
        data: vl,
        bars: bar_options,
        stack: true
    }
    var unk = UNKLeave
    var UNKSet = {
        label: 'UNK Rate',
        data: unk,
        bars: bar_options,
        stack: true
    }
    var total = TotalPercent;
    var totalSet = {
        label: 'Total Absent Rate',
        data: total,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#ffffff",
            lineWidth: 3
        },
        stack: false,
        yaxis: 2
    }

    var Overalltotal = {
        label: '',
        data: zOverallTotalLeave,
        lines: line_options2,
        show:false,

    }

    data = [SLSet,UNKSet,VLSet, MLSet, ELSet,totalSet];//[VLSet,UNKSet, totalSet, Overalltotal];
    var tickis = finalticks2[0];
    function degreeFormatter4(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
         yaxes: [
               {
                   /* First y axis */
                   interval:1
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
                   tickFormatter: degreeFormatter4
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
        //series: {
        //    stack: true
        //},
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
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },
        //colors: ['#00F033', '#FF0000', '#C1C1C1', '#FEFB6B', '#FF1000', '#C2C1C1', '#FEFB0B'],
        legend: {
            noColumns: 7,
            container: $("#chartLegend5")
        }
    }

    var holder = $('#stacked-absent-breakdown');
    var ss = datahere.length;
    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[5].data, function (i, el) {
            var o = p.pointOffset({ x: i, y: el[1], yaxis: 2 });
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1] + '%</div>').css({
                    position: 'absolute',
                    left: o.left + 25,
                    top: o.top - 15,
                    display: 'none',
                    color: "red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
          
        });
    }

}