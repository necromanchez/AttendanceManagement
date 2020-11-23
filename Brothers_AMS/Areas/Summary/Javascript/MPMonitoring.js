var d = new Date();

var date = d.getDate();
var month = d.getMonth() + 1;
var year = d.getFullYear();
var lastDay = new Date(year, month, 0).getDate();
var dateStr = month + "/1/" + year;
var dTo = month + "/" + date + "/" + year;
var selectedSection = "";


$(function () {
    $(".headspin").hide();
    $("#DateFrom").datepicker().datepicker("setDate", dateStr);
    $("#DateTo").datepicker().datepicker("setDate", dTo);
    //Initializepage();
    Dropdown_selectCertified('Certified');
    Dropdown_selectMPMainShift('Shift', "/Helper/GetDropdown_ScheduleReports");
    Dropdown_selectMPMain2('Section', "/Helper/GetDropdown_SectionAMS");
    GetUser()
    //$("#Generatech").on("click", function () {
    $(".fil").on("change",function(){
        //$("#loading_modal").modal("show");
        var start = Date.parse($("#DateFrom").val());
        var end = Date.parse($("#DateTo").val());
        var days = (end - start) / 1000 / 60 / 60 / 24;
        if (days > 62) {
            swal("Graph limit exceeded");
            $("#loading_modal").modal("hide")
        }
        else {
            //Initializepage();
        }

    });

    $("#Search").on("click", function () {

        $.ajax({
            url: '/MPMonitoring/RemoveCache',
            type: 'POST',
            datatype: "json",
            success: function (returnData) {

                Initializepage();

            }

        });


    });

    //graphstart();

    $('#Line').on('change', function (e) {

        //$("#select2-Line-container").text($("#Line").val());
        
        Dropdown_selectMPMainProcess("Process", "/Helper/GetDropdown_Skills?LineProcessTeam=" + $('#Line').val());
    });

    $("#Section").on('change', function () {
        $.ajax({
            url: '/Helper/GetSuperSection?section=' + $("#Section").val(),
            type: 'POST',
            datatype: "json",
            success: function (returnData) {

                $('#Section').val(returnData.usersection.GroupSection);
                selectedSection = returnData.usersection.GroupSection;
                //$("#select2-Section-container").text(returnData.usersection);
                Dropdown_selectMPMainLine('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.CostCode + "&RFID=" + "&GroupSection=" + $('#Section').val());

              
            }
        });
        //document.getElementById("select2-Section-container").style.whiteSpace = "nowrap";

     
            //$("#select2-Section-container").text($("#Section").val());


    })

  
})

function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.usersection != null && returnData.usercost != null) {
                $('#Section').val(returnData.usersection);
                $("#select2-Section-container").text(returnData.usersection);
                Dropdown_selectMPMainLine('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
                selectedSection = returnData.usersection;
                Initializepage();
            }
           
        }
    });
}

function Initializepage() {
    // GraphData();
    $(".headspin").show();
    $("#loading_modal").modal("show")
    var Filter = {
        DateFrom: $("#DateFrom").val(),
        DateTo: $("#DateTo").val(),
        Section: selectedSection,// $("#Section").val(),
        Shift: $("#Shift").val(),
        Line: $("#Line").val(),
        Process: $("#Process").val(),
        Certified: $("#Certified").val()
    }

    
        $('#MPTable').DataTable({
            ajax: {
                url: '/Summary/MPMonitoring/GetManPowerList',
                type: "POST",
                datatype: "json",
                data: Filter
            },
            dom: 'lBfrtip',
            buttons: [
                {
                    text: "Excel",
                    action: function () {
                        window.open('/Summary/MPMonitoring/ExportMP?Section=' + selectedSection);
                       
                    }
                },
            ],
            ordering: false,
            lengthMenu: [[10, 50, 100], [10, 50, 100]],
            lengthChange: true,
            scrollX: true,
            //scrollCollapse: true,
            scrollY: "600px",
            serverSide: "true",
            order: [0, "asc"],
            sorting:true,
            initComplete: function () {
             
                $('.dataTables_filter input').addClass('form-control form-control-sm');
                //$("#loading_modal").modal("hide");
                GetManPowerGraph();
            },
            processing: "true",
            language: {
                "processing": "processing... please wait"
            },
            destroy: true,
            columns: [
                {   title: "No", data: "Rownum", name: "Rownum" },
                {
                    title: "Date", data: "InDate", name: "InDate"
                },
                {   title: "Time In", data: "TimeIn", name: "TimeIn" },
                {
                    title: "Date Out", data:"InDateOut" , name: "InDateOut"
                },
                {   title: "Time Out", data: "TimeOut", name: "TimeOut" },
                {
                    title: "Shift", data: function (x) {
                        var certified = "Orig";
                        if (x.ChangeShift == "Green") {
                            return "<label class= 'Certified' style='16px !important;color:green' data-toggle='tooltip' title='Original Shift: "+x.OrigShift+"'>" + x.Shift + "</label>"
                            //return "<a href='#' data-toggle='tooltip' title='Hooray!'>Hover over me</a>"
                        }
                        else {
                            return "<label class= 'Orig' style='16px !important'>" + x.Shift + "</label>"
                        }

                       
                    }, name: "Shift" },
                {   title: "Line", data: "Line", name: "Line" },
                {   title: "Process", data: "Skill", name: "Skill" },
                {   title: "Employee No", data: "EmpNo", name: "EmpNo" },
                {
                    title: "Employee Name", data: function (x) {
                        var certified = "";
                        if (x.TrueColor == "Green") {
                            certified = 'Certified';
                        }
                        else if (x.TrueColor == "Black" || x.Skill == "No Process") {
                            certified = "Orig";
                        }
                        else {
                            certified = 'NotCertified';
                        }
                        return "<label class= '" + certified + "' style='16px !important'>" + x.EmployeeName + "</label>"
                    }
                },
                {   title: "Date Hired", data: "Date_Hired", name: "Date_Hired"},
                {
                    title: "Date Registered", data: "DateCertified", name: "DateCertified"
                },
                {   title: "Status", data: "Status", name: "Status" },
            ],
            drawCallback: function (settings) {
                $("#loading_modal").modal("hide");
                var table = $('#MPTable').DataTable();
                table.columns.adjust();
            },

        });
    var table = $('#MPTable').DataTable();
    $('#MPTable').on('length.dt', function (e, settings, len) {
        console.log('New page length: ' + len);
        $("#loading_modal").modal("show");
    });

   
}


function GetManPowerGraph() {
    var Filter = {
        DateFrom: $("#DateFrom").val(),
        DateTo: $("#DateTo").val(),
        Section: selectedSection,// $("#Section").val(),
        Shift: $("#Shift").val(),
        Line: $("#Line").val(),
        Process: $("#Process").val(),
         Certified: $("#Certified").val()
    }

    $.ajax({
        url: '/MPMonitoring/GetManPowerGraph',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
            $(".headspin").hide();
            for (var x = 0; x < returnData.graphlist.length; x++) {
                returnData.graphlist[x].InDate = moment(returnData.graphlist[x].InDate).format("MM/DD/YYYY")
            }

            var groupedDate = _.mapValues(_.groupBy(returnData.graphlist, 'InDate'),
                         clist => clist.map(InDate => _.omit(InDate, 'InDate')));

            ////console.log(groupedDate);
            graphstart(groupedDate);
            $("#loading_modal").modal("hide");
           
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
    var OverallCount = [];
    var finalticks = [];
    var nonelist = [];
    var Iterator = 0;
    $.each(groupedDate, function (i, arrdata) {
        i = formatDate(i);
        var Tickshere = [Iterator, i];

        finalticks.push(Tickshere);
        var overallcounter = 0;
        $.each(arrdata, function (ii, value) {

            switch (value.TrueColor) {
                case "Black":
                    var Black = [Iterator, value.HeadCount];
                    Blacked.push(Black);
                    overallcounter += value.HeadCount;
                    break;
                case "Red":
                    var Red = [Iterator, value.HeadCount];
                    UnCertified.push(Red);
                    overallcounter += value.HeadCount;
                    break;
                case "Yellow":
                    var Yellow = [Iterator, value.HeadCount];
                    Hybrid.push(Yellow);
                    overallcounter += value.HeadCount;
                    break;
                case "Green":
                    var Green = [Iterator, value.HeadCount];
                    Certified.push(Green);
                    overallcounter += value.HeadCount;
                    break;
                default:
                    var none = [Iterator, value.HeadCount];
                    Blacked.push(none);
                    break;
            }


        })
        var fin = [Iterator, overallcounter];
        OverallCount.push(fin);
        Iterator++;
    });

    var line_options = {
        show: true,
        lineWidth: 0,
        fill: false,
        fillColor: {
            colors: [{
                opacity: 0.0
            }, {
                opacity: 0.0
            }]
        }
    };

    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.6,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    var data, chartOptions;

    var stack1 = {
        label: 'Certified',
        data: Certified,
        stack: true,
        fill: true,
        bars: bar_options
    };
    var stack2 = {
        label: 'UnCertified',
        data: UnCertified,
        stack: true,
        fill: true,
        bars: bar_options
    };

    var stack3 = {
        label: 'Original Operator',
        data: Blacked,
        stack: true,
        fill: true,
        bars: bar_options
    };
    var stack4 = {
        label: 'Transfer',
        data: Hybrid,
        stack: true,
        fill: true,
        bars: bar_options,
        fillColor: { colors: [{ opacity: 0 }, { opacity: 0 }] }
    };

    var line = {
        label: '',
        data: OverallCount,
        xaxis: 1,
        stack: false,
        lines: line_options,
        points: {
            radius: 0,
            show: true
        },
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] }
    };
    var dataset = [stack1, stack2, stack3, stack4, line];


    chartOptions = {

        xaxis: {

            ticks: finalticks,
            rotateTicks: 0
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
            content: '%s: %y'
        },

        content: function (label, xval, yval, flotItem) {
            return label + ' x:' + xval + ' y: ' + yval;
        },
        colors: ['#00F033', '#FF0000', '#C1C1C1', '#FEFB6B', '#000000'],
        //legend: {
        //    //position: "ne" or "nw" or "se" or "sw"
        //    position:"se"
        //}
        legend: {
            noColumns: 4,
            container: $("#chartLegend")
        }
    }

    var holder = $('#stacked-vertical-chart');


    if (holder.length) {
        var p =$.plot(holder, dataset, chartOptions); 
        $.each(p.getData()[4].data, function (i, el) {
            var o = p.pointOffset({ x: el[0], y: el[1] });
            $('<div class="data-point-label">' + el[1] + '</div>').css({
                position: 'absolute',
                left: o.left- 20,
                top: o.top - 20,
                display: 'none'
            }).appendTo(p.getPlaceholder()).fadeIn('slow');
        });
    }
    

    

}


function Dropdown_selectMPMain(id, url) {
    var option = '<option value="">--SELECT--' + getlong() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlongadj2() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        GetUser();

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });


    //var option = '<option value="">--SELECT--</option>';
    //$('#' + id).html(option);
    //$.ajax({
    //    url: url,
    //    type: 'GET',
    //    dataType: 'JSON',
    //}).done(function (data, textStatus, xhr) {
    //    $.each(data.list, function (i, x) {
    //        option = '<option value="' + x.value + '">' + x.text +'</option>';

    //        //$('.selectpicker').selectpicker('refresh');
    //        $('#' + id).append(option);
    //    });
    //    GetUser();

    //}).fail(function (xhr, textStatus, errorThrown) {
    //    console.log(errorThrown, textStatus);
    //});
}



function Dropdown_selectCertified(id) {
    var option = '<option value="">All' + getlong() + '</option>';
    var daa = ["Certified", "Uncertified"];
    $('#' + id).html(option);
   
        $.each(daa, function (i, x) {
            option = '<option value="' + x + '">' + x + getlong() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
    
}