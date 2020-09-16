$(function () {
    $("#ALLtbl").hide();
    $("#checkall_emp").prop("disabled", true);
    Dropdown_selectMP('BIPH_Agency', "/Helper/GetDropdown_Agency");
    //Dropdown_select('Section', "/Helper/GetDropdown_Section");
    GetcurrentSection('Section', "/Helper/GetCurrentSection");
    $("#loading_modal").modal("show");
    Dropdown_selectFileType("FileType");
    Dropdown_selectMP('Line_Team', "/Helper/GetDropdown_LineProcessTeamLogin");
    initDatePicker('DateFrom');
    initDatePicker('DateTo');
    $("#DateFrom").datepicker().datepicker("setDate", new Date());
    $("#DateTo").datepicker().datepicker("setDate", new Date());
    //$('#ConfirmDTR').on('hidden.bs.modal', function (e) {
    //   setTimeout(function () { location.reload(); }, 2500);
    //})
    $("#templateDownload").on("click", function () {
        window.location.href = "../../Correction/Templates/DownloadTemplate?filename=OTForm.xlsx"
    })
    //$("#FileType").val(2);
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
            url: '../DTR/ReadUploadedFile',
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
                    $("#DTRForm")[0].reset();
                    Initializepage();
                }
                else {
                    $("#loading_modal").modal("hide")
                    $("#UploadedFile").val("");
                    //swal("DTR Successfully Filed");
                    notify("Saved!", "DTR Successfully Filed", "success");
                    $("#DTRForm")[0].reset();
                    Initializepage();
                }
               
            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });
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
    $("#Section").prop('disabled', true);
    $("#Line_Team").prop('disabled', true);
  
    //$("#FileType").on("change", function () {
    //    if ($("#BIPH_Agency").val() != "") {
    //        if ($(this).val() == 1) {
    //            $("#Section").prop('disabled', true);
    //            $("#Line_Team").prop('disabled', true);
    //            $("#EmployeeNo").prop('disabled', false);
    //            $("#EmployeeNo").css('background-color', "#F6F9D3");
    //            //background-color:#F6F9D3;
    //            $("#Line_Team").val('');
    //            $("#EmployeeNo").val('');
    //        }
    //        else {
    //            $.ajax({
    //                url: '/Helper/GetSection',
    //                type: 'POST',
    //                datatype: "json",
    //                success: function (returnData) {
    //                    $('#Section').val(returnData.usersection);
    //                    $("#Section").prop('disabled', true);
    //                    $("#Line_Team").prop('disabled', false);
    //                    $("#EmployeeNo").prop('disabled', true);
    //                    $("#EmployeeNo").css('background-color', "#E9ECEF");
    //                    $("#Line_Team").val('');
    //                    $("#EmployeeNo").val('');
    //                    //
    //                }
    //            });

    //        }
    //    }
    //    else {
    //        //$("#FileType").trigger("change");
    //    }
    //    $("#btnSearch").trigger("click");
    //})
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

    $("#btnconfirm").on("click", function () {
        if ($("#DateFrom").val() <= $("#DateTo").val()) {
            if ($("#Timein").val() < $("#TimeOut").val()) {
                var EmployeeList = chosend_EmpNo;// $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
                if (EmployeeList.length > 0) {

                    if ($("#DateFrom").val() != "" && $("#OTin").val() && $("#DateTo").val() && $("#OTout").val()) {
                        $("#DateFromSum").val($("#DateFrom").val());
                        $("#OTInsum").val($("#OTin").val());
                        $("#DateToSum").val($("#DateTo").val());
                        $("#OTOutsum").val($("#OTout").val());
                        $("#TimeInsum").val($("#Timein").val());
                        $("#TimeOutsum").val($("#TimeOut").val());


                        var EmployeeList = chosend_EmpNo;// $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
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
                                    TransType: "DTR"
                                }
                            },
                            serverSide: "true",
                            lengthMenu: [[10, 50, 100], [10, 50, 100]],
                            
                            searching:false,
                            lengthChange: false,
                            scrollY: "600px",
                            scrollCollapse: true,
                            order: [0, "asc"],
                            processing: "true",
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
                                   {
                                        title: "Concern", data: function (x) {
                                        return "<input type='text' class='form-control PPos2' id='P_" + x.EmpNo + "' name='P_2" + x.EmpNo + "'>"
                                        }
                                    },
                                  //{ title: "Line", data: "Line" },
                                  {
                                      title: "Reason", data: function (x) {
                                          return "<input type='text' class='form-control PPos' id='P_" + x.EmpNo + "' name='P_" + x.EmpNo + "'>"
                                      }
                                  },
                                   
                            ],

                        });
                        setTimeout(function () { $('#ChosenEmployeeTable').DataTable().ajax.reload(); }, 500);
                        $("#ConfirmDTR").modal("show");
                    }
                    else {
                        swal("Please fill required fields");
                    }
                }
                else {
                    swal("Please choose Employee");
                }
            }
            else {
                swal("Please recheck details");
            }
        }
        else {
            swal("Please recheck details");
        }
    })

    $("#Pposgroup").on("change", function () {
        $(".PPos").val($(this).val());
    })

    $("#PposgroupConcern").on("change", function () {
        $(".PPos2").val($(this).val());
    })

    $("#btnSaveDTR").on("click", SaveDTR);

    //AUTOMATIC STARTS HERE
    $("#BIPH_Agency").on("change", function () {
        $("#loading_modal").modal("show");
        $("#btnSearch").trigger("click");
    })
    $("#EmployeeNo").focusout(function () {
        $("#btnSearch").trigger("click");
    });
    $("#Line_Team").on("change", function () {
        $("#btnSearch").trigger("click");
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

                }
            });
        }
    });

    $("#btnDownloadTemplate").on("click", DownloadTemplate);
 
    //STEP BY STEP procedure
    $("#EmployeeNo").on("focusout", function () { $("#DateFrom").prop("disabled", false); $("#DateTo").prop("disabled", false); })

  
    $("#BIPH_Agency").on("change", function () {
        $("#FileType").prop("disabled", false);
        $("#btnSearch").trigger("click");
        $("#ALLtbl").show();
        //$("#btnDownloadTemplate").prop("disabled", false);
    })
    //$("#FileType").on("change", function () { $("#Line_Team").prop("disabled", false); })
    $("#Line_Team").on("change", function () { $("#DateFrom").prop("disabled", false); $("#DateTo").prop("disabled", false); })
    $("#DateTo").on("change", function () { $("#Timein").prop("disabled", false); $("#TimeOut").prop("disabled", false); })

    Initializepage();
    $('[data-toggle="tooltip"]').tooltip();




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
    $('#DTREmployeeTable').DataTable({
        ajax: {
            url: '../OT/GetEmployeeList',
            type: "GET",
            datatype: "json",
            data: {
                EmployeeNo: $("#EmployeeNo").val(),
                LineID: $("#Line_Team").val(),
                SectionID: $("#Section").val(),
                Agency: $("#BIPH_Agency").val(),
                TransType : "DTR"
            }
        },
        //ordering:false,
        lengthMenu: [10, 20, 30, 50],
        pagelength: 10,
        lengthChange: false,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        initComplete: function () {
            $("#loading_modal").modal("hide");
            if ($("#BIPH_Agency").val() == "") {
                $(".empmod").prop("disabled", true);
            }
          
          
        },
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
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
    $('#DTREmployeeTable tbody').on('click', 'tr', function () {

        if ($("#EmployeeNo").val() == "" && $("#FileType").val() == 1) {
            var tabledata = $('#DTREmployeeTable').DataTable();
            var data = tabledata.row(this).data();
            $("#EmployeeNo").val(data.EmpNo);
            getEmployeeNo();
            $("#DateFrom").prop("disabled", false);
            $("#DateTo").prop("disabled", false);

            var Sched = data.Schedule;
            var str = data.Schedule;
            var res = str.split(" - ");
            $("#Timein").val(res[0]);
            $("#TimeOut").val(res[1]);
            
        }
        else {
            single = true;
            $("#DateFrom").prop("disabled", false);
            $("#DateTo").prop("disabled", false);
            $("#Timein").prop("disabled", false);
            $("#TimeOut").prop("disabled", false);
        }

    });
}

function GetEmployeeChosen(EmpNo) {
    if ($("#BIPH_Agency").val() != "") {
        $(".empmod").prop("disabled", false);
        if (chosend_EmpNo.indexOf(EmpNo) !== -1) {
            chosend_EmpNo.remove(EmpNo);
        } else {
            chosend_EmpNo.push(EmpNo);
        }
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


function SaveDTR() {
    var datanow = $("#DTRForm").serialize();
    var tabledata = $('#ChosenEmployeeTable').DataTable();
    var reasons = [];
    var concerns = [];
    var EmpNo = [];

    var data = tabledata.rows().data();
    for (var x = 0; x < data.length; x++) {
        concerns.push(tabledata.context[0].aoData[x].anCells[7].lastChild.value);
        reasons.push(tabledata.context[0].aoData[x].anCells[6].lastChild.value);
        EmpNo.push(tabledata.context[0].aoData[x].anCells[0].lastChild.data);
    }
    $.ajax({
        url: '../DTR/SaveDTR',
        data: datanow + "&Reasons=" + reasons + "&EmployeeNos=" + EmpNo + "&DTRType=" + $("#DTRType").val() + "&concerns=" + concerns,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
             notify("Saved!", "DTR Successfully Filed", "success");
            //$("#DTRRefno").text(returnData.DTRRefNo);
            //swal("DTR Successfully Filed");
            //$("#DTRForm")[0].reset();
            //Initializepage();
            //$("#btnSaveDTR").prop("disabled", true);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            notify("Saved!", "DTR Successfully Filed", "success");
            //console.log(xhr.status);
            //console.log(thrownError);
            // swal("DTR Successfully Filed");
             //$("#DTRForm")[0].reset();
             //Initializepage();
             //$("#btnSaveDTR").prop("disabled", true);
        }
    });
}

function DownloadTemplate() {
    if ($("#BIPH_Agency").val() != "") {
        var table = $('#DTREmployeeTable').DataTable();
        if (table.data().count() < 30) {
            window.open('/DTR/DownloadTemplate?Agency=' + $("#BIPH_Agency").val());
        }
        else {
            swal("Employee list exceed CS template rows");
        }
    }
    else {
        swal("Please choose Agency");
    }
    //
}