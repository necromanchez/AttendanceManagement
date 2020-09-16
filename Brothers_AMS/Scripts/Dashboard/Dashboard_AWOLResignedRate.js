$(function () {
    //GetAWOLResignedRate();
    Dropdown_selectD('awol_BIPH_Agency', "/Helper/GetDropdown_Agency");
    $(".awol").on("change", function () {
        month = ($("#awol_Month").val() == "") ? month : $("#awol_Month").val();
        year = ($("#awol_Year").val() == "") ? year : $("#awol_Year").val();
        agency = ($("#awol_BIPH_Agency").val() == "") ? agency : $("#awol_BIPH_Agency").val();
        line = ($("#awol_Line").val() == "") ? agency : $("#awol_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line:line,
            Shift: $("#awol_Shift").val()
        }

   
        //GetOVertimeRate();
        GetAWOLResignedRate();
    })
})

function GetAWOLResignedRate() {

    var data1 = [];
    var finaldata_ResignedRate = [];

    $.ajax({
        url: '/Home/GetAWOLResignedRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var d = new Date(year, month, 0).getDate();
            for (var key in returnData.data2) {
                var x = 0;
                for (var key1 in returnData.data2[key]) {
                    if (x == d) { break; }
                    var unitdata;
                    unitdata = [x, returnData.data2[key][key1]]
                    data1.push(unitdata)
                    x++;//console.log()

                }
                finaldata_ResignedRate.push(data1);
                data1 = [];
            }
           // console.log(finaldata_ResignedRate);

            GraphstartAWOL(finaldata_ResignedRate);
        },
        error: function (xhr, ajaxOptions, thrownError) {

        }
    });

}




function GraphstartAWOL(datahere) {
   

    var shift = [];
    var finalticks = [];
    var Datashift = [];
    var finalticks2 = [];
    var nonelist = [];
    var Iterator = 0;

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


    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 3,
        fillColor: '#FF0000'
    }
    var night = Datashift[2]
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
    var day = Datashift[0]
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
       
        //tooltipOpts: {
        //    content: "%s : %y.2",
        //},
        stack: false
    }

    data = [nightSet, daySet];
    var tickis = finalticks2[0];
    function degreeFormatter3(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
        //return v + "%";
    }
    chartOptions = {
        yaxes: [
              {
                  min: 0,
                  max: 100,
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

       
        colors: ['#FF0000', '#4f81bd'],
        //colors: ['#4f81bd', '#77933c', '#FF2020'],
        legend: {
            noColumns: 3,
            container: $("#chartLegend3")
        }
    }

    var holder = $('#awolrateGraph');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[0].data, function (i, el) {
            if (!isNaN(el[1])) {
                var o = p.pointOffset({ x: el[0], y: el[1] });
                $('<div class="data-point-label">' + el[1] + ' %</div>').css({
                    position: 'absolute',
                    left: o.left - 5,
                    top: o.top - 20,
                    display: 'none',
                    color:"red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }
}
