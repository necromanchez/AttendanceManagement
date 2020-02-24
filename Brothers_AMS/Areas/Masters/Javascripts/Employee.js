$(function () {
    Initializepage();
    Dropdown_select('LineID', "/Helper/GetDropdown_LineProcessTeamLogin");
    Dropdown_select('LineID2', "/Helper/GetDropdown_LineProcessTeamLogin");
    Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    Dropdown_select('Status', "/Helper/GetDropdown_EmployeeStatus");
    Dropdown_select('MStatus', "/Helper/GetDropdown_EmployeeModStatus");
    Dropdown_select('EmployeeStatus', "/Helper/GetDropdown_EmployeeStatus");
    Dropdown_select('EmployeePos', "/Helper/GetDropdown_EmployeePosition");


    $("#LineID").on("change", function () {
        Dropdown_select('SkillID', "/Helper/GetDropdown_Skills");
    })

    Dropdown_select('CostCenter_AMS', "/Helper/GetDropdown_CostCenter");
    //Dropdown_select('CostCenter_EXPROD', "/Helper/GetDropdown_CostCenter");


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
        if ($("#CostCenter_AMS").val() != ""
            && $("#CostCenter_EXPROD").val() != "") {
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
                        msg("Skill Saved", "success");
                        Initializepage();
                    }
                    else {
                        swal("Skill Already Exist");
                    }
                }
            });
        }
        else {
            swal("Please Select Skill");
        }
    })

    $("#btnskillinitupload").on("click", ModalSkill);
    $('#SkillMod').on('hidden.bs.modal', function (e) {
        location.reload();
    })

    $("#LineID2").on("change", function () {
        $("#btnuploadskill").prop("disabled", false);
    })
    $("#Syncit").on("click", SyncEmployee);
    $("#clearallskill").on("click", ClearAllskill);
    $("#Section").on("change", Initializepage);

    $("#downloadbtnExprod").on("click", function () { window.open('../Employee/ExportExpro?CostCode=' + $("#Section").val()); });
    $("#downloadbtnSkill").on("click", function () { window.open('../Employee/ExportSkillEmployee?CostCode=' + $("#Section").val()); });
    $("#downloadbtnSchedule").on("click", function () { window.open('../Employee/ExportSchedule?CostCode=' + $("#Section").val()); });
    $("#downloadbtnStatus").on("click", function () { window.open('../Employee/ExportStatus?CostCode=' + $("#Section").val()); });
    $("#downloadbtnPosition").on("click", function () { window.open('../Employee/ExportPosition?CostCode=' + $("#Section").val()); });


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
        alert(selectedStatus);

        window.location = '/Employee/ActiveInactiveReport?Status=' + selectedStatus;
    });
})

var pagecount = 0;
function Initializepage() {
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
        lengthChange: false,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
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
            { data: "REFID" },
            { data: "ADID" },
            { data: "EmpNo" },
            { data: "Family_Name" },
            { data: "First_Name" },
            { data: "Middle_Name" },
            { data: "Status" },
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
                                "</button> "
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
            { data: "SectionGroup" },
            { data: "Gender" },
            { data: "Schedule" },
            { data: "CostCenter_AMS" },
            { data: "CostCenter_IT" },
            { data: "CostCenter_EXPROD" },
            {
                data: function (x) {
                    if (x.Status == "ACTIVE") {
                        return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white' alt='alert' class='model_img img-fluid' onclick=ShowCostHis('" + x.EmpNo + "','" + x.CostCenter_AMS + "','" + x.CostCenter_EXPROD + "')>" +
                                    "<i class='fa fa-history'></i> Cost Center History" +
                                "</button> "
                    }
                    else {
                        return "-"
                    }
                }
            },
            {
                data: function (x) {
                    if (x.Status == "ACTIVE") {
                        return "<button type='button' class='btn btn-sm' style='background-color:#0a89c1; color:white' alt='alert' class='model_img img-fluid' onclick=ShowSkills('" + x.EmpNo + "')>" +
                                    "<i class='fa fa-graduation-cap'></i> Process" +
                                "</button> "
                    }
                    else {
                        return "-"
                    }
                }
            },
            { data: "SkillCount" },
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

                 }
             },
            { data: "Email" },
            { data: "RFID" },
        ],
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

function ShowSkills(data) {
    $("#EmploySkillForm")[0].reset();
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
            { title: "Line/Team", data: "Line", sWidth: "30%" },
            { title: "Skill", data: "Skill", sWidth: "30%" },
            {
                title: "Logo", sWidth: "10%", data: function (x) {
                    var logO = (x.SkillLogo == null) ? "no-logop.png" : x.SkillLogo;
                    return "<img class='card-img-top img-responsive' style='width:50px;height:30px;' src='/PictureResources/ProcessLogo/" + logO + "' alt='Card image cap'>";
                }
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
            { title: "CostCenter (EXPROD)", data: "CostCenter_EXPROD" },
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
                }, name: "UpdateDate_EXPROD"
            },
            {
                title: "Update Employee", data: function (x) {

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
                swal("Exprod Cost Center Updated");
                Initializepage();
            }
            else {
                swal("An error occured");

            }
        },
        error: function (error) {

        }
    });
}

function UploadSchedule() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("UploadedSchedule").files[0];
    files.append('files[0]', file1);
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
                $("#loading_modal").modal("hide")
                swal("Schedule Updated");
                Initializepage();
            }
            else {
                swal("An error occured");

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
                $("#loading_modal").modal("hide")
                swal("Status Updated");
                Initializepage();
            }
            else {
                swal("An error occured");

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
                swal("An error occured");

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
                    swal("Skill Upload Successful");

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

            swal("Employee Successfully Sync");
            $("#loading_modal").modal("hide");
            Initializepage();

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
        text: "All Skills within you section will be clear",
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
                url: '../Employee/RemoveSkillAll',
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        Initializepage();
                        notify("Saved!", "All Skills removed", "success");
                    }
                    else {
                        swal("Cannot be Deleted ");
                    }

                }
            });


        } else {
            swal("Cancelled", "Skill removal Cancelled", "error");
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
            Status: $("#EmployeeStatus").val()
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
            { title: "Status", data: "Status", sWidth: "25%" },
            { title: "Update By", data: "UpdateID", sWidth: "15%" },
            //{ title: "Update Date", data: "UpdateDate",sWidth: "10%" },
            {
                title: "Update Date", data: function (x) {
                    return (x.UpdateDate != null) ? moment(x.UpdateDate).format("MM/DD/YYYY") : ""
                }, name: "UpdateDate", sWidth: "10%"
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
