$(function () {
    
    GetUser();
    Dropdown_select('LineID2', "/Helper/GetDropdown_LineProcessTeamLogin?Sectiongroup=" + $("#Section").val());
    Dropdown_selectEmpSection('Section', "/Helper/GetDropdown_SectionAMS?Dgroup=");
    Dropdown_select('Status', "/Helper/GetDropdown_EmployeeStatus?Sectiongroup="+$("#Section").val() +"&MStatus=false");
    Dropdown_select('MStatus', "/Helper/GetDropdown_EmployeeStatus?Sectiongroup=" + $("#Section").val() + "&MStatus=true");
    Dropdown_select('EmployeeStatus', "/Helper/GetDropdown_EmployeeStatus?Sectiongroup=" + $("#Section").val() +"&MStatus=false");//"/Helper/GetDropdown_EmployeeStatus");
    
   
   

    $("#setsched").on("click", function () {

        $("#SetSchedulemodal").modal("show");
    });

    $("#LineID").on("change", function () {
        Dropdown_select('SkillID', "/Helper/GetDropdown_Skills");
    })

    Dropdown_select('CostCenter_AMS', "/Helper/GetDropdown_CostCenter");
   


    $('#LineID').on('change', function (e) {
        Dropdown_select("SkillID", "/Helper/GetDropdown_Skills?LineProcessTeam=" + $('#LineID').val());
        $("#theskillimage").hide();
        $('#SkillLogO').attr('src', "/PictureResources/ProcessLogo/no-logop.png");
    });
    $('#SkillID').on('change', function (e) {
        $.ajax({
            url: '../Employee/GetSkillLogo',
            data: { SkillID: $(this).val() },
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                if (returnData.skillLogo == null) {
                    $('#SkillLogO').attr('src', "/PictureResources/ProcessLogo/no-logop.png");
                }
                else {
                    $('#SkillLogO').attr('src', "/PictureResources/ProcessLogo/" + returnData.skillLogo);

                }
                $("#theskillimage").show();
            }
        });

    });

    $("#EmployCostForm").on("submit", function (e) {
        e.preventDefault();
        if ($("#CostCenter_AMS").val() != "") {
            $.ajax({
                url: '../Employee/ModifyCostCenter',
                data: $(this).serialize(),
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        Initializepage();
                        GetCosttable(returnData.employno);
                        swal("Cost Center Updated");
                    }
                    else {
                        swal("Failed to Update Cost Center");
                    }
                }
            });
        }
        else {
            swal("Please Input Cost Center");
        }
    })

    $("#EmploySkillForm").on("submit", function (e) {
        e.preventDefault();
        if ($("#LineID").val() != "" && $("#SkillID").val() != "") {
            $.ajax({
                url: '../Employee/AddSkill',
                data: $(this).serialize(),
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        GetSkilltable(returnData.employno);
                        //swal("Skill Saved");
                        msg("Process Saved", "success");
                        Initializepage();
                    }
                    else {
                        swal("Process Already Exist");
                    }
                }
            });
        }
        else {
            swal("Please Select Process");
        }
    })

    $("#btnskillinitupload").on("click", ModalSkill);
    $('#SkillMod').on('hidden.bs.modal', function (e) {
        //location.reload();
    })

    $("#LineID2").on("change", function () {
        $("#btnuploadskill").prop("disabled", false);
    })
    $("#Syncit").on("click", SyncEmployee);
    $("#clearallskill").on("click", ClearAllskill);
    $("#Section").on("change", function () {
        //$("#select2-selection__rendered").text($("#Section").val());
        Dropdown_select('Status', "/Helper/GetDropdown_EmployeeStatus?Sectiongroup=" + $("#Section").val() + "&MStatus=false");
        Dropdown_select('MStatus', "/Helper/GetDropdown_EmployeeStatus?Sectiongroup=" + $("#Section").val() + "&MStatus=true");
        Dropdown_select('LineID2', "/Helper/GetDropdown_LineProcessTeamLogin?Sectiongroup=" + $("#Section").val());

        Initializepage();
    });

    $("#downloadbtnExprod").on("click", function () { window.open('../Employee/ExportExpro?CostCode=' + $("#Section").val()); });
    $("#downloadbtnSkill").on("click", function () { window.open('../Employee/ExportSkillEmployee?CostCode=' + $("#Section").val()); });
    $("#downloadbtnSchedule").on("click", function () { window.open('../Employee/ExportSchedule?CostCode=' + $("#Section").val()); });
    $("#downloadbtnStatus").on("click", function () { window.open('../Employee/ExportStatus?CostCode=' + $("#Section").val()); });
    $("#downloadbtnPosition").on("click", function () { window.open('../Employee/ExportPosition?CostCode=' + $("#Section").val()); });


    $("#nosheddown").on("click", function () { window.open('../Employee/ExportNOSchedule?CostCode=' + $("#Section").val()); });
    $("#noprossdown").on("click", function () { window.open('../Employee/ExportNOSkillEmployee?CostCode=' + $("#Section").val()); });



    $(".file-upload").on('change', function () {
        var files = new FormData();
        var file1 = document.getElementById("picturepackage").files[0];
        files.append('files[0]', file1);
        files.append('Employee', $("#IDno").val());
        $.ajax({
            type: 'POST',
            url: '/TimeInandOut/UploadEmployeePhoto2',
            data: files,
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (response) {
                var tabledata = $('#EmployeeTable').DataTable();
                var info = tabledata.page.info();
                //alert(info.page + 1);
                pagecount = pagecount + (info.page * 10);
                Initializepage();
            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });

    });

    $("#Status").on("change", function () {
        Initializepage();
    });

    $("#MStatus").on("change", function () {
        Initializepage();
    });

    $("#SaveStatus").on("click", SaveStatus);
    $("#SavePos").on("click", SavePos);
    $("#ActiveInactiveReportbtn").on("click", function () {
        var selectedStatus = $('#ActiveInactiveSelect').find(":selected").val();
      
        window.open('/Employee/ActiveInactiveReport?Status=' + selectedStatus + "&CostCode=" + $("#Section").val());

    
    });



   

  
    initDatePicker('EffectivitySchedchosen');


    $("#DupRFID").on("click", function () {
        $("#DuplicateRFIDmodal").modal("show");
        $('#DupRFIDTable').DataTable({
            ajax: {
                url: '../Employee/GetDuplicateRFIDList',
                type: "GET",
                datatype: "json"
            },
            dom: 'lBfrtip',
            buttons: [
                'excel'
            ],
            //lengthMenu: [[10, 50, 100], [10, 50, 100]],
            lengthMenu: [[10, 50, 100], [10, 50, 100]],
            lengthChange: true,
            serverSide: "true",
            order: [0, "desc"],
            processing: "true",
            autoWidth:"false",
            initComplete: function () {
                
                var table = $('#DupRFIDTable').DataTable();
                table.columns.adjust();
            },
          
            language: {
                "processing": "processing... please wait"
            },
            //dom: 'Bfrtip',
            destroy: true,
         
            columns: [
                { title: "RFID", data: "RFID", name: "RFID"   },
                { title: "EmpNo", data: "EmpNo", name: "EmpNo" },
                { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
                { title: "CostCode", data: "CostCode", name: "CostCode" },
                { title: "Section", data: "Section", name: "Section" },
            ],
        });
    });

    initDatePicker2('EffectivityResigned');
    $(".resd").hide();
    $("#EmployeeStatus").on("change", function () {
        if ($("#EmployeeStatus").val().toUpperCase() != "ACTIVE") {
            $(".resd").show();
            
        }
        else {
            $(".resd").hide();
            $("#EffectivityResigned").val("");
        }

    })
})

function initDatePicker(dp) {
    var dtToday = new Date();

    var month = dtToday.getMonth() + 1;
    var day = dtToday.getDate() + 1;
    var year = dtToday.getFullYear();
    if (month < 10)
        month = '0' + month.toString();
    if (day < 10)
        day = '0' + day.toString();
    var maxDate = year + '-' + month + '-' + day;
    //alert(maxDate);
    $('#' + dp).attr('min', maxDate);
    $('#' + dp).datepicker({
        todayBtn: "linked",
        //orientation: "top right",
        autoclose: true,
        todayHighlight: true,
        minDate: new Date(maxDate),
        //maxDate: '+30Y'
    });
}

function initDatePicker2(dp) {
    
    $('#' + dp).datepicker({
        todayBtn: "linked",
        //orientation: "top right",
        autoclose: true,
        todayHighlight: true,
        //minDate: new Date(maxDate),
        //maxDate: '+30Y'
    });
}
function GetEmployeeCount(Section) {
    $.ajax({
        url: '../Employee/GetEmployee_StatusProcessShift',
        data: { Section: Section },
        type: 'GET',
        datatype: "json",
        success: function (returnData) {
            $("#noschedule").text(returnData.EmployeeCount.NoSchedule);
            $("#noprocess").text(returnData.EmployeeCount.NoProcess);
            $("#amsactive").text(returnData.EmployeeCount.AMSActive);
            $("#hractive").text(returnData.EmployeeCount.HRActive);
            $("#amsinactive").text(returnData.EmployeeCount.AMSInActive);
            $("#hrinactive").text(returnData.EmployeeCount.HRInActive);
        }
    });
}


function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            currentSectionuser = returnData.usersection;
            $("#Section").val(currentSectionuser)
            Initializepage();
        }
    });
}
var currentSectionuser = "";
var pagecount = 0;
function Initializepage() {
    $("#loading_modal").modal("show");
    GetEmployeeCount($("#Section").val());

    $("#btnuploadskill").prop("disabled", true);
    $("#theskillimage").hide();
    $('#EmployeeTable').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeList',
            type: "POST",
            datatype: "json",
            data: { supersection: $("#Section").val(), Status: $("#Status").val(), MStatus: $("#MStatus").val() }
        },
        displayStart: pagecount,
        ordering: false,
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        lengthChange: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        destroy: true,
        columns: [
            {
                data: "OrderPrio", name: "OrderPrio", visible:false
            },
            {
                data: "Rownum", name: "Rownum" },
            {
                className: "empphoto", data: function (x) {
                    var logO = "";
                    if (x.EmployeePhoto == '' || x.EmployeePhoto == null) {
                        logO = '/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg';
                    }
                    else {
                        logO = "/PictureResources/EmployeePhoto/" + x.EmployeePhoto;
                    }
                    return "<img class='card-img-top img-responsive' style='cursor: pointer;width:50px;height:30px;' src='" + logO + "' alt='Card image cap'>";
                }
            },
            { data: "REFID", name: "REFID" },
            { data: "RFID", name: "RFID" },
            { data: "ADID", name: "ADID" },
            { data: "EmpNo", name: "EmpNo" },
            { data: "Family_Name", name: "Family_Name" },
            { data: "First_Name", name: "First_Name" },
            { data: "Middle_Name", name: "Middle_Name" },
            { data: "Status", name: "Status" },
             {
                 data: function (x) {
                     var colorhere = "";
                     if (x.ModifiedStatus != null) {
                         if (x.ModifiedStatus.toLowerCase() == "active") {
                             colorhere = "#33bf7a";
                         }
                         else {
                             colorhere = "#FF9898";
                         }
                         return "<button type='button' class='btn btn-sm' style='background-color:" + colorhere + "; color:white' alt='alert' class='model_img img-fluid' onclick=UpdateStatus('" + x.EmpNo + "')>" +
                                    "<i class='fa fa-user-md'>" + x.ModifiedStatus.toUpperCase() + "</i>" +
                                "</button>"
                     }
                     else {
                         if (x.Status.toLowerCase() == "active") {
                             colorhere = "#33bf7a";
                         }
                         else {
                             colorhere = "#FF9898";
                         }
                         return "<button type='button' class='btn btn-sm' style='background-color:" + colorhere + "; color:white' alt='alert' class='model_img img-fluid' onclick=UpdateStatus('" + x.EmpNo + "')>" +
                                  "<i class='fa fa-user-md'> " + x.Status + " </i>" +
                              "</button> "
                     }

                 }
             },
            { data: "ModifiedSection", name: "ModifiedSection" },
            { data: "Gender", name:"Gender" },
            //{ data: "Schedule" },
            {
                data: function (x) {
                    var sched = (x.Schedule == null) ? "" : x.Schedule;
                    return "<button type='button' class='btn btn-sm' style='background-color:" + "#33bf7a" + "; color:white' alt='alert' class='model_img img-fluid' onclick=UpdateSchedule('" + x.EmpNo + "')>" +
                        "<i class='fa fa-hourglass-o'> " + sched + " </i>" +
                        "</button> "
                   
                }
            },
            //{ data: "CostCenter_AMS" },
            {
                data: function (x) {
                    var colorcost = (x.CostCenter_AMS != x.CostCenter_IT) ? "red" : "";

                    return "<div style='font-size:16px !important; color:" + colorcost + "'>" + x.CostCenter_AMS + "</div>"

                }
            },
            { data: "CostCenter_IT", name:"CostCenter_IT" },
            //{ data: "CostCenter_EXPROD" },
            {
                data: function (x) {
                    //if (x.Status == "ACTIVE") {
                        return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white' alt='alert' class='model_img img-fluid' onclick=ShowCostHis('" + x.EmpNo + "','" + x.CostCenter_AMS + "','" + x.CostCenter_EXPROD + "')>" +
                                    "<i class='fa fa-history'></i> Cost Center History" +
                                "</button> "
                    //}
                    //else {
                    //    return "-"
                    //}
                }
            },
            {
                data: function (x) {
                    //if (x.Status == "ACTIVE") {
                        return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white' alt='alert' class='model_img img-fluid' onclick=ShowSkills('" + x.EmpNo + "','" + x.CostCenter_AMS + "')>" +
                                    "<i class='fa fa-graduation-cap'></i> Process" +
                                "</button> "
                    //}
                    //else {
                    //    return "-"
                    //}
                }
            },
            { data: "SkillCount", name:"SkillCount" },
            {
                data: "Date_Hired", name: "Date_Hired"
            },
            {
                data: function (x) {
                    return (x.Date_Resigned != null) ? moment(x.Date_Resigned).format("MM/DD/YYYY") : ""
                }, name: "Date_Resigned"
            },

            { data: "Emp_Category" },
            {
                data: function (x) {
                    return (x.Date_Regularized != null) ? moment(x.Date_Regularized).format("MM/DD/YYYY") : ""
                }, name: "Date_Regularized"
            },
            { data: "Position" },
            {
                 data: function (x) {
                     if (x.ModifiedPosition != null) {
                         return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white; width:120px' alt='alert' class='model_img img-fluid' onclick=UpdatePosition('" + x.EmpNo + "')>" +
                                    "<i class='fa fa-user-md'> " + x.ModifiedPosition + "</i>" +
                                "</button> "
                     }
                     else {
                         return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white; width:120px' alt='alert' class='model_img img-fluid' onclick=UpdatePosition('" + x.EmpNo + "')>" +
                                  "<i class='fa fa-user-md'> " + x.Position + "</i>" +
                              "</button> "
                     }

                 }, name:"Position"
            },
            { data: "Email", name:"Email" },
            //{
            //    data: function (x) {
            //            return "<button type='button' class='btn btn-sm' style='background-color:red; color:white;' alt='alert' class='model_img img-fluid' onclick=DeleteEmpno('" + x.EmpNo + "')>" +
            //                "<i class='fa fa-trash-o'> Remove </i>" +
            //                "</button> "
            //    }
            //},
        ],
        initComplete: function () {

           
                //var table = $('#EmployeeTable').DataTable();
                //table.column(26).visible(false);
                
            $("#loading_modal").modal("hide");


        }
    });
    $('#EmployeeTable tbody').off('click');
    $('#EmployeeTable tbody').on('click', '.empphoto', function () {
        var tabledata = $('#EmployeeTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#IDno").val(data.EmpNo);
        $("#picturepackage").click();

    });
    pagecount = 0;
}

function ShowCostHis(data, AMS_CC, EXPROD_CC) {
    $("#EmployNo").val(data);
    $("#CostCenter_AMS").val(AMS_CC);
    $("#CostCenter_EXPROD").val(EXPROD_CC);
    GetCosttable(data);
    $("#CostHistory").modal("show");
}

function ShowSkills(data,CostAMS) {
    Dropdown_select('LineID', "/Helper/GetDropdown_LineProcessTeamLoginV2?CostCode="+CostAMS);

    //$("#EmploySkillForm")[0].reset();
    $("#theskillimage").hide();
    $("#EmpNo").val(data);
    GetSkilltable(data);
    $("#Skillmodal").modal("show");
}

function GetSkilltable(data) {
    $('#Skilltablemod').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeSkill?EmployeeNo=' + data,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        autoWidth: false,
        columns: [
            { title: "Line/Team", data: "Line", name: "Line", sWidth: "30%" },
            { title: "Process", data: "Skill", name: "Skill", sWidth: "30%" },
            {
                title: "Logo", sWidth: "10%", data: function (x) {
                    var logO = (x.SkillLogo == null) ? "no-logop.png" : x.SkillLogo;
                    return "<img class='card-img-top img-responsive' style='width:50px;height:30px;' src='/PictureResources/ProcessLogo/" + logO + "' alt='Card image cap'>";
                }
            },
            { title: "Update By", data: "UpdateBy", name: "UpdateBy", },
            {
                title: "Update Date", data: function (x) {
                    return moment(x.UpdateDate).format("MM/DD/YYYY")
                },
            },
            {
                title: "Action", data: function (x) {
                    return "<button type='button' class='btn btn-sm bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-trash'></i> Delete" +
                            "</button>"
                }
            },
        ],
    });

    $('#Skilltablemod tbody').on('click', '.btndelete', function () {
        var tabledata = $('#Skilltablemod').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#EmpNo").val(data.EmpNo);
        DeletionheresSkill_Employee('../Employee/DeleteSkills', data.EmpNo, data.SkillID);
    });
}

function GetCosttable(data) {
    $('#Employee_Costcentertable').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeCostCenter?EmployeeNo=' + data,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        autoWidth: false,
        destroy: true,
        columns: [
            { title: "CostCenter (AMS)", data: "CostCenter_AMS", sWidth: "10%" },
            { title: "CostCenter (IT)", data: "CostCenter_IT" },
            { title: "CostCenter (EXPROD)", data: "CostCenter_EXPROD", visible:false },
            {
                title: "Update Date (AMS)", data: function (x) {
                    return moment(x.UpdateDate_AMS).format("MM/DD/YYYY")
                }, name: "UpdateDate_AMS"
            },
            {
                title: "Update Date (IT)", data: function (x) {
                    return moment(x.UpdateDate_IT).format("MM/DD/YYYY")
                }, name: "UpdateDate_IT"
            },
            {
                title: "Update Date (EXPROD)", data: function (x) {
                    return moment(x.UpdateDate_EXPROD).format("MM/DD/YYYY")
                }, name: "UpdateDate_EXPROD", visible: false
            },
            {
                title: "Update By", data: function (x) {

                    return (x.Employeename == null) ? "System" : x.Employeename
                }
            },

        ],
    });
}

function UploadExprod() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("UploadedExprod").files[0];
    files.append('files[0]', file1);
    $.ajax({
        type: 'POST',
        url: '../Employee/UploadExprod',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide")
                swal("AMS Cost Center Updated");
                Initializepage();
            }
            else {
                $("#loading_modal").modal("hide");
                swal("AMS Cost Center Upload Failed");

            }
        },
        error: function (error) {

        }
    });
}

function UploadSchedule() {
    $("#loading_modal").modal("show");
    var files = new FormData();
    var file1 = document.getElementById("UploadedSchedule").files[0];
    files.append('files[0]', file1);
    var datecho = $("#EffectivitySchedchosen").val();
    files.append('EffectivitySched', datecho);
    $.ajax({
        type: 'POST',
        url: '../Employee/UploadSchedule',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide");
                $("#SetSchedulemodal").modal("hide");
                swal("Schedule Updated");
                Initializepage();
            }
            else {
                $("#loading_modal").modal("hide");
                swal("Schedule Upload Failed. Please recheck upload file");

            }
        },
        error: function (error) {

        }
    });
}

function UploadStatus() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("UploadedStatus").files[0];
    files.append('files[0]', file1);
    $.ajax({
        type: 'POST',
        url: '../Employee/UploadStatus',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide");
                swal("Status Updated");
                Initializepage();
            }
            else {
                $("#loading_modal").modal("hide");
                swal("Status Upload Failed. Please recheck upload file");

            }
        },
        error: function (error) {

        }
    });
}

function UploadPosition() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("UploadedPosition").files[0];
    files.append('files[0]', file1);
    $.ajax({
        type: 'POST',
        url: '../Employee/UploadPosition',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide")
                swal("Position Updated");
                Initializepage();
            }
            else {
                $("#loading_modal").modal("hide")
                swal("Position Upload Failed. Please recheck upload file");

            }
        },
        error: function (error) {

        }
    });
}

function ModalSkill() {
    $("#SkillMod").modal("show");
}

function UploadSkills() {
    if ($("#LineID2").val() != "") {
        $("#loading_modal").modal("show")
        var files = new FormData();
        var file1 = document.getElementById("btnuploadskill").files[0];
        files.append('LineID', $("#LineID2").val());
        files.append('files[0]', file1);
        $.ajax({
            type: 'POST',
            url: '../Employee/UploadSkills',
            data: files,
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (response) {
                if (response.result == "success") {
                    $("#loading_modal").modal("hide")
                    swal("Process Upload Successful");

                    if (response.uploaderror.length > 0) {
                        $('#errortbl').DataTable({
                            data: response.uploaderror,
                            order: [0, "asc"],
                            processing: "true",
                            language: {
                                "processing": "processing... please wait"
                            },
                            //dom: 'Bfrtip',
                            destroy: true,
                            columns: [
                                { title: "Row", data: "Row", width: "10%" },
                                { title: "Message", data: "Message", width: "10%" },
                            ],

                        });
                    }
                }
                else {
                    swal("An error occured");
                }
            },
            error: function (error) {

            }
        });
    }
    else {
        swal("Please select Line");
    }
}

function SyncEmployee() {
    $("#loading_modal").modal("show")
    $.ajax({
        type: 'POST',
        url: '../Employee/SyncIT',
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.msg == "Success") {
                swal("Employee Successfully Sync");
                $("#loading_modal").modal("hide");
                Initializepage();
            }
            else {
                swal("Employee Failed to Sync. Please contact your system Admin");
                $("#loading_modal").modal("hide");
                Initializepage();
            }

        },
        error: function (error) {

        }
    });
}


function DeletionheresSkill_Employee(link, EmpNo, SkillID) {
    swal({
        title: "Are you sure?",
        //text: "You will not be able to recover this imaginary file!",   
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        closeOnConfirm: true,
        closeOnCancel: true
    }, function (isConfirm) {
        if (isConfirm) {

            $.ajax({
                url: link,
                data: {
                    EmpNo: EmpNo,
                    SkillID: SkillID
                },
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        Initializepage();
                        notify("Saved!", "Deleted", "success");
                        GetSkilltable($("#EmpNo").val());
                    }
                    else {
                        swal("Cannot be Deleted ");
                    }

                }
            });


        } else {
            swal("Cancelled", "Deletion Cancelled", "error");
        }
    });
}

function ClearAllskill() {
    swal({
        title: "Are you sure?",
        text: "All Process within your section will be clear",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        closeOnConfirm: true,
        closeOnCancel: true
    }, function (isConfirm) {
        if (isConfirm) {

            $.ajax({
                url: '../Employee/RemoveSkillAll?Section=' + $("#Section").val(),
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        Initializepage();
                        notify("Saved!", "All Process removed", "success");
                    }
                    else {
                        swal("Cannot be Deleted ");
                    }

                }
            });


        } else {
            swal("Cancelled", "Process removal Cancelled", "error");
        }
    });
}

function UpdateStatus(empno) {
    $("#EmployNoStatus").val(empno);
    $("#UpdateStatusModal").modal("show");
    StatusTable(empno);
}

function UpdatePosition(empno) {
    $("#EmployNoPos").val(empno);
    Dropdown_select('EmployeePos', "/Helper/GetDropdown_EmployeePosition?Sectiongroup=" + $("#Section").val());
    $("#UpdatePositionModal").modal("show");
    PositionTable(empno);
}
function SaveStatus() {

    $.ajax({
        type: 'POST',
        url: '../Employee/UpdateStatus',
        dataType: 'json',
        data: {
            EmpNo: $("#EmployNoStatus").val(),
            Status: $("#EmployeeStatus").val(),
            DateResigned: $("#EffectivityResigned").val()
        },
        success: function (response) {

            notify("Saved!", "Updated Status", "success");
            $("#UpdateStatusModal").modal("hide");
            Initializepage();
        },
        error: function (error) {

        }
    });
}

function SavePos() {
    $.ajax({
        type: 'POST',
        url: '../Employee/UpdatePosition',
        dataType: 'json',
        data: {
            EmpNo: $("#EmployNoPos").val(),
            Position: $("#EmployeePos").val()
        },
        success: function (response) {

            notify("Saved!", "Updated Position", "success");
            $("#UpdatePositionModal").modal("hide");
            Initializepage();
        },
        error: function (error) {

        }
    });
}

function StatusTable(Empno) {
    $('#Statustablemod').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeStatus?EmployeeNo=' + Empno,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        autoWidth: false,
        columns: [
            { title: "HR Status",  data: "HRStatus" },
            { title: "Status", data: "Status" },
            { title: "Resigned Date", data: "DateResigned" },
            { title: "Update By", data: "UpdateID"},
            //{ title: "Update Date", data: "UpdateDate",sWidth: "10%" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate"
            },


        ],
    });
}

function PositionTable(Empno) {
    $('#Positiontablemod').DataTable({
        ajax: {
            url: '../Employee/GetEmployeePosition?EmployeeNo=' + Empno,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        autoWidth: false,
        columns: [
            { title: "Position", data: "Position", sWidth: "25%" },
            { title: "Update By", data: "UpdateID", sWidth: "15%" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate", sWidth: "10%"
            },


        ],
    });
}

function ActiveInactiveReport(Empno) {
    $('#Positiontablemod').DataTable({
        ajax: {
            url: '../Employee/GetEmployeePosition?EmployeeNo=' + Empno,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        autoWidth: false,
        columns: [
            { title: "Position", data: "Position", sWidth: "25%" },
            { title: "Update By", data: "UpdateID", sWidth: "15%" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate", sWidth: "10%"
            },


        ],
    });
}

function UpdateSchedule(empno) {
    $("#UpdateSchedule").modal("show");
    ScheduleTable(empno);
}

function ScheduleTable(Empno) {
    $('#Schedulehistory').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeScheduleList?EmployeeNo=' + Empno,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        autoWidth: false,
        columns: [
            { title: "Schedule", data: "ScheduleName", sWidth: "25%" },
            { title: "Shift", data: "ScheduleShift", sWidth: "25%" },
            {
                title: "Effectivity Date", data: function (x) {
                    return (x.EffectivityDate != null) ? moment(x.EffectivityDate).format("MM/DD/YYYY") : ""
                }, name: "EffectivityDate", sWidth: "10%"
            },
            { title: "Update By", data: "UpdateID", sWidth: "15%" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate", sWidth: "10%"
            },


        ],
    });


    $('#SchedulehistoryCStable').DataTable({
        ajax: {
            url: '../Employee/GetEmployeeScheduleCSList?EmployeeNo=' + Empno,
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        scrollX: true,
        order: [0, "desc"],
        processing: "true",
        autowidth: true,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        initComplete: function () {
            //alert("asd");
            var table = $('#SchedulehistoryCStable').DataTable();
            table.ajax.reload();
        },
        columns: [
            { title: "Reference No", data: "CS_RefNo" },
            { title: "Schedule", data: "ScheduleName" },
            { title: "Shift", data: "ScheduleShift" },
            {
                title: "Date From", data: function (x) {
                    return (x.DateFrom != null) ? moment(x.DateFrom).format("MM/DD/YYYY") : ""
                }, name: "DateFrom"
            },
            {
                title: "Date To", data: function (x) {
                    return (x.DateTo != null) ? moment(x.DateTo).format("MM/DD/YYYY") : ""
                }, name: "DateTo"
            },
            { title: "Update By", data: "UpdateID" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate"
            },


        ],
    });
}

function DeleteEmpno(EmpNo) {
    $.ajax({
        type: 'POST',
        url: '../Employee/DeleteEmp',
        data: {EmpNo : EmpNo},
        dataType: 'json',
      
        success: function (response) {
            if (response.result) {
                swal("Employee Successfully Deleted");
                Initializepage();
            }
            else {
                swal("Failed to delete employee");
            }
        },
        error: function (error) {

        }
    });
}