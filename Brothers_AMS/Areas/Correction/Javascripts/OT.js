$(function () {
    $("#ALLtbl").hide();
    $("#OvertimeType").prop("disabled", false);
    $("#checkall_emp").prop("disabled",true);
    Dropdown_selectMP('BIPH_Agency', "/Helper/GetDropdown_Agency");
    Dropdown_selectMP('BIPH_Agency2', "/Helper/GetDropdown_Agency");
    $("#loading_modal").modal("show");
    Dropdown_selectOT("OvertimeType");
    Dropdown_selectFileType("FileType");
    Dropdown_selectMP('Line_Team', "/Helper/GetDropdown_LineProcessTeamLogin");
    GetcurrentSection('Section', "/Helper/GetCurrentSection");
   
    //$('#ConfirmOT').on('hidden.bs.modal', function (e) {
    //    setTimeout(function () { location.reload(); }, 2500);
    //})
  
    $("#templateDownload").on("click", function () {
        window.location.href = "../../Correction/Templates/DownloadTemplate?filename=OTForm.xlsx"
    })

    $("#btnFileUpload").on("click", function () {
        $("#UploadedFile").trigger("click");
    })

    $("#UploadedFile").on("change", function () {
        $("#loading_modal").modal("show");

        var files = new FormData();
        var file1 = document.getElementById("UploadedFile").files[0];
        files.append('files[0]', file1);
        $.ajax({
            type: 'POST',
            url: '../OT/ReadUploadedFile',
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
                    $("#OTForm")[0].reset();
                    Initializepage();
                }
                else {
                    $("#loading_modal").modal("hide")
                    $("#UploadedFile").val("");
                    //swal("OT Successfully Filed");
                    notify("Saved!", "OT Successfully Filed", "success");
                    $("#OTForm")[0].reset();
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
                Initializepage();
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
      //  $("#btnSearch").trigger("click");
    })
    $("#btnSearch").on("click", function () {
        //$("#btnconfirm").prop("disabled", false);
        Initializepage();
    })

    $("#btnconfirm").on("click", Confirmchecker);
    
    $("#Pposgroup").on("keyup", function () {
        $(".PPos").val($(this).val());
    })

    $("#btnSaveOT").on("click", SaveOT);
    

    $("#DateFrom").datepicker().datepicker("setDate", new Date());
    $("#DateTo").datepicker().datepicker("setDate", new Date());

    //AUTOMATIC STARTS HERE
    $("#BIPH_Agency").on("change", function () {
        $("#loading_modal").modal("show");
        $("#btnSearch").trigger("click");
        $("#ALLtbl").show();
        //$("#btnDownloadTemplate").prop("disabled", false);
    })
  
    $("#EmployeeNo").focusout(function () {
        $("#btnSearch").trigger("click");
    });
    //$("#Line_Team").on("change", function () {
    //    $("#btnSearch").trigger("click");
    //})

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

 
    $("#Line_Team").prop("disabled",true);
    //STEP BY STEP procedure
    $("#BIPH_Agency").on("change", function () { $("#FileType").prop("disabled", false); })
    //$("#FileType").on("change", function () { $("#Line_Team").prop("disabled", false); })
    $("#Line_Team").on("change", function () { $("#OvertimeType").prop("disabled", false); initDatePicker('DateFrom'); })
    $("#OvertimeType").on("change", function () {
        $("#DateFrom").prop("disabled", false);
        $("#OTin").prop("disabled", false);
        $("#OTout").prop("disabled", false);
      
    })
    $("#OTin").val("--SELECT--");
    $("#OTout").val("--SELECT--");
   
    //$('#OTTable').on('page.dt', function () {
    //    //var info = table.page.info();
    //    //$('#pageInfo').html('Showing page: ' + info.page + ' of ' + info.pages);
       
    //});


    Initializepage();
})

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

function GetEmployeeChosen(EmpNo) {
    if ($("#BIPH_Agency").val() != "") {
        $("#OvertimeType").prop("disabled", false);
        $(".empmod").prop("disabled", false);
        if (chosend_EmpNo.indexOf(EmpNo) !== -1) {
            chosend_EmpNo.remove(EmpNo);
        } else {
            chosend_EmpNo.push(EmpNo);
        }
    }
}


var init = 2;
var single = false;
function Initializepage() {
    $("#btnSearch").prop("disabled", false);
    $('#OTTable').DataTable({
        ajax: {
            url: '../OT/GetEmployeeList',
            type: "GET",
            datatype: "json",
            data: {
                EmployeeNo: $("#EmployeeNo").val(),
                LineID: $("#Line_Team").val(),
                Section: $("#Section").val(),
                Agency: $("#BIPH_Agency").val(),
                TransType : "OT"
            }
        },
        createdRow: function (row, data, dataIndex) {
            $(row).addClass(data.EmpNo);
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
        drawCallback: function (settings) {
            
            if ($("#OTout").val() != "--SELECT--") {
                //TimeValidator_Nosubmit(chosend_EmpNo);
            }
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
              {
                  data: function (data, type, row, meta) {
                      var status = ((chosend_EmpNo.indexOf(data.EmpNo) !== -1)) ? "checked" : "";
                      return " <input type='checkbox' id=" + data.EmpNo + " class='empmod filled-in chk-col-light-blue' name='employchosen' " + status + " onclick=GetEmployeeChosen('" + data.EmpNo + "') />" +
                             " <label class=checker wew for=" + data.EmpNo + "></label>"

                 }, orderable: false, searchable: false
              },
              { data: "EmpNo" },
              { data: "Family_Name" },
              { data: "First_Name" },
              { data: "Agency" },
              { data: "CostCenter_AMS" },
              { data: "Section" },
              { data: "Schedule" },
              { data: "CumulativeOT"  ,className: "text-center" },
              //{ data: "Line" },
        ],
        initComplete: function () {
            $("#loading_modal").modal("hide");
            if ($("#BIPH_Agency").val() == "") {
                $(".empmod").prop("disabled", true);
            }
          
          
        }
        
    });

    $('#OTTable tbody').on('click','tr', function () {
        if ($("#EmployeeNo").val() == "" && $("#FileType").val() == 1) {
            var tabledata = $('#OTTable').DataTable();
            var data = tabledata.row(this).data();
            $("#EmployeeNo").val(data.EmpNo);
            getEmployeeNo();
            $("#OvertimeType").prop("disabled", false);

            var Sched = data.Schedule;
            var str = data.Schedule;
            var res = str.split(" - ");
            $("#OTin").val(res[1]);

            if ($("#OvertimeType").val() == "SundayHoliday") {
                $("#OTin").val(res[0]);
            }

        }
        else {
            single = true;
        }
       
    });
   
}

function initDatePicker(dp) {
    $('#' + dp).datepicker({
        todayBtn: "linked",
        orientation: "top right",
        autoclose: true,
        todayHighlight: true
    });
}

function SaveOT() {
    var datanow = $("#OTForm").serialize();
    var tabledata = $('#ChosenEmployeeTable').DataTable();
    var purposes = [];
    var EmpNo = [];
   
    
    var data = tabledata.rows().data();
    for (var x = 0; x < data.length; x++) {
        purposes.push(tabledata.context[0].aoData[x].anCells[6].lastChild.value);
        EmpNo.push(tabledata.context[0].aoData[x].anCells[0].lastChild.data);
    }
    $.ajax({
        url: '../OT/SaveOT',
        data: datanow + "&Purposes=" + purposes + "&EmployeeNos=" + EmpNo,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            //swal("OT Successfully Filed");
            notify("Saved!", "OT Successfully Filed", "success");
            //$("#OTForm")[0].reset();
            //Initializepage();
            //$("#btnSaveOT").prop("disabled", true);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            notify("Saved!", "OT Successfully Filed", "success");
            //swal("OT Successfully Filed");
            //$("#OTForm")[0].reset();
            //Initializepage();
            //$("#btnSaveOT").prop("disabled", true);
        }
    })

}

function DownloadTemplate() {
    if ($("#BIPH_Agency").val() != "") {
        var table = $('#OTTable').DataTable();
        if (table.data().count() < 25) {
            window.open('/OT/DownloadTemplate?Agency=' + $("#BIPH_Agency").val());
        }
        else {
            swal("Employee list exceed OT template rows");
        }
    }
    else {
        swal("Please choose Agency");
    }
}

function Confirmchecker() {
    $(".ipinagbawal").removeClass("ipinagbawal");
    $(".withOTna").removeClass("withOTna");
    //if ($("#OTin").val() < $("#OTout").val()) {
        var EmployeeList = chosend_EmpNo;//$('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
        var check = TimeValidator(EmployeeList);
    //}
    //else {
    //    swal("Please recheck input fields");
    //}
        
}

function TimeValidator(data) {
    var result = true;
    var EmployeeList = data;
    if (EmployeeList.length > 0) {
        $.ajax({
            url: '/OT/TimeValidate',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                list: data,
                DateFrom: $("#DateFrom").val(),
                OTin: $("#OTin").val(),
                OTOut: $("#OTout").val(),
                Type: $("#OvertimeType").val()
            }),
            datatype: "json",
            success: function (returnData) {
                if (returnData.Allow) {
                    if (EmployeeList.length > 0) {
                        if ($("#DateFrom").val() != ""
                            && ($("#OTin").val() != $("#OTout").val())) {
                            $("#DateFromSum").val($("#DateFrom").val());
                            $("#OTInsum").val($("#OTin").val());
                            $("#DateToSum").val($("#DateTo").val());
                            $("#OTOutsum").val($("#OTout").val());
                            EmployeeList = chosend_EmpNo;//$('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();
                            $('#ChosenEmployeeTable').DataTable({
                                ajax: {
                                    url: '../OT/GetEmployeeList',
                                    type: 'GET',
                                    datatype: 'json',
                                    traditional: true,
                                    searching: false,
                                    contentType: 'application/json; charset=utf-8',
                                    data: {
                                        ChosenEmployees: EmployeeList,
                                        EmployeeNo: $("#EmployeeNo").val(),
                                        LineID: $("#Line_Team").val(),
                                        Section: $("#Section").val(),
                                        Agency: $("#BIPH_Agency").val(),
                                        TransType: "OT"
                                    }
                                },
                                lengthChange: false,
                                searching: false,
                                serverSide: "true",
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
                                      //{ title: "Line", data: "Line" },
                                      {
                                          title: "Purpose", data: function (x) {
                                              return "<input type='text' class='form-control PPos' id='P_" + x.EmpNo + "' name='P_" + x.EmpNo + "'>"
                                          }
                                      }
                                ],

                            });
                            setTimeout(function () { $('#ChosenEmployeeTable').DataTable().ajax.reload(); }, 500);

                            $("#ConfirmOT").modal("show");
                        }
                        else {
                            swal("Please recheck input fields");
                        }
                    }
                    else {
                        swal("Please Choose Employees");
                    }
                }
                else {
                    returnData.EmpConflict.forEach(function myFunction(item) {
                        //console.log(item);
                        $("." + item).addClass("ipinagbawal");
                    });
                    returnData.EmpAlready.forEach(function myFunction(item) {
                        //console.log(item);
                        $("." + item).addClass("withOTna");
                    });
                    swal("Employees have conflicting schedule");
                }
            }
        });
    }
    else {
        swal("Please Choose Employees");
    }


    return result;
}

function TimeValidator_Nosubmit(data) {
    var result = true;
    var EmployeeList = data;
    if (EmployeeList.length > 0) {
        $.ajax({
            url: '/OT/TimeValidate',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                list: data,
                OTin: $("#OTin").val(),
                OTOut: $("#OTout").val(),
                Type: $("#OvertimeType").val()
            }),
            datatype: "json",
            success: function (returnData) {
             
            }
        });
    }
    else {
        swal("Please Choose Employees");
    }


    return result;
}

function Dropdown_selectOT(id) {
    var option = '<option value="">--SELECT--' + getlong() + '</option>';
    var daa = ["Regular", "SundayHoliday", "LegalHoliday", "SpecialHoliday"];
    $('#' + id).html(option);

    $.each(daa, function (i, x) {
        option = '<option value="' + x + '">' + x + getlong() + '</option>';

        //$('.selectpicker').selectpicker('refresh');
        $('#' + id).append(option);
    });

}

