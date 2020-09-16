
$(function () {
    //GetAttendanceRateAbsentRate();
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
      
        GetAttendanceRateAbsentRate();
       
    })
})

function GetAttendanceRateAbsentRate() {
    var data1 = [];
    var finaldata_Absentrate = [];
   
    $.ajax({
        url: '/Home/GetAttendanceRate_AbsentRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var d = new Date(year, month, 0).getDate();
            for (var key in returnData.data) {
                var x = 0;
                for (var key1 in returnData.data[key]) {
                    if (x == d) { break; }
                    var unitdata;
                    unitdata = [x, returnData.data[key][key1]]
                    data1.push(unitdata)
                    x++;//console.log()

                }
                finaldata_Absentrate.push(data1);
                data1 = [];
            }
            //console.log(finaldata_Absentrate);

            GraphstartAbsentRate(finaldata_Absentrate);
        },
        error: function (xhr, ajaxOptions, thrownError) {

        }
    });

}

function GraphstartAbsentRate(datahere) {
  

    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator =0;

    var i = "";

    month = ($("#AR_Month").val() == "") ? month : $("#AR_Month").val();
    year = ($("#AR_Year").val() == "") ? year : $("#AR_Year").val();
    for (var key in datahere) {
        var x = 0;
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



    //console.log(finalticks2);
    //console.log(Datashift);


    var data=[], chartOptions;
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
    var night = Datashift[1]
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
    var day = Datashift[0]
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

    var total = Datashift[2]
    var totalSet = {
        label: 'Total Absent Rate',
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
    //var SETcount = {
    //    label: 'Absent',
    //    data: Datashift[3],
    //    bars: bar_options
    //}
    switch ($("#AR_Shift").val()) {
        case "":
            data.push(nightSet);
            data.push(daySet);
            data.push(totalSet);
            break;
        case "Day":
          
            data.push(daySet);
            break;
        case "Night":
            data.push(nightSet);
           
            break;
    }

   // data = [nightSet, daySet, totalSet];
    var tickis = finalticks2[0];
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
        colors: ['#4f81bd', '#77933c', '#FF2020'],
        legend: {
            noColumns: 4,
            container: $("#chartLegend2")
        }
    }

    var holder = $('#absentrateGraph');

    if (holder.length) {
        //$.plot(holder, data, chartOptions);
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[2].data, function (i, el) {
            var o = p.pointOffset({ x: el[0], y: el[1] });
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1] + ' %</div>').css({
                    position: 'absolute',
                    left: o.left - 5,
                    top: o.top - 20,
                    display: 'none',
                    color:"red"
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }



}