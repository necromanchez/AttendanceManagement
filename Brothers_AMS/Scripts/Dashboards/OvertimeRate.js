$(function () {

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
            Line: line,
            Shift: $("#overt_Shift").val()
        }


        GetOvertimeRate();

    })
})

function GetOvertimeRate() {
    //$("#loading_modalD_OT").modal("show");
    $.ajax({
        url: '/Home/GET_OTRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            GraphStartOTrate(returnData.list);
        }

    });
}


function GetOvertimeRate_Department() {
    $.ajax({
        url: '/Home/GET_OTRate_Department',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            GraphStartOTrate(returnData.list);
        }

    });

}

function GraphStartOTrate(datahere) {
    var finalticks = [];
    var HeadCount = [];
    var OTHours = [];
    var Iterator = 1;
    var i = "";

    datahere.forEach(function (x) {
        var monthdaydata = moment(x.DayMonth).format("MM/DD/YYYY");
        var newdate = new Date(monthdaydata);
        var i = formatDate(newdate.getDate(), parseInt(month));
        var Tickshere = [Iterator, i];
        var OTHoursdata = [Iterator, x.OTHours.toFixed(1)];
        var HeadCountData = [Iterator, x.HeadCount];
        OTHours.push(OTHoursdata);
        HeadCount.push(HeadCountData);
        finalticks.push(Tickshere);
        Iterator++;
    });
    var data = [], chartOptions;

    var line_options = {
        show: true,
        lineWidth: 3,
        fillColor: '#FF0000',

    }


    var HeadCountDataSet = {
        label: 'Employee Count',
        data: HeadCount,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#FF2020",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,

    }


    var OTHoursSet = {
        label: 'OT Hours',
        data: OTHours,
        lines: line_options,

        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#FF2020",
            lineWidth: 1
        },
        stack: false,
        yaxis: 1,

    }
    var tickis = finalticks;
    data = [OTHoursSet, HeadCountDataSet];
    //data = [HeadCountDataSet];
    function degreeFormatter2(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxis: {
            min: 1
        },
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
            //content: function (label, xval, yval, flotItem) {
            //    return '%s: %y'
            //},
            content: function (label, xval, yval, flotItem) {
                return ' %s: ' + yval;
            },
        },


        //colors: ['#4f81bd', '#77933c', '#FF2020'],
        legend: {
            noColumns: 2,
            container: $("#chartLegend4")
        }
    }

    var holder = $('#stacked-Overtime');

    if (holder.length) {
        //$.plot(holder, data, chartOptions);
        var p = $.plot(holder, data, chartOptions);

        $.each(p.getData()[0].data, function (i, el) {
            var o = p.pointOffset({ x: el[0], y: el[1] });
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1] + '</div>').css({
                    position: 'absolute',
                    left: o.left,
                    top: o.top-10,
                    display: 'none',
                    color: "red"
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });

    }
    Graph4 = true;
    $(".graph_5").hide();
    //if (Graph1 == true && Graph2 == true && Graph3 == true && Graph4 == true && Graph5 == true) {
    //    $("#loading_modalD_AttendanceRate").modal("hide");
    //}
}