
$(function () {
    GetManPowerGraph2();
   // Dropdown_select('BIPH_Agency', "/Helper/GetDropdown_Agency");

})

var data1 = [];
var finaldata_Absentrate = [];
function GetManPowerGraph2() {
    var Filter = {
        Month: "2",
        Year: "2020",
        Agency: "BIPH",
    }

    $.ajax({
        url: '/Home/GetAttendanceRate_AbsentRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var d = new Date(theyear, themonth + 2, 0).getDate();
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
            console.log(finaldata_Absentrate);

            graphstart2(finaldata_Absentrate);
        },
        error: function (xhr, ajaxOptions, thrownError) {

        }
    });

}


var themonth = 0;
var theyear = 2020;

function graphstart2(datahere) {

    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator = 0;

    var i = "";


    for (var key in datahere) {
        var x = 0;
        for (var key1 in datahere[key]) {
            var theday = parseInt(key1) + 1
            i = formatDate(theday, themonth + 1);
            var Tickshere = [Iterator, i];
            var dayshft = datahere[key][x];
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



    console.log(finalticks2);
    console.log(Datashift);


    var data, chartOptions;
    data = [
       {
           label: "Present",
           data: Datashift[0],
           lines: {
               show: true,
               lineWidth: 2,
               fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] }
           },
           points: {
               show: true,
               radius: 4,
               fill: true,
               fillColor: "#ffffff",
               lineWidth: 2
           }
       },
         {
             label: 'Absent',
             data: Datashift[1]
         },


    ];

    chartOptions = {

        xaxis: {
            ticks: finalticks2[0],
            rotateTicks: 90
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
        bars: {
            show: true,
            barWidth: .4,
            fill: true,
            align: 'center',
            fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] }
        },
        shadowSize: 0,
        tooltip: true,
        tooltipOpts: {
            content: '%s: %y'
        },
        colors: ['#00F033', '#FF0000', '#C1C1C1', '#FEFB6B'],
    }

    var holder = $('#absentrateGraph');

    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }
}