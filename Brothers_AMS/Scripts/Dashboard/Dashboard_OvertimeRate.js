
$(function () {
    //GetOVertimeRate();
    Dropdown_selectD('overt_BIPH_Agency', "/Helper/GetDropdown_Agency");
    $(".overt").on("change", function () {
        month = ($("#overt_Month").val() == "") ? month : $("#overt_Month").val();
        year = ($("#overt_Year").val() == "") ? year : $("#overt_Year").val();
        agency = ($("#overt_BIPH_Agency").val() == "") ? agency : $("#overt_BIPH_Agency").val();
        line = ($("#overt_Line").val() == "") ? agency : $("#overt_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line:line,
            Shift: $("#overt_Shift").val()
        }


        GetOVertimeRate();
       
    })
})

function GetOVertimeRate() {
    var data1 = [];
    var finaldata_Absentrate = [];

    $.ajax({
        url: '/Home/GetOvertime',
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
          //  console.log(finaldata_Absentrate);

            GraphovertimeRate(finaldata_Absentrate);
        },
        error: function (xhr, ajaxOptions, thrownError) {

        }
    });

}

function GraphovertimeRate(datahere) {


    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator = 0;

    var i = "";
    month = ($("#overt_Month").val() == "") ? month : $("#overt_Month").val();
    year = ($("#overt_Year").val() == "") ? year : $("#overt_Year").val();

    for (var key in datahere) {
        var x = 0;
        for (var key1 in datahere[key]) {
            var theday = parseInt(key1) + 1
            i = formatDate(theday, parseInt(month));
            var Tickshere = [Iterator, i];
            var dayshft = datahere[key][x];
            dayshft[1] = parseFloat(dayshft[1]);
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

  
    var data=[], chartOptions;
    var line_options = {
        show: true,
        lineWidth: 1,
        fillColor: '#FF0000'
    }
    var night = Datashift[1]
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
    var day = Datashift[0]
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

    var total = Datashift[2]
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

    switch ($("#overt_Shift").val()) {
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

   
    var tickis = finalticks2[0];
    function degreeFormatter2(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        //yaxes: [

        //      {
        //          //tick: {
        //          //    format: function (d) {
        //          //        return d + "%";
        //          //    }
        //          //},
        //          //min: 0,
        //          //max: 100,
        //          //tickFormatter: degreeFormatter2
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
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[0].data, function (i, el) {
            var o = p.pointOffset({ x: el[0], y: el[1] });
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1] + '</div>').css({
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