var PresentMagic, DTRMagic, OTMagic, EmpShiftMagic, ETTMagic, ADMagic, TTMagic;
var theDay, theMonth, theYear;
var CountDayABS = 0, CountNightABS = 0;
var generatego = false;

var selectedSection = "";



$(function () {

    
    Dropdown_selectEmpCompany('BIPH_Agency', "/Helper/GetDropdown_Agency");
    Dropdown_selectYear("Year");
    Dropdown_selectMonth("Month");
    $("#DateAdjust").datepicker().datepicker("setDate", new Date());
    GetUser();
    CountDayABS = 0; CountNightABS = 0;
    $("#Section").on("change", function () {
        selectedSection = $("#Section").val();
        generatego = false;
    })
    $("#GetActualTap").on("click", function () {
        window.location.href = '/Summary/Employeetap/Employeetap';

    })
   
    $("#btnAdjustmentDownload").on("click", function () {
        //alert($("#DateAdjust").val());
        var d = new Date($("#DateAdjust").val());
        theDay = d.getDate();
        theMonth = d.getMonth()+1;
        theYear = d.getFullYear();

        window.open('../WorkTimeSummary/ExportAdjust?Month=' + theMonth + "&Year=" + theYear + "&Day=" + theDay + "&Section=" + selectedSection);
    });

    $(".theshow").hide();
    $("#Search").on("click", function () {
        // $("#loading_modal").modal("show")

       
        goagain = true;
        //$(".reloadtbl").removeClass("active");
        //$("#PAB").addClass("active");
        $(".theshow").show();
        generatego = true;
        GenerateDaysname();
        $.ajax({
            url: '../WorkTimeSummary/RemoveCache',
            type: 'POST',
            dataType: 'JSON',
            success: function (returnData) {
                //Initializedpage();
                //InitializepageTT();

                var x = $('ul#tabs').find('li').find('a.active').attr('id');
                switch (x) {
                    case "TabD":
                        $("#tapDetails").show();
                        if (TTMagic) {
                            $("#tapDetails").show();
                        }
                        else {
                            //$("#loading_modal").modal("show");
                            InitializepageTT();
                            TTMagic = true;
                        }
                        break;
                    case "PAB":
                        //var table = $('#AttenanceTbl').DataTable();

                        //if (!table.data().any()) {

                        //    Initializedpage();
                        //}
                        //else {
                            $("#PresentAbsent").show();
                            Initializedpage();
                        //}

                        break;
                    case "DB":
                        if (DTRMagic) {
                            $("#DTRBreak").show();
                        }
                        else {
                            $("#loading_modal").modal("show");
                            Initializedpage_WorkingHours();
                            DTRMagic = true;
                        }
                        break;
                    case "OTM":
                        if (OTMagic) {
                            $("#OTV").show();
                        }
                        else {
                            $("#loading_modal").modal("show");
                            Initializedpage_OTHours();
                            OTMagic = true;
                        }
                        break;
                    case "ES":
                        if (EmpShiftMagic) {
                            $("#EmployeeSchedule").show();
                        }
                        else {
                            $("#loading_modal").modal("show");
                            Initializedpage_EmployeeShift();
                            EmpShiftMagic = true;
                        }

                        break;
                    case "TTi":
                        if (ETTMagic) {
                            $("#EmployeeTime").show();
                        }
                        else {
                            $("#loading_modal").modal("show");
                            Initializedpage_EmployeeTimeinout();
                            ETTMagic = true;
                        }

                        break;
                    case "AD":
                        if (ADMagic) {
                            $("#ABdetails").show();
                        }
                        else {
                            $("#loading_modal").modal("show");
                            Initializepage_AbsentDetails();
                            ADMagic = true;
                        }

                        break;
                }


            }
        });
       
        PresentMagic = DTRMagic = OTMagic = EmpShiftMagic = ETTMagic = ADMagic = TTMagic =false;
        $("#DTRBreak").hide();
        $("#OTV").hide();
        $("#EmployeeSchedule").hide();
        $("#ABdetails").hide();
        $("#tapDetails").hide();
    });
   
    $('#tabs').on('shown.bs.tab', function (event) {
        var x = $(event.target)[0].id;         // active tab
        $(".padhider").hide();
        if (generatego) {
            switch (x) {
                case "TabD":
                    $("#tapDetails").show();
                    if (TTMagic) {
                        $("#tapDetails").show();
                    }
                    else {
                        //$("#loading_modal").modal("show");
                        InitializepageTT();
                        TTMagic = true;
                    }
                    break;
                case "PAB":
                    var table = $('#AttenanceTbl').DataTable();

                    if (!table.data().any()) {

                        Initializedpage();
                    }
                    else {
                        $("#PresentAbsent").show();
                    }

                    break;
                case "DB":
                    if (DTRMagic) {
                        $("#DTRBreak").show();
                    }
                    else {
                        $("#loading_modal").modal("show");
                        Initializedpage_WorkingHours();
                        DTRMagic = true;
                    }
                    break;
                case "OTM":
                    if (OTMagic) {
                        $("#OTV").show();
                    }
                    else {
                        $("#loading_modal").modal("show");
                        Initializedpage_OTHours();
                        OTMagic = true;
                    }
                    break;
                case "ES":
                    if (EmpShiftMagic) {
                       
                        $("#EmployeeSchedule").show();
                    }
                    else {
                        $("#loading_modal").modal("show");
                        Initializedpage_EmployeeShift();
                        EmpShiftMagic = true;
                    }
                  
                    break;
                case "TTi":
                    if (ETTMagic) {
                        $("#EmployeeTime").show();
                    }
                    else {
                        $("#loading_modal").modal("show");
                        Initializedpage_EmployeeTimeinout();
                        ETTMagic = true;
                    }

                    break;
                case "AD":
                    if (ADMagic) {
                        $("#ABdetails").show();
                    }
                    else {
                        $("#loading_modal").modal("show");
                        Initializepage_AbsentDetails();
                        ADMagic = true;
                    }

                    break;
            }
        }
        else {
            generatego = false;
        }
       
        //var y = $(event.relatedTarget).text();  // previous tab

    });
    

    //$("#hrDateFrom").datepicker().datepicker("setDate", new Date());
    //$("#hrDateTo").datepicker().datepicker("setDate", new Date());
    $("#ExportHRdata").on("click", function () {
        if ($("#hrDateFrom").val() != "" && $("#hrDateTo").val() != "") {
           
            window.open('../WorkTimeSummary/ExportHRFormat?Month=' + $("#Month").val() + '&Year=' + $("#Year").val() + '&Section=' + $("#Section").val() + '&Agency=' + $("#BIPH_Agency").val() + '&DateFrom=' + $("#hrDateFrom").val() + '&DateTo=' + $("#hrDateTo").val())
        }
    });

    $("#Exportwsdata").on("click", function () {
        if ($("#wsDateFrom").val() != "" && $("#wsDateTo").val() != "") {
            
            window.open('../WorkTimeSummary/WrongShift?Month=' + $("#Month").val() + '&Year=' + $("#Year").val() + '&Section=' + $("#Section").val() + '&Agency=' + $("#BIPH_Agency").val() + '&DateFrom=' + $("#wsDateFrom").val() + '&DateTo=' + $("#wsDateTo").val() + '&Shift=' + $("#Shift").val())
        }
    });
    //$("#HRExportmodal").modal("show");
});
var table1;
var theDayShift = 0;
var theNightShift = 0;
var dayscountwithoutWK = 0;

var Pcountall = 0;
var Bcountall = 0; //DayShift
var Pcount = 0;
var Bcount = 0; //DayShift
var Ycount = 0;//NightShift
var Ycount = 0;
var MLcount = 0;

function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.usersection != null && returnData.usercost != null) {
                $('#Section').val(returnData.usersection).trigger('change');
                $('#Section').val(returnData.usersection);
            
                selectedSection = returnData.usersection;
                $("#select2-Section-container").text(returnData.usersection);
               // $("#Search").trigger("click");
                $('#Section').prop("disabled", true);
            }
            else {
                $('#Section').prop("disabled", false);
             
            }
                 
       
        }
    });
}

function GetMonth() {
    var d = new Date();
    var n = d.getMonth() +1;
    return n;
}
function GetYear() {
    var d = new Date();
    var n = d.getFullYear();
    return n;
}

function HeaderData() {
    $.ajax({
        url: '../WorkTimeSummary/GETHEADER',
        data: {
            Month: $("#Month").val(),
            Year: $("#Year").val(),
            Section: selectedSection,// $("#Section").val(),
            Agency: $("#BIPH_Agency").val(),
            go: goagain
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            $("#loading_modal").modal("hide");
            $("#DStotal").text(returnData.header.DayShiftCountnow);
            $("#DSper").text(returnData.header.DayShiftper + "%");
            $("#NStotal").text(returnData.header.NightshiftCountnow);
            $("#NSper").text(returnData.header.NightShiftper + "%");
            $("#total").text(returnData.header.DayShiftCountnow + returnData.header.NightshiftCountnow);
            var totalper = returnData.header.DayShiftper + returnData.header.NightShiftper;
            $("#per").text(totalper.toFixed(2) + "%");
            $("#MLDS").text(returnData.header.MLCountDay);
            $("#NWDS").text(returnData.header.NWCountDay);
            $("#MLNS").text(returnData.header.MLCountNight);
            $("#NWNS").text(returnData.header.NWCountNight);
            $("#totalML").text(returnData.header.MLCountDay + returnData.header.MLCountNight);
            $("#totalNW").text(returnData.header.NWCountDay + returnData.header.NWCountNight);
        }
    });
}

function ShowOutput_old(data, day, Sched) {
    dayscountwithoutWK++;
    var today = new Date();
    var dd = today.getDate();//getDate().toString().padStart(2, 0);//String(today.getDate()).padStart(2, '0');
    var mm = today.getMonth()+1;//String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    data = (data == null) ? "" : data;
    today = mm + '/' + dd + '/' + yyyy;
    var Datereg = $("#Month").val() + "/"+day+"/"+$("#Year").val();

    var Weekday = GetResult(day);
    //console.log(data.indexOf('AB'));
   
    if (Date.parse(Datereg) <= Date.parse(today)) {
        if ((Weekday == "Sun" || Weekday == "Sat") && data != "ABS") {
            Pcount++;
            var color = (data.toLowerCase().indexOf('ab') > -1) ? "red" : "green";
            return "<p class='text-" + color + " Adjustbrand' >" + data + "</p>"
        }
        else if ((Weekday == "Sun" || Weekday == "Sat")) {
            dayscountwithoutWK--;
            return "<p class='text-aqua Adjustbrand'>NW</p>"
        }
        else if (data.toLowerCase().indexOf('abs') > -1) {
            if (Sched != null) {
                if (Sched.toLowerCase().indexOf('day') > -1) {
                    Bcount++;
                }
                if (Sched.toLowerCase().indexOf('night') > -1) {
                    Bcount++;
                }
                else {

                }
            }
            data = (data == "ABS") ? "AB" : data;
            
            
            return "<p class='text-red Adjustbrand'>" + data + "</p>"
        }
        else {
            Pcountall++;
         
            if (data != null && data == "P") {
                Pcount++;
               
                return "<p class='text-green Adjustbrand'>" + data + "</p>"
            }
            else {
                //console.log(data.indexOf('HD'));
                if (data.toLowerCase().indexOf('n') > -1) {
                    if (data.indexOf("HD") > -1) { Ycount += parseFloat('.5'); }
                    if (data.indexOf("ML") > -1) { MLcount++; }
                    else { Ycount++;}
                }
                else {
                    if (data.indexOf("HD") > -1) { Bcount += parseFloat('.5'); }
                    if (data.indexOf("ML") > -1) { MLcount++; }
                   
                }
                Pcount++;
                data = (data == "ABS") ? "AB" : data;
                return "<p class='text-green Adjustbrand'>" + data + "</p>"
            }
        }
    }
    else {
        dayscountwithoutWK--;
        return "<p class='text-gray Adjustbrand'>-</p>"

    }
   
}

var taocount = 0;
var goagain = false;
function GetResult(day) {
    var dateString = $("#Month").val() + '-' + day + '-' + $("#Year").val();
    var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    var d = new Date(dateString);
    var dayName = days[d.getDay()];
    return dayName;
}

function daysInMonth(month, year) {
    return new Date(year, month, 0).getDate();
}

function GenerateDaysname(){
    $("#Daysname").empty();
    var loopstr = "";
    for (var x = 1; x <= 31; x++) {
        loopstr += "<td>" + GetResult(x) + "</td>"
    }
    $(".Daysname").empty().append(loopstr);
}

function ShowOutput(data) {
    switch (data) {
        case "EL":
            return "<p class='Adjustbrand' style='color: #AF67FF'>" + data + "</p>"
            break;
        case "HD":
            return "<p class='Adjustbrand' style='color: #E9FF97'>" + data + "</p>"
            break;
        case "SL":
            return "<p class='Adjustbrand' style='color: #DF7401'>" + data + "</p>"
            break;
        case "VL":
            return "<p class='Adjustbrand' style='color: #4E8EFF'>" + data + "</p>"
            break;
        case "NW":
            return "<p class='Adjustbrand' style='color: #929495'>" + data + "</p>"
            break;
        case "AB":
            return "<p class='Adjustbrand' style='color: red'>" + data + "</p>"
            break;
        case "ML":
            return "<p class='Adjustbrand' style='color: #04B404'>" + data + "</p>"
            break;
        case "P(D)":
            return "<p class='Adjustbrand' style='color: green'>" + data + "</p>"
            break;
        case "P(N)":
            return "<p class='Adjustbrand' style='color: green'>" + data + "</p>"
            break;
        case "TR(D)":
            return "<p class='Adjustbrand' style='color: green'>" + data + "</p>"
            break;
        case "TR(N)":
            return "<p class='Adjustbrand' style='color: green'>" + data + "</p>"
            break;
        default:
            return "<p class='Adjustbrand' style='color: gray'>" + data + "</p>"
            break;
    }
}

function Initializedpage() {

   

    $("#loading_modal").modal("show");
    $('#AttenanceTbl').DataTable({
        ajax: {
            url: '../WorkTimeSummary/GeAttendanceMonitoringList',
            data: {
                Month: $("#Month").val(),
                Year: $("#Year").val(),
                Section: selectedSection,// $("#Section").val(),
                Agency: $("#BIPH_Agency").val(),
                go: goagain
            },
            type: "GET",
            datatype: "json",
        },
        ordering:false,
        lengthChange: true,
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        pagelength: 10,
        loadonce: false,
        scrollX: true,
        dom: 'lBfrtip',
        buttons: [
            {
                text: "Excel",
                action: function () {
                    window.open('../WorkTimeSummary/ExportWorktimeSummary_Present?Month=' + $("#Month").val() + '&Year=' + $("#Year").val() + '&Section=' + selectedSection + '&Agency=' + $("#BIPH_Agency").val());

                }
            },
        ],
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        scrollY: "600px",
        //scrollX: "1000px",
        scrollCollapse: true,
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "EmpNo", data: "EmpNo", name: "EmpNo", className: "reloadclass" },
            { title: "EmployeeName", data: "EmployeeName", name: "EmployeeName" },
            { title: "Position", data: "Position", name: "Position"},
            { title: "CostCode", data: "CostCode", name: "CostCode"},
            { title: "Current Schedule", data: "Schedule", visible: true },
            {
                title: "Process", data: function (x) {

                    return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                },
            },
            {
                title: "1", data: function (x) {
                    return ShowOutput(x.C1);
                }
            },
            {
                title: "2", data: function (x) {
                    return ShowOutput(x.C2);
                }
            },
            {
                title: "3", data: function (x) {
                    return ShowOutput(x.C3);
                }
            },
            {
                title: "4", data: function (x) {
                    return ShowOutput(x.C4);
                }
            },
            {
                title: "5", data: function (x) {
                    return ShowOutput(x.C5);
                }
            },
            {
                title: "6", data: function (x) {
                    return ShowOutput(x.C6);
                }
            },
            {
                title: "7", data: function (x) {
                    return ShowOutput(x.C7);
                }
            },
            {
                title: "8", data: function (x) {
                    return ShowOutput(x.C8);
                }
            },
            {
                title: "9", data: function (x) {
                    return ShowOutput(x.C9);
                }
            },
            {
                title: "10", data: function (x) {
                    return ShowOutput(x.C10);
                }
            },
            {
                title: "11", data: function (x) {
                    return ShowOutput(x.C11);
                }
            },
            {
                title: "12", data: function (x) {
                    return ShowOutput(x.C12);
                }
            },
            {
                title: "13", data: function (x) {
                    return ShowOutput(x.C13);
                }
            },
            {
                title: "14", data: function (x) {
                    return ShowOutput(x.C14);
                }
            },
            {
                title: "15", data: function (x) {
                    return ShowOutput(x.C15);
                }
            },
            {
                title: "16", data: function (x) {
                    return ShowOutput(x.C16);
                }
            },
            {
                title: "17", data: function (x) {
                    return ShowOutput(x.C17);
                }
            },
            {
                title: "18", data: function (x) {
                    return ShowOutput(x.C18);
                }
            },
            {
                title: "19", data: function (x) {
                    return ShowOutput(x.C19);
                }
            },
            {
                title: "20", data: function (x) {
                    return ShowOutput(x.C20);
                }
            },
            {
                title: "21", data: function (x) {
                    return ShowOutput(x.C21);
                }
            },
            {
                title: "22", data: function (x) {
                    return ShowOutput(x.C22);
                }
            },
            {
                title: "23", data: function (x) {
                    return ShowOutput(x.C23);
                }
            },
            {
                title: "24", data: function (x) {
                    return ShowOutput(x.C24);
                }
            },
            {
                title: "25", data: function (x) {
                    return ShowOutput(x.C25);
                }
            },
            {
                title: "26", data: function (x) {
                    return ShowOutput(x.C26);
                }
            },
            {
                title: "27", data: function (x) {
                    return ShowOutput(x.C27);
                }
            },
            {
                title: "28", data: function (x) {
                    return ShowOutput(x.C28);
                }
            },
            {
                title: "29", data: function (x) {
                    return ShowOutput(x.C29);
                }
            },
            {
                title: "30", data: function (x) {
                    return ShowOutput(x.C30);
                }
            },
            {
                title: "31", data: function (x) {
                    return ShowOutput(x.C31);
                }
            },

        
            //{
            //    title: "Status", data: function (x) {
            //        if (x.Status.toLowerCase() == "active") {
            //            colorhere = "#33bf7a";
            //        }
            //        else {
            //            colorhere = "#FF9898";
            //        }
            //        return "<button type='button' class='btn btn-sm' style='background-color:" + colorhere + "; color:white;' alt='alert' class='model_img img-fluid' onclick=UpdateStatus('" + x.EmpNo + "')>" +
            //            "<i class='fa fa-user-md'> " + x.Status + " </i>" +
            //            "</button> "
            //    }
            //},

            {
                title: "Present (D&N)", data:"Pcount"
            },
            {
                title: "Absent (D&N)", data: "Bcount"
            },
            {
                title: "Absent (HD)", data: "Ycount"
            },
            {
                title: "Absent (ML)", data: "MLcount"
            },
            {
                title: "Attendance Rate", data: function (x) {
                   
                    var days = x.WD;
                    if ((x.Pcount + x.Bcount + x.Ycount == 0)) {
                        return "0.00%"
                    }
                    else {
                        var Ppercentage = (((x.Pcount) / (x.Pcount + x.Bcount + x.Ycount)) * 100).toFixed(2);
                        return Ppercentage + "%";
                    }
                }
            },



        ],
        initComplete: function () {
            goagain = false;
            HeaderData();
            var table = $('#AttenanceTbl').DataTable();
            var start = 7;

           

            var numDays = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
            for (var x = numDays; x < 31; x++) {
                table.column(x + 7).visible(false);
            }
            for (var x = 1; x <= 31; x++) {
                var daywk = GetResult(x);
                $(table.column(start).header()).text(daywk + '\n' + x);
                start++;
            }
            table.columns.adjust();

            if (!table.data().any()) {
                swal("No Data. Please Select Section");
            }
            else {

            }
            $("#PresentAbsent").show();
            //$(".reloadclass").trigger("click");
            $("#loading_modal").modal("hide");

        },
        drawCallback: function (settings) {
            $("#loading_modal2").modal("hide");
            //var table = $('#AttenanceTbl').DataTable();
            table.columns.adjust();
        },
        fixedColumns: true,
        fixedColumns: {
            leftColumns: 7
            //rightColumns: 1
        },
        destroy: true
    });
    var table = $('#AttenanceTbl').DataTable();
    $('#AttenanceTbl').on('length.dt', function (e, settings, len) {
        console.log('New page length: ' + len);
        $("#loading_modal2").modal("show");
    });

    $('#AttenanceTbl input').unbind();
    $('#AttenanceTbl input').bind('keyup', function (e) {
        if (e.keyCode == 13) {
            $("#loading_modal2").modal("show");
            table.fnFilter($(this).val());
        }
    });
    
}

function GetProcess(EmpNo, CostCode) {
    $.ajax({
        type: 'POST',
        url: '../WorkTimeSummary/GetAttendanceEmployeeProcess',
        data: {
                EmpNo: EmpNo,
                CostCode: CostCode
        },
        dataType: 'json',
        success: function (returnData) {
            var processtbl = "";
            $("#processtbl").html("");
            for (var x = 0; x < returnData.list.length; x++)
            {
                if (returnData.list[x].Line == null) {
                    processtbl += "<tr>" +
                                 "<td></td>" +
                                 "<td></td>" +
                                "</tr>";
                }
                else {
                    processtbl += "<tr>" +
                                  "<td>" + returnData.list[x].Line + "</td>" +
                                  "<td>" + returnData.list[x].Skill + "</td>" +
                                 "</tr>";
                }
                
            }
           
            $("#processtbl").append(processtbl);
            $("#ProcessModal").modal("show");
        }


    });

}

function UpdateLeave(Date, EmpNo) {
    //$("#DateLeavemodal").modal("show");
    //console.log(Date + EmpNo);

}

function UploadAdjustment() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("btnAdjustmentUpload").files[0];
    files.append('files[0]', file1);
    files.append('DateChange', $("#DateAdjust").val());
    $.ajax({
        type: 'POST',
        url: '../WorkTimeSummary/UploadAdjustment',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide")
                
                swal("Adjustment Updated");
                setTimeout(function () { $("#Search").trigger("click"); }, 2000);
                
                $("#btnAdjustmentUpload").val("");
                //Initializedpage();
            }
            else {
                $("#loading_modal").modal("hide")

                swal("Adjustment Failed. Please recheck upload file");

            }
        },
        error: function (error) {

        }
    });
}

function PerDaychecker(Month, Year, Day, EmpNo) {

    $.ajax({
        url: '../WorkTimeSummary/CheckLeave',
        data: {
            Month: Month,
            Year: Year,
            Day: Day,
            EmpNo: EmpNo
        },
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        //console.log(data);
    }).fail(function (xhr, textStatus, errorThrown) {
      //  console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectYear(id) {
    var option = '<option value="">--SELECT--' + getlongadjWorktimeSelect() + '</option>';
    $('#' + id).html(option);
    for (y = 2000; y <= 2500; y++) {
        
        option = '<option value="' + y + '">' + y + getlongadjWorktimeSelect() + '</option>';
        $('#' + id).append(option);
    }
    $("#Year").val(GetYear()).trigger('change');
}

function Dropdown_selectMonth(id) {
    var option = '<option value="">--SELECT--' + getlongadjWorktimeSelect() + '</option>';
    var monthArray = new Array();
    monthArray[1] = "January";
    monthArray[2] = "February";
    monthArray[3] = "March";
    monthArray[4] = "April";
    monthArray[5] = "May";
    monthArray[6] = "June";
    monthArray[7] = "July";
    monthArray[8] = "August";
    monthArray[9] = "September";
    monthArray[10] = "October";
    monthArray[11] = "November";
    monthArray[12] = "December";
    for (m = 1; m <= 12; m++) {
        option = '<option value="' + m + '">' + monthArray[m] + getlongadjWorktimeSelect() + '</option>';
        $('#' + id).append(option);
    }
    $("#Month").val(GetMonth()).trigger('change');
}