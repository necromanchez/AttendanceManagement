function YearlyDashboard() {
    $("#loading_modalD_Yearly").modal("show");
    $.ajax({
        url: '/Home/Get_YearlyDashboard',
        type: 'POST',
        data: {
            Agency: MAgency,
            Line: MLine,
            Shift: MShift,
            GroupSection: $("#Sectiond").val()
        },
        datatype: "json",
        success: function (returnData) {
            GraphAttendanceRate_Yearly(returnData.AttendanceRateYearly);
            GraphStartAbsentRate_Yearly(returnData.AbsentRateYearly);
            var LeaveGroupData = returnData.LeaveBreakdownYearly;
            var groupedDateSet = _.mapValues(_.groupBy(LeaveGroupData, 'Year'),
                clist => clist.map(Year => _.omit(Year, 'Year')));
            GraphStartLeaveBreakdown_Yearly(groupedDateSet);

            var statusGroupData = returnData.AwolandResignedYearly;
            var groupedDateSet2 = _.mapValues(_.groupBy(statusGroupData, 'Year'),
                clist => clist.map(Year => _.omit(Year, 'Year')));
            GraphStartGET_AWOLandResignrate_Yearly(groupedDateSet2);

            GraphStartOTrate_Yearly(returnData.OTRateYearly);

            $("#loading_modalD_Yearly").modal("hide");
        }
    });

}


function YearlyDashboard_Department() {
    $("#loading_modalD_Yearly").modal("show");
    $.ajax({
        url: '/Home/Get_YearlyDashboard_Department',
        type: 'POST',
        data: {
            Agency: MAgency,
            Line: MLine,
            Shift: MShift,
            GroupSection: $("#Sectiond").val()
        },
        datatype: "json",
        success: function (returnData) {
            GraphAttendanceRate_Yearly(returnData.AttendanceRateYearly);
            GraphStartAbsentRate_Yearly(returnData.AbsentRateYearly);
            var LeaveGroupData = returnData.LeaveBreakdownYearly;
            var groupedDateSet = _.mapValues(_.groupBy(LeaveGroupData, 'Year'),
                clist => clist.map(Year => _.omit(Year, 'Year')));
            GraphStartLeaveBreakdown_Yearly(groupedDateSet);

            var statusGroupData = returnData.AwolandResignedYearly;
            var groupedDateSet2 = _.mapValues(_.groupBy(statusGroupData, 'Year'),
                clist => clist.map(Year => _.omit(Year, 'Year')));
            GraphStartGET_AWOLandResignrate_Yearly(groupedDateSet2);

            GraphStartOTrate_Yearly(returnData.OTRateYearly);

            $("#loading_modalD_Yearly").modal("hide");
        }
    });

}


function GraphAttendanceRate_Yearly(datahere) {
    var finalticks = [];
    var Present = [];
    var Absent = [];
    var PresentInactive = [];
    var MLCount = [];
    var NWCount = [];
    var Percentage = [];
    var MonthDay = [];
    var Iterator = 1;
    var i = "";
    datahere.forEach(function (x) {
        //var theday = parseInt(x.MonthDay);
        //i = formatDate(theday, parseInt(month));

        var Tickshere = [Iterator, x.Year];
        var Presentdata = [Iterator, x.PresentTotal];
        var Absentdata = [Iterator, x.AbsentTotal];
        //var PresentInactivedata = [Iterator, x.PresentInactive];
        var MLCountdata = [Iterator, x.MLTotal];
        var NWCountdata = [Iterator, x.NWTotal];
        var Percentdata = [Iterator, x.Percentage];

        Present.push(Presentdata);
        //PresentInactive.push(PresentInactivedata);
        Absent.push(Absentdata);
        MLCount.push(MLCountdata);
        NWCount.push(NWCountdata);
        Percentage.push(Percentdata);

        finalticks.push(Tickshere);
        Iterator++;
    });


    var data, chartOptions;
    var line_options = {
        show: true,
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

    var PresentSet = {
        label: "Present",
        data: Present,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    //var PresentInactiveSet = {
    //    label: "Present Inactive Employees",
    //    data: PresentInactive,
    //    bars: bar_options,
    //    fill: true,
    //    fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    //};

    var AbsentSet = {
        label: 'Absent',
        data: Absent,
        bars: bar_options
    }

    var MLCountSet = {
        label: "ML Employee",
        data: MLCount,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    var NWCountSet = {
        label: "NW Employee",
        data: NWCount,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };

    var totalSet = {
        label: 'Attendance Rate',
        data: Percentage,
        lines: line_options,
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
    //data = [PresentSet, AbsentSet, totalSet];
    var columncount = 0;
    var colored;
    var data = [];
    if ($("#Shift").val() == "Day" || $("#Shift").val() == "Night") {
        data.push(PresentSet);
        data.push(AbsentSet);
        data.push(MLCountSet);
        data.push(NWCountSet);
        //data.push(PresentInactiveSet);
        data.push(totalSet);
        columncount = 5;
        colored = ['#4E8EFF', '#FF6666', '#04B404', '#929495', 'red']
    }
    else {
        data.push(PresentSet);
        data.push(AbsentSet);
        data.push(MLCountSet);
        data.push(NWCountSet);
        data.push(totalSet);
        columncount = 5;
        colored = ['#4E8EFF', '#FF6666', '#04B404', '#929495', 'red']

    }
    var tickis = finalticks;//MonthDay;//finalticks2[0];
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
        tooltipOpts: {
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },


        colors: colored,
        legend: {
            noColumns: columncount,
            container: $("#chartLegend")
        }
    }

    var holder = $('#ManpowerARtbl');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[columncount - 1].data, function (i, el) {
            var o = p.pointOffset({ x: i, y: el[1], yaxis: 2 });

            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1].toFixed(0) + '%</div>').css({
                    position: 'absolute',
                    left: o.left + 20,
                    top: o.top - 15,
                    display: 'none',
                    color: "red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }


}

function GraphStartAbsentRate_Yearly(datahere) {
    var finalticks = [];
    var TotalDayAbsent = [];
    var AbsentPercentDay = [];
    var TotalNightAbsent = [];
    var AbsentPercentNight = [];
    var TotalNoSchedAbsent = [];
    var AbsentPercentNoSched = [];

    var TotalAbsentPercent = [];


    var Iterator = 1;
    var i = "";
    datahere.forEach(function (x) {

        var Tickshere = [Iterator, x.YEAR];
        var TotalDayAbsentdata = [Iterator, x.TotalDayAbsent];
        var AbsentPercentDaydata = [Iterator, x.AbsentPercentDay];
        var TotalNightAbsentdata = [Iterator, x.TotalNightAbsent];
        var AbsentPercentNightdata = [Iterator, x.AbsentPercentNight];
        var TotalNoSchedAbsentdata = [Iterator, x.TotalNoSchedAbsent];
        var AbsentPercentNoScheddata = [Iterator, x.AbsentPercentNoSched];
        var TotalAbsentPercentdata = [Iterator, x.TotalAbsentPercent];

        TotalDayAbsent.push(TotalDayAbsentdata);
        AbsentPercentDay.push(AbsentPercentDaydata);
        TotalNightAbsent.push(TotalNightAbsentdata);
        AbsentPercentNight.push(AbsentPercentNightdata);
        TotalNoSchedAbsent.push(TotalNoSchedAbsentdata);
        AbsentPercentNoSched.push(AbsentPercentNoScheddata);
        TotalAbsentPercent.push(TotalAbsentPercentdata);
        finalticks.push(Tickshere);
        Iterator++;
    });




    var data = [], chartOptions;
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
    var nosched = TotalNoSchedAbsent
    var noschedSet = {
        label: 'No Shift',
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


    var night = TotalNightAbsent
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
        yaxis: 1
    }
    var day = TotalDayAbsent
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

    var total = TotalAbsentPercent
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
            fillColor: "#FF2020",
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
            fillColor: "#FF2020",
            lineWidth: 1
        },
        stack: false,
        yaxis: 2,

    }

    var noSchedpercent = AbsentPercentNoSched
    var noschedpercentSet = {
        label: 'Absent Night percent',
        data: noSchedpercent,
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


    var columncount = 0;
    var colored;
    switch ($("#Shift").val()) {
        case "":
            data.push(totalSet);
            data.push(nightSet);
            data.push(daySet);
            data.push(noschedSet);
            colored = ['red', '#4E8EFF', '#FD8D86', '#929495']
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
            colored = ['red', '#FD8D86']
            columncount = 2;
            break;
        case "NoSched":
            data.push(noschedpercentSet);
            data.push(noschedSet);
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

}

function GraphStartLeaveBreakdown_Yearly(datahere) {
    var finalticks = [];
    //var LeaveType = [];
    var HeadCount = [];
    var Iterator = 1;

    var VLLeave = [];
    var SLLeave = [];
    var MLLeave = [];
    var ELLeave = [];
    var UNKLeave = [];

    $.each(datahere, function (ii, leavedata) {

        var Tickshere = [Iterator,ii];

        $.each(leavedata, function (iii, leavedataType) {


            switch (leavedataType.LeaveType) {
                case "SL":
                    var HeadCountdata = [Iterator, leavedataType.TotalHeadcount];
                    SLLeave.push(HeadCountdata);
                    break;
                case "VL":
                    var HeadCountdata = [Iterator, leavedataType.TotalHeadcount];
                    VLLeave.push(HeadCountdata);
                    break;
                case "ML":
                    var HeadCountdata = [Iterator, leavedataType.TotalHeadcount];
                    MLLeave.push(HeadCountdata);
                    break;
                case "EL":
                    var HeadCountdata = [Iterator, leavedataType.TotalHeadcount];
                    ELLeave.push(HeadCountdata);
                    break;
                case "UNK":
                    var HeadCountdata = [Iterator, leavedataType.TotalHeadcount];
                    UNKLeave.push(HeadCountdata);
                    break;
            };

        });
        finalticks.push(Tickshere);
        Iterator++;
    });

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

    var MLSet = {
        label: "ML Rate",
        data: MLLeave,
        bars: bar_options,
        stack: true
    };

    var ELSet = {
        label: "ML Rate",
        data: ELLeave,
        bars: bar_options,
        stack: true
    };

    var UNKSet = {
        label: "UNK Rate",
        data: UNKLeave,
        bars: bar_options,
        stack: true
    };
    data = [VLSet, SLSet, MLSet, ELSet, UNKSet];//[VLSet,UNKSet, totalSet, Overalltotal];
    var tickis = finalticks;
    function degreeFormatter4(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxes: [
            {
                /* First y axis */
                //interval: 1
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

        shadowSize: 0,
        tooltip: true,

        tooltipOpts: {
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },
        legend: {
            noColumns: 7,
            container: $("#chartLegend5")
        }
    }

    var holder = $('#stacked-absent-breakdown');
    var ss = datahere.length;
    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[2].data, function (i, el) {
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

function GraphStartGET_AWOLandResignrate_Yearly(datahere) {
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
        var Tickshere = [Iterator, ii];
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
            percount += statusdataType.TotalPer;
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
        points: {
            show: true,
            radius: 4,
            fill: true,
            lineWidth: 1
        },
        yaxis: 1,
        stack: false
    }

    var PerSet = {
        label: 'AWOL/Resigned Rate',
        data: PercentRate,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            lineWidth: 1
        },
        yaxis: 2,
        stack: false
    }


    data = [PerSet, TotaloutSet, INACTIVESet, AWOLSet, RESIGNEDSet];
    var tickis = finalticks;
    function degreeFormatter3(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
        //return v + "%";
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

        //colors: ['#4f81bd', '#77933c', '#FF2020', '#77233c'],
        legend: {
            noColumns: 4,
            container: $("#chartLegend3")
        }
    }

    var holder = $('#awolrateGraph');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[0].data, function (i, el) {
            var o = p.pointOffset({ x: el[0], y: el[1], yaxis: 2 });

            if (!isNaN(el[1])) {
                var va = "";
                try {
                    va = el[1].toFixed(0);
                }
                catch (err) {
                    va = 0;
                }


                $('<div class="data-point-label">' + va + '%</div>').css({
                    position: 'absolute',
                    left: o.left,
                    top: o.top,
                    display: 'none',
                    color: "red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }
}

function GraphStartOTrate_Yearly(datahere) {
    var finalticks = [];
    var HeadCount = [];
    var OTHours = [];
    var Iterator = 1;
    var i = "";

    datahere.forEach(function (x) {
        var Tickshere = [Iterator, x.Year];
        var OTHoursdata = [Iterator, x.TotalOT.toFixed(1)];
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
        yaxes: [
            {
                position: "left",  /* left or right */

                interval: 0.5


            },
            {
                position: "right",  /* left or right */

                interval: 1

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
                    top: o.top,
                    display: 'none',
                    color: "red"
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });

    }
  
}