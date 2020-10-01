var $document = $(document);
var thetime;
var selectedemployee;
var mode = "IN";
var currentSection = "";
var all = false;
var val;
var timer;
(function () {
  
    $("#empDetails").hide();
    $("#requestrow").hide();
    GetComip();
    $("#loading_modal2").modal("show")

    $("#togBtn").trigger("click");
    $("#togBtn").on("click", function () {
        $("#IDno").focus();
        if (all) {
            all = false;
        }
        else {
            all = true;
        }
        var e = $.Event("keypress", { which: 13 });
        $('#IDno').trigger(e);
      
    })

    var delay = (function () {
        var timer = 0;
        return function (callback, ms) {
            clearTimeout(timer);
            timer = setTimeout(callback, ms);
        };
    })();

    $("#IDno").on("input", function () {
        delay(function () {
            if ($("#IDno").val().length < 4) {
                $("#IDno").val("");
            }
        }, 20);
    });

    $("#INN").click();
    $(".sidebar-mini").addClass("sidebar-collapse");
    $(".main-sidebar").hide();
    $(".sidebar-toggle").removeClass("sidebar-toggle");
    $(".navbar-custom-menu").hide();
    $(".OC_Process").hide();
    $("#Line").prop("disabled", true);

    $("#IDno").focus();

    var clock = function () {
        clearTimeout(timer);

        $.ajax({
            url: '/TimeInandOut/GetServerDate',
            type: "POST",
            datatype: "json",
            success: function (returnData) {
                date = moment(returnData.thed).format("MM/DD/YYYY HH:mm:ss");//returnData.thed;//new Date();
                date = new Date(date);
                hours = date.getHours();
                minutes = date.getMinutes();
                seconds = date.getSeconds();
                dd = (hours >= 12) ? 'PM' : 'AM';
                hours = (hours > 12) ? (hours - 12) : hours
                timer = setTimeout(clock, 1000);
                var minut = (Math.floor(minutes) < 10) ? "0" + Math.floor(minutes) : Math.floor(minutes);
                $('#Timehere').html(Math.floor(hours) + ':' + minut + ' ' + dd)

                var dateStr = date;
                var day = getDayName(dateStr, "en-US");
                $('#WeekDay').html(day)
               
                thetime = Math.floor(hours) + ':' + minut + ' ' + dd;
                val = date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear();
                $('#datess').html(formatDate(date));
            }
        });

        
    };
    clock();
    $document.bind('contextmenu', function (e) {
        e.preventDefault();
    });
    $(".logo-mini").on("click", function () {
        location.href = "/Home/Index";
    })
   
    
    $('#IDno').keypress(function (event) {
        var keycode = (event.keyCode ? event.keyCode : event.which);
        if (keycode == '13') {
            var ss = $("#IDno").val();
            $("#Line").prop("disabled", false);
            $.ajax({
                url: '/TimeInandOut/GetEmployeeDetails',
                data: {
                    RFID: $("#IDno").val(),
                    //LineID: $("#Line").val()
                },
                type: 'GET',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.employee != null && returnData.employee != "") {
                        
                        if (returnData.HRInactive) {
                            swal("Employee HR Status Inactive, Please contact your Section's PIC");
                        }


                        if (all == false) {
                            Dropdown_select2('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.CostCode + "&RFID=" + $("#IDno").val());

                        }
                        else {
                            Dropdown_select2('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.CostCode + "&RFID="+"");

                        }
                        //$("#Line").trigger("change");
                        currentSection = returnData.CostCode;
                        GetAttendanceDetail("go");
                        selectedemployee = returnData.employee;
                        console.log(returnData.employee);
                        var photo = (returnData.employee.EmployeePhoto == '') ? '/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg' : "/PictureResources/EmployeePhoto/" + returnData.employee.EmployeePhoto;
                        $("#employeephoto").attr({ "src": photo });
                        $("#namae").text(returnData.employee.First_Name + " " + returnData.employee.Family_Name);
                        $("#Position").text(returnData.employee.Position);
                        $("#Status").text(returnData.employee.Status);
                        $("#EmpNumber").text(returnData.employee.EmpNo);
                        $("#Section").text(returnData.employee.Section);
                        $("#Company").text(returnData.employee.Company);

                        var Schedulename = "";
                        if (returnData.ScheduleName == null) {
                            Schedulename = "No Schedule Assigned";
                            $("#Schedulename").css('color', 'red');
                        }
                        else {
                            Schedulename = returnData.ScheduleName;
                        }
                        $("#Schedulename").text(Schedulename);
                        $("#empDetails").show();
                        $("#TimeIns").text(thetime);
                        if (mode == "OUT") {
                            if (returnData.employee.Status.toUpperCase() == "ACTIVE") {
                                selectprocess(0);
                            }
                            
                        }

                        if(returnData.employee.First_Name == "undefined")
                        {
                            $('#IDno').val("");
                            $("#IDno").focus();
                            swal("Please Tap in Again");
                           
                            
                        }

                        setTimeout(function () {
                            location.reload();
                        }, 300000);

                    }
                    else {
                        swal("Employee does not exist");
                        $("#IDno").val("");
                        $("#namae").text("");
                        $("#Position").text("");
                        $("#Status").text("");
                        $("#TimeIns").text("");
                        $("#employeephoto").attr({ "src": "/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg" });

                    }
                }
            });
        }
    });


    $("#Line").on("change", function () {
        $(".OC_Process").show();
        $.ajax({
            url: '/TimeInandOut/GetProcesses',
            data: {
                LineID: $("#Line").val(),
                RFID: $("#IDno").val()
            },
            type: 'GET',
            datatype: "json",
            success: function (returnData) {
                var theprocessList = "";
                var theprocessList_dis = "";
                $('#theprocessList').html('');
                $('#theprocessList_Active').html('');
                for (var x = 0; x < returnData.Skilllist.length; x++) {
                    var logohere = (returnData.Skilllist[x].SkillLogo == null) ? "no-logop.png" : returnData.Skilllist[x].SkillLogo;
                    var str = returnData.Skilllist[x].Skill;
                    var iffull = (returnData.Skilllist[x].CurrentCount == returnData.Skilllist[x].Count) ? "disabled" : "";
                    var grayout = (returnData.Skilllist[x].CurrentCount == returnData.Skilllist[x].Count) ? "#CECECE" : "";
                    //if (str.length > 10) str = str.substring(0, 10);
                    theprocessList += "<div class='input-container'>" +
                                            "<input id='" + returnData.Skilllist[x].ID + "' class='radio-button pots' type='radio' name='skills' onclick='selectprocess(" + returnData.Skilllist[x].ID + ")' " + iffull + "/>" +
                                            "<div class='radio-tile' style=background-color:" + grayout + "> <label for='walk' class='radio-tile-label'>IMP:" + returnData.Skilllist[x].CurrentCount + " - " + returnData.Skilllist[x].Count + "</label>" +
                                            //"<label for='walk' class=''style='padding-top:5px'>Happy</label>"+
                                                "<div class='icon walk-icon'>" +

                                                    "<img class='forimage' src='/PictureResources/ProcessLogo/" + logohere + "' />" +
                                                "</div>" +
                                                "<label for='walk' class='radio-tile-label break-word' style='width:100px'>" + str + "</label>" +
                                            "</div>" +
                                        "</div>"


                }
                for (var x = 0; x < returnData.UnSkilllist.length; x++) {
                    var str = returnData.UnSkilllist[x].Skill;
                    var logohere = (returnData.UnSkilllist[x].SkillLogo == null) ? "no-logop.png" : returnData.UnSkilllist[x].SkillLogo;
                    var iffull = (returnData.UnSkilllist[x].CurrentCount == returnData.UnSkilllist[x].Count) ? "disabled" : "";
                    var grayout = (returnData.UnSkilllist[x].CurrentCount == returnData.UnSkilllist[x].Count) ? "#CECECE" : "";
                    //if (str.length > 10) str = str.substring(0, 10);
                    theprocessList_dis += "<div class='input-container'>" +
                                            "<input id='" + returnData.UnSkilllist[x].ID + "' class='radio-button pots' type='radio' name='skills' onclick='selectprocess(" + returnData.UnSkilllist[x].ID + ")' " + iffull + "/>" +
                                            "<div class='radio-tile'  style=background-color:" + grayout + "> <label for='walk' class='radio-tile-label break-word'> IMP:" + returnData.UnSkilllist[x].CurrentCount + " - " + returnData.UnSkilllist[x].Count + "</label>" +
                                                "<div class='icon walk-icon'>" +

                                                    "<img class='forimage' src='/PictureResources/ProcessLogo/" + logohere + "' />" +
                                                "</div>" +
                                                "<label for='walk' class='radio-tile-label break-word' style='width:100px'>" + str + "</label>" +
                                            "</div>" +
                                        "</div>"


                }
                $('#theprocessList').append(theprocessList);
                $('#theprocessList_Active').append(theprocessList_dis);
            }
        });
    });

    $("#EmployeePic").on("click", function () {
        $("#picturepackage").click();
    })
    $(".file-upload").on('change', function () {
        var files = new FormData();
        var file1 = document.getElementById("picturepackage").files[0];
        files.append('files[0]', file1);
        files.append('Employee', $("#IDno").val());
        var sa = this;
        $.ajax({
            type: 'POST',
            url: '/TimeInandOut/UploadEmployeePhoto',
            data: files,
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (response) {
                readURL(sa);

            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });

    });
    $("#loading_modal2").modal("hide");

})();

function getDayName(dateStr, locale) {
    var date = new Date(dateStr);
    return date.toLocaleDateString(locale, { weekday: 'long' });
}

function GetComip() {
    $.ajax({
        url: '/TimeInandOut/GetComIP',
        type: "POST",
        datatype: "json",
        success: function (returnData) {
            //alert(returnData.comip);
            $("#comip").html(returnData.comip[1]);
        }
    });

}

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            $('#employeephoto').attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}


function GetAttendanceDetail(re) {
    $('#AttendanceDetails').DataTable({
        ajax: {
            url: '/TimeInandOut/GetAttendanceDetailsList?RFID=' + $("#IDno").val(),
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        searching: false,
        lengthChange: false,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "Employee_RFID", data: "Employee_RFID", visible: false },
            { title: "Line", data: "Line" },
            { title: "Process", data: "Skill" },
            {
                title: "Date", data: function (x) {
                    return (x.TimeIn == null) ? moment(x.TimeOut).format("L") : moment(x.TimeIn).format("L")
                }, name: "Date" },
            {
                title: "Time In", data: function (x) {
                    return (x.TimeIn == null) ? "" : moment(x.TimeIn).format("HH:mm")
                }, name: "TimeIn"
            },
            {
                title: "Time Out", data: function (x) {
                    if (x.TimeOut == null) {
                        return "";
                    }
                    else if (x.TimeOut == "/Date(-2209017600000)/" || x.TimeOut == "/Date(-2208974400000)/") {
                        return "No Out";
                    }
                    else {
                        return moment(x.TimeOut).format("HH:mm");
                    }
                }, name: "TimeOut"
            },

        ],
        initComplete: function () {
            //var trs = document.getElementById("AttendanceDetails").getElementsByTagName("tr");
            //trs[0].className = "currentRow";
            var row = $("#AttendanceDetails_wrapper tr:first-child");
            $(row).addClass("firstrowhere");
            //GetPendinOT();
            if (re == "go") {
                GetPendingTimekeeping();
            }
           
        }
    });
}

function selectprocess(processID) {

    if ($("#IDno").val() != "") {
        $.ajax({
            url: '/TimeInandOut/SaveTimein',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                Employee: selectedemployee,
                LineID: ($("#Line").val() == "") ? 0 : $("#Line").val(),
                ProcessID: processID,
                Mode: mode
            }),
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                //jacob
                console.log(selectedemployee);
                //$('#Line').prop('selectedIndex', 0);
                //msg("Recorded.", "center");
                
                $('#Line').trigger("change");
                GetAttendanceDetail("stop");
                //$('#theprocessList').html('');
                //$('#theprocessList_Active').html('');
                $("#IDno").val("");
                $("#IDno").focus();

                console.log(returnData);
                if (returnData.TheResult == "SameProcess") {

                    swal("Same Process");
                }
                else {
                    SuccessTap();
                }
            }

        });
    }
    else {
        msg("No Valid RFID.", "warning");
    }

}

function modeassign(mod) {
    mode = mod;

    if (mod == "IN") {
        $("#theIN").css("font-size", "2.2rem");
        $("#theOut").css("font-size", "14px");
        $(".innto").css("background-color", "#079ad9");
        $(".outto").css("background-color", "#9d9e9e");
    }
    else {
        $("#theIN").css("font-size", "14px");
        $("#theOut").css("font-size", "2.2rem");
        $(".outto").css("background-color", "#079ad9");
        $(".innto").css("background-color", "#9d9e9e");
    }
    $("#IDno").focus();
}


function formatDate(date) {
    var monthNames = [
      "January", "February", "March",
      "April", "May", "June", "July",
      "August", "September", "October",
      "November", "December"
    ];

    var day = date.getDate();
    var monthIndex = date.getMonth();
    var year = date.getFullYear();

    return monthNames[monthIndex] + ' ' + day + ', ' + year;
}



//Timekeeping

function GetPendingTimekeeping() {
    $('#Pentbl').DataTable({
        ajax: {
            url: '/TimeInandOut/GetPendingTK?RFID=' + $("#IDno").val(),
            type: "POST",
            datatype: "json"
        },
        scrollX: true,
        lengthChange: false,
        serverSide: "true",
        order: [0, "asc"],
        searching: false,
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
             { title: "ID", data: "ID", visible:false },
            { title: "Type", data: "Type" },
            {
                title: "DateFrom", data: function (x) {
                    return (x.DateFrom == null) ? moment(x.DateFrom).format("L") : moment(x.DateFrom).format("L")
                }, name: "DateFrom"
            },
            {
                title: "DateTo", data: function (x) {
                    return (x.DateTo == null) ? moment(x.DateTo).format("L") : moment(x.DateTo).format("L")
                }, name: "DateTo"
            },
            { title: "IN", data: "TimeIn" },
            { title: "OUT", data: "TimeOut" },
            {
                  title: "Action", data: function (x) {
                      return "<button type='button' class='btn btn-lg' style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid' onclick=TTResult("+x.ID+",'"+x.Type+"')>" +
                                  "<i class='fa fa-thumbs-o-up'></i> Yes" +
                              "</button> " +
                              "<button type='button' class='btn btn-lg bg-blue btnedit' onclick=TTResult(" + x.ID + ",'" + x.Type + "')>" +
                                  "<i class='fa fa-thumbs-o-down' ></i> No" +
                              "</button> "
                     

                  }
             },
        ],
        initComplete: function () {
            var table = $('#Pentbl').DataTable();
            if (!table.data().any()) {
                $("#requestrow").hide();
            }
            else {
                $("#requestrow").show();
                table.columns.adjust();
            }
        }
    });
}

function TTResult(ID,Type) {
    $.ajax({
        url: '/TimeInandOut/SaveOTResult',
        data: {
            ID: ID,
            Type:Type,
            msg: ""
           
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            GetPendingTimekeeping();
            SuccessTap_confirm();
        }

    });
}


