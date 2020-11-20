$(function () {
  
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
            Line: line,
            Shift: $("#breakd_Shift").val()
        }
        
        LeaveBreakDown();

    })
})


function LeaveBreakDown() {
    //$("#loading_modalD_Leave").modal("show");
    $.ajax({
        url: '/Home/GET_LeaveBreakdown',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var LeaveGroupData = returnData.list;
           
            var groupedDateSet = _.mapValues(_.groupBy(LeaveGroupData, 'DateSet'),
                clist => clist.map(DateSet => _.omit(DateSet, 'DateSet')));

           
            GraphStartLeaveBreakdown(groupedDateSet);
        }

    });
}

function LeaveBreakDown_Department() {
    //$("#loading_modalD_Leave").modal("show");
    $.ajax({
        url: '/Home/GET_LeaveBreakdown_Department',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            var LeaveGroupData = returnData.list;

            var groupedDateSet = _.mapValues(_.groupBy(LeaveGroupData, 'DateSet'),
                clist => clist.map(DateSet => _.omit(DateSet, 'DateSet')));


            GraphStartLeaveBreakdown(groupedDateSet);
        }

    });
}

function GraphStartLeaveBreakdown(datahere) {
    var finalticks = [];
    //var LeaveType = [];
    var HeadCount = [];
    var Iterator = 1;

    var VLLeave = [];
    var SLLeave = [];
    var MLLeave = [];
    var ELLeave = [];
    var UNKLeave = [];
    var ABLeave = [];
    var TOTALout = [];
    $.each(datahere, function (ii, leavedata) {
        var monthdaydata = moment(ii).format("MM/DD/YYYY");
        var newdate = new Date(monthdaydata);
        var i = formatDate(newdate.getDate(), parseInt(month));
        //var mData = [Iterator, i];
        var Tickshere = [Iterator, i];
        var tcount = 0;
        $.each(leavedata, function (iii, leavedataType) {
            
            
            switch (leavedataType.LeaveType) {
                case "SL":
                    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                    SLLeave.push(HeadCountdata);
                    break;
                case "VL":
                    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                    VLLeave.push(HeadCountdata);
                    break;
                case "ML":
                    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                    MLLeave.push(HeadCountdata);
                    break;
                case "EL":
                    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                    ELLeave.push(HeadCountdata);
                    break;
                case "UNK":
                    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                    UNKLeave.push(HeadCountdata);
                    break;
                //case "AB":
                //    var HeadCountdata = [Iterator, leavedataType.HeadCount];
                //    ABLeave.push(HeadCountdata);
                //    break;

            };
            tcount += leavedataType.HeadCount;
        });
        var totalout = [Iterator, tcount];
        finalticks.push(Tickshere);
        TOTALout.push(totalout);
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
        stack:true,
        barWidth: 0.5,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
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
        stack: false,
        
    }
   
    var SLSet = {
        label: "SL Count",
        data: SLLeave,
        bars: bar_options,
        stack: true,
        color:"#DF7401"
    };
   
    var VLSet = {
        label: 'VL Count',
        data: VLLeave,
        bars: bar_options,
        stack: true,
        color: "#4E8EFF"
    }
    
    var MLSet = {
        label: "ML Count",
        data: MLLeave,
        bars: bar_options,
        color:"#04B404",
        stack: true
    };

    var ELSet = {
        label: "EL Count",
        data: ELLeave,
        bars: bar_options,
        stack: true,
        color:"#AF67FF"
    };

    var UNKSet = {
        label: "Absent Count",
        data: UNKLeave,
        bars: bar_options,
        stack: true,
        color: "#FF0000"
    };

    //var ABSet = {
    //    label: "No Leave Count",
    //    data: ABLeave,
    //    bars: bar_options,
    //    stack: true,
    //    color: "#F39D9D"
    //};

    
    data = [TotaloutSet, UNKSet, VLSet, SLSet, MLSet, ELSet];//[VLSet,UNKSet, totalSet, Overalltotal];
  
    var tickis = finalticks;
    function degreeFormatter4(v, axis) {
        return v.toFixed(axis.tickDecimals);
    }
    chartOptions = {
        yaxis:
        {
            min:0
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
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },
        //colors: coloredb,
        legend: {
            noColumns: 7,
            container: $("#chartLegend5")
        },
        
    }
   
    var holder = $('#stacked-absent-breakdown');
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

    Graph5 = true;

    if (Graph1 == true && Graph2 == true && Graph3 == true && Graph4 == true && Graph5 == true) {
        $("#loading_modalD_AttendanceRate").modal("hide");
    }

}