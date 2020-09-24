$(function () {
    $("#ALLtbl").hide();
    $("#checkall_emp").prop("disabled", true);
    Dropdown_selectEmpCompany('BIPH_Agency', "/Helper/GetDropdown_Agency");
    //Dropdown_select('Section', "/Helper/GetDropdown_Section");
    Dropdown_selectMP('Line_Team', "/Helper/GetDropdown_LineProcessTeamLogin");
    GetcurrentSection('Section', "/Helper/GetCurrentSection");
    Dropdown_selectFileType("FileType");
    Dropdown_selectCS("CSType");
    Dropdown_selectMP('Schedule', "/Helper/GetDropdown_Schedule");
    Dropdown_selectMP('ScheduleSum', "/Helper/GetDropdown_Schedule");
    //$('#ConfirmChangeSchedule').on('hidden.bs.modal', function (e) {
    //    setTimeout(function () { location.reload(); }, 2500);
    //})
    
    initDatePicker('DateFrom');
    initDatePicker('DateTo');

    $("#Schedule").on("change", function () {
        var la = $("#Schedule option:selected").text().split(" - ");
        $("#CSin").val(la[0]);
        var ss = la[1].split(" ");
        $("#CSout").val(ss[0]);
        
        $.ajax({
            url: '../ChangeSchedule/GetShift',
            type: 'GET',
            datatype: "json",
            data: { ScheduleID: $("#Schedule").val() },
            success: function (returnData) {
                $("#Shift").val(returnData.Shiftname);
            },
        });
    })
    $("#Pposgroup").on("keyup", function () {
        $(".PPos").val($(this).val());
    })
    $("#Section").prop('disabled', true);
    $("#Line_Team").prop('disabled', true);
    $("#FileType").on("change", function () {
        chosend_EmpNo = [];
        if ($("#BIPH_Agency").val() != "") {
            if ($(this).val() == 1) {
                $("#checkall_emp").prop("disabled", true);
                $("#Section").prop('disabled', true);
                $("#Line_Team").prop('disabled', true);
                $("#EmployeeNo").prop('disabled', false);
                $("#EmployeeNo").css('background-color', "#F6F9D3");
                //background-color:#F6F9D3;
                $("#Line_Team").val('');
                $("#EmployeeNo").val('');
            }
            else {
                $("#checkall_emp").prop("disabled", false);
                $.ajax({
                    url: '/Helper/GetSection',
                    type: 'POST',
                    datatype: "json",
                    success: function (returnData) {
                        $('#Section').val(returnData.usersection);
                        $("#Section").prop('disabled', true);
                        $("#Line_Team").prop('disabled', false);
                        $("#EmployeeNo").prop('disabled', true);
                        $("#EmployeeNo").css('background-color', "#E9ECEF");
                        $("#Line_Team").val('');
                        $("#EmployeeNo").val('');
                        single = false;
                        //
                    }
                });

            }

        }
        else {
            //$("#FileType").trigger("change");
        }
        $("#btnSearch").trigger("click");
    })


    
    $("#btnSearch").on("click", function () {
        Initializepage();
    })
    $("#checkall_emp").on("change", function () {
        if (this.checked) {
            $('.empmod').each(function (i, obj) {
                chosend_EmpNo.push(obj.id);
            });
            $('.empmod').prop('checked', true);
        }
        //else {
        //    $('.empmod').each(function (i, obj) {
        //        chosend_EmpNo.remove(obj.id);
        //    }); $('.empmod').prop('checked', false);
        //}
    })

    $("#btnconfirm").on("click", function () {
        if ($("#DateFrom").val() <= $("#DateTo").val()) {
            var EmployeeList = chosend_EmpNo;// $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
            if (EmployeeList.length > 0) {
                if ($("#DateFrom").val() != ""
                    && $("#DateTo").val()
                    && $("#BIPH_Agency").val() != ""
                    && $("#CSType").val() != ""
                    && $("#Schedule").val() != "") {
                    $("#DateFromSum").val($("#DateFrom").val());
                    $("#DateToSum").val($("#DateTo").val());
                    $("#ScheduleSum").val($("#Schedule").val());
                    var EmployeeList = chosend_EmpNo;//$('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
                    $('#ChosenEmployeeTable').DataTable({
                        ajax: {
                            url: '../OT/GetEmployeeList',
                            type: 'GET',
                            datatype: 'json',
                            traditional: true,
                            contentType: 'application/json; charset=utf-8',
                            data: {
                                ChosenEmployees: EmployeeList,
                                EmployeeNo: $("#EmployeeNo").val(),
                                LineID: $("#Line_Team").val(),
                                SectionID: $("#Section").val(),
                                Agency: $("#BIPH_Agency").val(),
                                TransType: "CS"
                            }
                        },
                        lengthMenu: [[10, 50, 100], [10, 50, 100]],
                        
                        lengthChange: false,
                        scrollY: "600px",
                        scrollCollapse: true,
                        serverSide: "true",
                        order: [0, "asc"],
                        processing: "true",
                        searching:false,
                        language: {
                            "processing": "processing... please wait"
                        },
                        //dom: 'Bfrtip',
                        destroy: true,
                        columns: [
                              { title: "Employee", data: "EmpNo" },
                              { title: "Family Name", data: "Family_Name" },
                              { title: "First Name", data: "First_Name" },
                              { title: "Agency", data: "Agency" },
                              { title: "Cost Center", data: "CostCenter_AMS" },
                              { title: "Section", data: "Section" },
                              //{ title: "Line", data: "Line" },
                              {
                                  title: "Reason", data: function (x) {
                                      return "<input type='text' class='form-control PPos' id='P_" + x.EmpNo + "' name='P_" + x.EmpNo + "'>"
                                  }
                              }
                        ],

                    });
                    setTimeout(function () { $('#ChosenEmployeeTable').DataTable().ajax.reload(); }, 500);
                    $("#SchedFrom").val($("#DateFrom").val());
                    $("#SchedTo").val($("#DateTo").val());
                    $("#ConfirmChangeSchedule").modal("show");
                }
                else {
                    swal("Please fill required fields");
                }
            }
            else {
                swal("Please select Employee");
            }
        }
        else {
            swal("Please fill required fields");
        }
    })

    $("#btnSaveCS").on("click", SaveCS);
    $("#DateFrom").datepicker().datepicker("setDate", new Date());
    $("#DateTo").datepicker().datepicker("setDate", new Date());

    //AUTOMATIC STARTS HERE
    $(".autof").on("change", function () {
        $("#btnSearch").trigger("click");
    })
    $("#BIPH_Agency").on("change", function () {
        $("#loading_modal").modal("show");
        Initializepage();
        //$("#btnSearch").trigger("click");
        $("#ALLtbl").show();
        //$("#btnDownloadTemplate").prop("disabled", false);
    })

    $('#EmployeeNo').keypress(function (event) {
        var keycode = (event.keyCode ? event.keyCode : event.which);
        if (keycode == '13') {
            $("#Line").prop("disabled", false);
            $.ajax({
                url: '/Login/GetEmployeeNo',
                data: {
                    RFID: $("#EmployeeNo").val(),
                    //LineID: $("#Line").val()
                },
                type: 'GET',
                datatype: "json",
                success: function (returnData) {
                    $('#EmployeeNo').val(returnData.empno);
                    var t = $('#ChangeScheduleTable').DataTable();
                    t.search(returnData.empno);
                }
            });
        }
    });

    $("#btnDownloadTemplate").on("click", DownloadTemplate);

    //$("#FileType").val(1);


    $("#btnFileUpload").on("click", function () {
        $("#UploadedFile").trigger("click");
    })
    $("#UploadedFile").on("change", function () {
        $("#loading_modal").modal("show")

        var files = new FormData();
        var file1 = document.getElementById("UploadedFile").files[0];
        files.append('files[0]', file1);
        $.ajax({
            type: 'POST',
            url: '../ChangeSchedule/ReadUploadedFile',
            data: files,
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (response) {
                if (response.Failed == "Failed") {
                    swal("Please recheck Upload file contents");
                    $("#loading_modal").modal("hide")
                    $("#UploadedFile").val("");
                    $("#CSForm")[0].reset();
                    Initializepage();
                }
                else {
                    $("#loading_modal").modal("hide")
                    $("#UploadedFile").val("");
                    //swal("CS Successfully Filed");
                    notify("Saved!", "CS Successfully Filed", "success");
                    $("#CSForm")[0].reset();
                    Initializepage();
                }
            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });
    })


    //STEP BY STEP procedure
    $("#EmployeeNo").on("focusout", function () { $("#Schedule").prop("disabled", false); })
    $("#BIPH_Agency").on("change", function () { $("#FileType").prop("disabled", false); })
    //$("#FileType").on("change", function () { $("#Line_Team").prop("disabled", false); })
    $("#Line_Team").on("change", function () { $("#Schedule").prop("disabled", false); })
    $("#Schedule").on("change", function () { $("#DateFrom").prop("disabled", false); $("#DateTo").prop("disabled", false); })
    $("#DateTo").on("change", function () { $("#CSType").prop("disabled", false); })
    Initializepage();
})
var single = false;
var chosend_EmpNo = [];

Array.prototype.remove = function () {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) != -1) {
            this.splice(ax, 1);
        }
    }
    return this;
}

function Initializepage() {
    $('#ChangeScheduleTable').DataTable({
        ajax: {
            url: '../OT/GetEmployeeList',
            type: "GET",
            datatype: "json",
            data: {
                EmployeeNo: $("#EmployeeNo").val(),
                LineID: $("#Line_Team").val(),
                SectionID: $("#Section").val(),
                Agency: $("#BIPH_Agency").val(),
                Schedule: $("#Schedule").val(),
                TransType: "CS"
            }
        },
        //ordering:false,
        lengthMenu: [10, 20, 30, 50],
        pagelength: 10,
        lengthChange: false,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        initComplete: function () {
            $("#loading_modal").modal("hide");
            if ($("#BIPH_Agency").val() == "") {
                $(".empmod").prop("disabled", true);
            }
          
          
        },
        columns: [
              {
                  data: function (data, type, row, meta) {
                      var status = ((chosend_EmpNo.indexOf(data.EmpNo) !== -1)) ? "checked" : "";
                      return " <input type='checkbox' id=" + data.EmpNo + " class='empmod filled-in chk-col-light-blue' name='employchosen' " + status + " onclick=GetEmployeeChosen('" + data.EmpNo + "') />" +
                              " <label class=checker for=" + data.EmpNo + "></label>"

                  }, orderable: false, searchable: false
              },
              { data: "EmpNo" },
              { data: "Family_Name" },
              { data: "First_Name" },
              { data: "Agency" },
              { data: "CostCenter_AMS" },
              { data: "Section" },
              { data: "Schedule" },
              //{ data: "Line" },
              
        ],

    });

    $('#tbody').on('click', 'tr', function () {

        if ($("#EmployeeNo").val() == "" && $("#FileType").val() == 1) {
            var tabledata = $('#ChangeScheduleTable').DataTable();
            var data = tabledata.row(this).data();
            $("#EmployeeNo").val(data.EmpNo);
            getEmployeeNo();
            $("#Schedule").prop("disabled", false);
        }
        else {
            single = true;
        }

    });

}

function GetEmployeeChosen(EmpNo) {
    if ($("#BIPH_Agency").val() != "") {
        $("#Schedule").prop("disabled", false);
        $(".empmod").prop("disabled", false);
        if (chosend_EmpNo.indexOf(EmpNo) !== -1) {
            chosend_EmpNo.remove(EmpNo);
        } else {
            chosend_EmpNo.push(EmpNo);
        }
    }

    if ($("#FileType").val() == 1) {
        $("#EmployeeNo").val(EmpNo);
        $("#btnSearch").trigger("click");
    }
 


}

function initDatePicker(dp) {
    $('#' + dp).datepicker({
        todayBtn: "linked",
        orientation: "top right",
        autoclose: true,
        todayHighlight: true
    });
}

function SaveCS() {
    var datanow = $("#ChangeScheduleForm").serialize();
    var tabledata = $('#ChosenEmployeeTable').DataTable();
    var reasons = [];
    var EmpNo = [];

    var data = tabledata.rows().data();
    //for (var x = 0; x < data.length; x++) {
    //    reasons.push(tabledata.context[0].aoData[x].anCells[7].lastChild.value);
    //    EmpNo.push(tabledata.context[0].aoData[x].anCells[0].lastChild.data);
    //}
    for (var x = 0; x < data.length; x++) {
        reasons.push(tabledata.context[0].aoData[x].anCells[6].lastChild.value);
        EmpNo.push(tabledata.context[0].aoData[x].anCells[0].lastChild.data);
    }
    $.ajax({
        url: '../ChangeSchedule/SaveCS',
        data: datanow + "&Reasons=" + reasons + "&EmployeeNos=" + EmpNo,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            notify("Saved!", "CS Successfully Filed", "success");
        },
        error: function (xhr, ajaxOptions, thrownError) {
            notify("Saved!", "CS Successfully Filed", "success");
        }
    });
}

function DownloadTemplate() {
    if ($("#BIPH_Agency").val() != "") {
        var table = $('#ChangeScheduleTable').DataTable();
        if (table.data().count() < 30) {
            window.open('/ChangeSchedule/DownloadTemplate?Agency=' + $("#BIPH_Agency").val());
        }
        else {
            swal("Employee list exceed CS template rows");
        }
    }
    else {
        swal("Please choose Agency");
    }
}

function Dropdown_selectCS(id) {
    var option = '<option value="">--SELECT--' + getlong() + '</option>';
    var daa = ["Change of Shift Schedule", "Change of Rest Day", "No Work Schedule"];
    var data = ["CS", "RD", "NW"];
    $('#' + id).html(option);

    $.each(daa, function (i, x) {
        option = '<option value="' + data[i] + '">' + x + '</option>';

        //$('.selectpicker').selectpicker('refresh');
        $('#' + id).append(option);
    });

}