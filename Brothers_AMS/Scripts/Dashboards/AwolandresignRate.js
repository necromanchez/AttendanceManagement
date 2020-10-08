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
            Line: line,
            Shift: $("#awol_Shift").val()
        }
        GetAWOLResignedRate();
    })
})


function GetAWOLResignedRate() {
    //$("#loading_modalD_Awol").modal("show");

    $.ajax({
        url: '/Home/GET_AWOLandResignrate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
            var statusGroupData = returnData.list;
            var groupedDateSet = _.mapValues(_.groupBy(statusGroupData, 'DayMonth'),
                clist => clist.map(DayMonth => _.omit(DayMonth, 'DayMonth')));
            GraphStartGET_AWOLandResignrate(groupedDateSet);
        }
    });
}


function GetAWOLResignedRate_Department() {
    //$("#loading_modalD_Awol").modal("show");

    $.ajax({
        url: '/Home/GET_AWOLandResignrate_Department',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
            var statusGroupData = returnData.list;
            var groupedDateSet = _.mapValues(_.groupBy(statusGroupData, 'DayMonth'),
                clist => clist.map(DayMonth => _.omit(DayMonth, 'DayMonth')));
            GraphStartGET_AWOLandResignrate(groupedDateSet);
        }
    });
}


function GraphStartGET_AWOLandResignrate(datahere) {
    var finalticks = [];
    var Status = [];
    var HeadCount = [];
  
    var Iterator = 1;
    var i = "";
    var PercentRate = [];
    var INACTIVElist = [];
    var AWOLlist = [];
    var RESIGNEDlist = [];
    var TOTALout = [];
    $.each(datahere, function (ii, statusdata) {
        var monthdaydata = moment(ii).format("MM/DD/YYYY");
        var newdate = new Date(monthdaydata);
        var i = formatDate(newdate.getDate(), parseInt(month));
        //var mData = [Iterator, i];
        var Tickshere = [Iterator, i];
        var tcount = 0;
        var percount = 0;
        $.each(statusdata, function (iii, statusdataType) {
           
            switch (statusdataType.Status) {
                case "INACTIVE":
                    var HeadCountdata = [Iterator, statusdataType.HeadCount];
                    INACTIVElist.push(HeadCountdata);
                    break;
                case "RESIGNED":
                    var HeadCountdata = [Iterator, statusdataType.HeadCount];
                    RESIGNEDlist.push(HeadCountdata);
                    break;
                case "AWOL":
                    var HeadCountdata = [Iterator, statusdataType.HeadCount];
                    AWOLlist.push(HeadCountdata);
                    break;
            
            };
            tcount += statusdataType.HeadCount;
            percount += statusdataType.Percentage;
        });
        var totalout = [Iterator, tcount];
        var Perout = [Iterator, percount];
        TOTALout.push(totalout);
        PercentRate.push(Perout);
        finalticks.push(Tickshere);
        Iterator++;
    });

    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 3,
    }

    var line_options2 = {
        show: true,
        lineWidth: 0,
        fillColor: { colors: [{ opacity: 0 }, { opacity: 0 }] },
    }

    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.5,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    
    var INACTIVESet = {
        label: 'Inactive',
        data: INACTIVElist,
        //lines: line_options,
        bars: bar_options,
        //formatter: function (label, series) {
        //    return "<div style='font-size:15pt;'>" + label + "<br>" + series.data[0][1] + " : " + series.percent.toFixed(2) + "%" + "</div>";
        //},
        //points: {
        //    show: true,
        //    radius: 4,
        //    fill: true,
        //    lineWidth: 1
        //},
        yaxis: 1,
        stack: true
    }

    var AWOLSet = {
        label: 'AWOL',
        data: AWOLlist,
        //lines: line_options,
        bars: bar_options,
        //points: {
        //    show: true,
        //    radius: 4,
        //    fill: true,
        //    lineWidth: 1
        //},
        yaxis: 1,
        stack: true
    }

    var RESIGNEDSet = {
        label: 'Resigned',
        data: RESIGNEDlist,
        //lines: line_options,
        bars: bar_options,
        //points: {
        //    show: true,
        //    radius: 4,
        //    fill: true,
        //    lineWidth: 1
        //},
        yaxis: 1,
        stack: true
    }

    var TotaloutSet = {
        label: '',
        data: TOTALout,
        lines: line_options2,
        //points: {
        //    show: true,
        //    radius: 4,
        //    fill: true,
        //    lineWidth: 1
        //},
        yaxis: 1,
        stack: false
    }

    var PerSet = {
        label: 'AWOL/Resigned Rate',
        data: PercentRate,
        lines: line_options,
        //points: {
        //    show: true,
        //    radius: 4,
        //    fill: true,
        //    lineWidth: 1
        //},
        //yaxis: 2,
        stack: false
    }
    
      
    data = [TotaloutSet, INACTIVESet, AWOLSet, RESIGNEDSet, PerSet];
    var tickis = finalticks;
    //function degreeFormatter3(v, axis) {
    //    return v.toFixed(axis.tickDecimals) + "%";
    //    //return v + "%";
    //}
    chartOptions = {
        yaxis: {
            min: 0,
            tickDecimals:0
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

        colors: ['#4f81bd', '#77933c', '#FF2020', '#77233c'],
        legend: {
            noColumns: 4,
            container: $("#chartLegend3")
        }
    }

    var holder = $('#awolrateGraph');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[0].data, function (i, el) {
            if (!isNaN(el[1])) {
                var o = p.pointOffset({ x: el[0], y: el[1] });
                $('<div class="data-point-label">' + el[1] + '</div>').css({
                    position: 'absolute',
                    left: o.left - 5,
                    top: o.top - 20,
                    display: 'none',
                    color: "red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }
    $("#loading_modalD_Awol").modal("hide");
}