function Deletionheres(link, ID, Name) {
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
                data: { ID: ID },
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        //swal("Deleted!", "Data has been deleted.", "success");
                        notify("Deleted!", "Data has been deleted.", "success");
                        Initializepage();
                        //Clearall();
                    }
                    else {
                        swal("Cannot be Delete " + Name);
                    }

                }
            });


        } else {
            swal("Cancelled", "Deletion Cancelled", "error");
        }
    });
}

function SuccessTap() {

    swal({
        title: "Tap Successful",
        text: "Data Saved",
        timer: 400,
        showConfirmButton: false
    });
}

function ContinueApproved() {
    swal({
        title: "Reject uncheck Employees?",
        //text: "You will not be able to recover this imaginary file!",   
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        closeOnConfirm: false,
        closeOnCancel: false
    }, function (isConfirm) {
        if (isConfirm) {
            GlobalAcceptance = true;
            $("#btnApprovedRequest").click();
        } else {
            swal("Cancelled", "Cancelled", "error");
        }
    });
}
var GlobalAcceptance = false;


function validateForm(data) {
    var isValid = true;
    $('#' + data).each(function () {
        if ($(this).val() === '')
            isValid = false;
    });
    return isValid;
}

function Dropdown_select(id, url) {
    var option = '<option value="">--SELECT--</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });

        $("#FileType").trigger("change");
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}
function Dropdown_select2(id, url) {
    var option = '<option value="">--SELECT--</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        var LineVal = $("#Line > option:nth-child(2)").val();
        $("#Line").val(LineVal).trigger('change');
        
        $("body > div > div.content-wrapper > section.content > div > div > div > div.col-xl-8.align-self-md-center > div > div:nth-child(2) > div.col-md-8.align-self-md-center > div:nth-child(4) > div.col-md-7 > div > div > span").on("click", function () {
            $("#Line").select2("open");
        })
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function GetcurrentSection(id, url) {

    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $("#" + id).val(data.sectionnow);
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}


function getEmployeeNo() {
    var options = '';
    var datas = document.getElementsByName("EmployeeNo")[0].value;

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //FOR FG
    $.ajax({
        url: '/OT/GetEmployeeNo',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: {
            Agency: $("#BIPH_Agency").val(),
            IDno: $("#EmployeeNo").val()
        },
        rowNum: 1000,
        success: function (returnData) {
            options = "";
            if (returnData.list.length > 20) {
                l = 10;
            }
            else {
                l = returnData.list.length;
            }
            for (var i = 0; i < l; i++) {
                options += '<option value="' + returnData.list[i].EmpNo + '" />';
            }
            $("#EmployeeNoList").empty().append(options);
            document.getElementById('EmployeeNoList').innerHTML = options;
            Initializepage();

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function Dropdown_select_onchange(x, value, url, id) {
    var option = '<option hidden></option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
        data: { x: x }
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + '</option>';
            $('#' + id).append(option);
        });
        $('#' + id).val(value);
        $('.selectpicker').selectpicker('refresh');
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function LogOff() {
    $.ajax({
        url: '/Login/LogOff',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            window.location.href = "/Login/Login";
        }
    });
}

function btnChangePassword_OnClick() {
    window.location.href = "/Home/ChangePassword";
}

function goTime() {
    window.location.href = "/TimeInandOut/TimeInandOut";
}
function goLine() {
    window.location.href = "/LineView/LineView";
}

function getLine() {
    var options = '';
    var datas = document.getElementsByName("Line")[0].value;

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //FOR FG
    $.ajax({
        url: '../Helper/GetLine?line',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { line: datas },
        rowNum: 1000,
        success: function (returnData) {
            options = "";
            if (returnData.list.length > 20) {
                l = 10;
            }
            else {
                l = returnData.list.length;
            }
            for (var i = 0; i < l; i++) {
                options += '<option value="' + returnData.list[i].Line + '" data-value="' + returnData.list[i].ID + '"/>';
            }
            $("#LineList").empty().append(options);
            document.getElementById('LineList').innerHTML = options;

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}


function msg(msg, status) {
    if (status == '') {
        iziToast.info({
            title: 'Info',
            message: msg,
            position: 'topRight',
        });
    } else {
        switch (status) {
            case 'center':
                iziToast.success({
                    title: 'Success',
                    message: msg,
                    position: 'center',
                });
                break;
            case 'success':
                iziToast.success({
                    title: 'Success',
                    message: msg,
                    position: 'topRight',
                });
                break;

            case 'failed':
                iziToast.warning({
                    title: 'Failed',
                    message: msg,
                    position: 'topRight',
                    backgroundColor: '#ff9999',
                    theme: 'light',
                });
                break;

            case 'warning':
                iziToast.warning({
                    title: 'Warning',
                    message: msg,
                    position: 'center',

                });
                break;

            case 'error':
                iziToast.error({
                    title: 'Error',
                    message: msg,
                    position: 'topRight',
                    backgroundColor: 'red',
                });
                break;
        }
    }
}

function GetApproversSummary(data) {
    $('#AF_ApproverStatustableSummary').DataTable({
        ajax: {
            url: '/Correction/Approval_OT/GetApproverList',
            type: "GET",
            datatype: "json",
            data: { OTRefNo: data },

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

              { data: "Position" },
              { data: "EmployeeNo" },
              { data: "EmployeeName" },
              {
                  title: "Status", data: function (x) {
                      var label = "";
                      if (x.Type == "SundayHoliday") {
                          if (x.Approved == 1) {
                              label = "<button type='button' class='btn btn-sm bg-green'>Approved</button>"
                          }
                          else if (x.Approved == 0) {
                              label = "<button type='button' class='btn btn-sm bg-orange'>Pending</button>"
                          }
                          else {
                              label = "<button type='button' class='btn btn-sm bg-red'>Rejected</button>"
                          }
                      }
                      else {
                          if (x.Status == 2 && x.Position == "GeneralManager") {
                              label = "<button type='button' class='btn btn-sm bg-green'>Not Necessary</button>"
                          }
                          else {
                              if (x.Approved == 1) {
                                  label = "<button type='button' class='btn btn-sm bg-green'>Approved</button>"
                              }
                              else if (x.Approved == 0) {
                                  label = "<button type='button' class='btn btn-sm bg-orange'>Pending</button>"
                              }
                              else {
                                  label = "<button type='button' class='btn btn-sm bg-red'>Rejected</button>"
                              }
                          }
                      }
                      return label
                  }
              },

        ],

    });

}


function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
