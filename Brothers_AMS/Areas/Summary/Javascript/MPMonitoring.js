$(function () {

    var d = new Date();

    var date = d.getDate();
    var month = d.getMonth() + 1; // Since getMonth() returns month from 0-11 not 1-12
    var year = d.getFullYear();
    var lastDay = new Date(year, month, 0).getDate();

    var dateStr = month + "/1/" + year;
    var dTo = month + "/" + lastDay + "/" + year;
    $("#DateFrom").datepicker().datepicker("setDate", dateStr);
    $("#DateTo").datepicker().datepicker("setDate", dTo);
    
    Dropdown_select('Shift', "/Helper/GetDropdown_Schedule");
    Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    
    $(".fil").on("change", function () {

        var start = Date.parse($("#DateFrom").val());
        var end = Date.parse($("#DateTo").val());
        var days = (end - start) / 1000 / 60 / 60 / 24;
        if (days > 62) {
            swal("Graph limit exceeded");
        }
        else {
            Initializepage();
        }

    });


    //graphstart();
    
    $('#Line').on('change', function (e) {
        Dropdown_select("Process", "/Helper/GetDropdown_Skills?LineProcessTeam=" + $('#Line').val());
    });

    $("#Section").on('change', function () {
        $.ajax({
            url: '/Helper/GetSuperSection?section='+$("#Section").val(),
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
             
                    $('#Section').val(returnData.usersection.GroupSection);
                    Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.CostCode + "&RFID=" + "&GroupSection=" + $('#Section').val());
            
            }
        });
    })

    setTimeout(function () { GetUser(); }, 1500);
    
})




function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section').val(returnData.usersection);
            Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            Initializepage();
        }
    });
}

function Initializepage() {
    // GraphData();
    var Filter = {
        DateFrom: $("#DateFrom").val(),
        DateTo: $("#DateTo").val(),
        Section: $("#Section").val(),
        Shift: $("#Shift").val(),
        Line: $("#Line").val(),
        Process: $("#Process").val()
    }
    $('#MPTable').DataTable({
        ajax: {
            url: '../MPMonitoring/GetManPowerList',
            type: "POST",
            datatype: "json",
            data: Filter 
        },
        dom: 'Bfrtip',
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ],
        lengthMenu: [6000, 200, 300, 500],
        //pagelength: 1000,
        //lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
        lengthChange: false,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        initComplete: function () {
            GetManPowerGraph();
        },
        language: {
            "processing": "processing... please wait"
        },
        destroy: true,
        columns: [
            {
                title: "Date", data: function (x) {
                     return (x.InDate != null) ? moment(x.InDate).format("MM/DD/YYYY") : ""
                 }, name: "InDate"
            },
            { title: "Time In", data: "TimeInNew" },
            { title: "Time Out", data: "TimeOutNew" },
            { title: "Shift", data: "ShiftNew" },
            { title: "Line", data: "LineNew" },
            { title: "Process", data: "Skill" },
            {
                title: "Employee Name", data: function (x) {
                    var certified = "";
                    if (x.NEWCOLOR == "Green") {
                        certified = 'Certified';
                    }
                    else if (x.NEWCOLOR == "Black") {
                        certified = "Orig";
                    }
                    else {
                        certified = 'NotCertified';
                    }
                    return "<label class= '" + certified + "' style='16px !important'>" + x.EmployeeName + "</label>"
                }},
            { title: "Date Hired", data: "DateHired" },
            {
                title: "Date Certified", data: function (x) {
                    return (x.DateCertified != null) ? moment(x.DateCertified).format("MM/DD/YYYY") : "-"
                }, name: "DateCertified"
            },
          
        ],

    });
    
}


function GetManPowerGraph() {
    var Filter = {
        DateFrom: $("#DateFrom").val(),
        DateTo: $("#DateTo").val(),
        Section: $("#Section").val(),
        Shift: $("#Shift").val(),
        Line: $("#Line").val(),
        Process: $("#Process").val()
    }

    $.ajax({
        url: '/MPMonitoring/GetManPowerGraph',
        type: 'POST',
        data:Filter,
        datatype: "json",
        success: function (returnData) {
            for (var x = 0; x < returnData.graphlist.length; x++) {
                returnData.graphlist[x].InDate = moment(returnData.graphlist[x].InDate).format("MM/DD/YYYY")
            }

            var groupedDate = _.mapValues(_.groupBy(returnData.graphlist, 'InDate'),
                         clist => clist.map(InDate => _.omit(InDate, 'InDate')));

            ////console.log(groupedDate);
            graphstart(groupedDate);
        }
    });

}


function formatDate(date) {
   date = new Date(date);
    var monthNames = [
      "Jan", "Feb", "Mar",
      "Apr", "May", "Jun", "Jul",
      "Aug", "Sep", "Oct",
      "Nov", "Dec"
    ];

    var day = date.getDate();
    var monthIndex = date.getMonth();
    var year = date.getFullYear();

    return day + '-' + monthNames[monthIndex];// + ' ' + year;
}

function graphstart(groupedDate) {

    var Certified = [];
    var UnCertified = [];
    var Blacked = [];
    var Hybrid = [];
    var finalticks = [];
    var nonelist = [];
    var Iterator = 0;
    $.each(groupedDate, function (i, arrdata) {
        i = formatDate(i);
        var Tickshere = [Iterator, i];
      
        console.log(Tickshere);
        finalticks.push(Tickshere);
       
        $.each(arrdata, function (ii, value) {
           
            switch (value.TrueColor) {
                case "Black":
                    var Black = [Iterator, value.HeadCount];
                    Blacked.push(Black);
                    break;
                case "Red":
                    var Red = [Iterator, value.HeadCount];
                    UnCertified.push(Red);
                    break;
                case "Yellow":
                    var Yellow = [Iterator, value.HeadCount];
                    Hybrid.push(Yellow);
                    break;
                case "Green":
                    var Green = [Iterator, value.HeadCount];
                    Certified.push(Green);
                    break;
                default:
                    var none = [Iterator, value.HeadCount];
                    Blacked.push(none);
                    break;
            }


        })

        Iterator++;
    });

    var  data, chartOptions;
    data = [
        {
            label: 'Certified',
            data: Certified
        },
        {
            label: 'Not Certified',
            data: UnCertified
        },
        {
            label: 'Original Operator',
            data: Blacked
        },
        {
            label: 'Transfered',
            data: Hybrid
        }

    ];
    console.log(finalticks);
    
    chartOptions = {
       
        xaxis: {
           
            ticks: finalticks,
            rotateTicks: 0
        },
        grid:{
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
            fillColor: { colors: [ { opacity: 1 }, { opacity: 1 } ] }
        },
        shadowSize: 100,
        tooltip: true,
        tooltipOpts: {
            content: '%s: %y'
        },
        content: function (label, xval, yval, flotItem) {
            return label + ' x:' + xval + ' y: ' + yval;
        },
        colors: ['#00F033', '#FF0000', '#C1C1C1', '#FEFB6B'],
    }

    var holder = $('#stacked-vertical-chart');

    if (holder.length) {
        $.plot(holder, data, chartOptions);
    }
}