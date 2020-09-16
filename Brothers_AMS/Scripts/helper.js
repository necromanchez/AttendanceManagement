
function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join('');
}

function Dropdown_selectEmpSection(id, url) {
    var option = '<option value="">All Sections' + getlongadjWorktimeSelect() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlongadjWorktimeSelect() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectMPMain2(id, url) {
    var option = '<option value="">All Sections' + getlongadj2() + '</option>';
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
        var idd = "select2-" + id + "-container";
        try {
            document.getElementById(idd).style.whiteSpace = "nowrap";
            document.getElementById(id).style.whiteSpace = "nowrap";
        }
        catch (err) {
          
        }

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}


function Dropdown_selectMPMain22(id, url) {
    var option = '<option value="">All Sections' + getlongadjLineView() + '</option>';
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
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectMPMain_Dept(id, url) {
    var option = '<option value="">All Department' + getlongadjWorktimeSelect() + '</option>';
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
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}




function Dropdown_selectMPMainLine(id, url) {
    var option = '<option value="">All Groups' + getlong() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlongadjWorktimeSelect() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}


function Dropdown_selectMPMainProcess(id, url) {
    var option = '<option value="">All Process' + getlong() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlong() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectMPMainShift(id, url) {
    var option = '<option value="">All Shifts' + getlong() + '</option>';
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
        var idd = "select2-" + id + "-container";
        document.getElementById(idd).style.whiteSpace = "nowrap";
        document.getElementById(id).style.whiteSpace = "nowrap";

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}



function getlong() {
    var lo = "";
    for (var x = 0; x < 60; x++) {
        lo += "&ensp;";
    }
    return lo;
}

function getlongOver() {
    var lo = "";
    for (var x = 0; x < 40; x++) {
        lo += " ";
    }
    return lo;
}


function getlongadj2() {
    var lo = "";
    for (var x = 0; x < 48; x++) {
        lo += "&ensp;";
    }
    return lo;
}

function getlongadj() {
    var lo = "";
    for (var x = 0; x < 37; x++) {
        lo += "&ensp;";
    }
    return lo;
}

function getlongadjWorktimeSelect() {
    var lo = "";
    for (var x = 0; x < 20; x++) {
        lo += "&ensp;";
    }
    return lo;
}


function getlongadjLineView() {
    var lo = "";
    for (var x = 0; x < 17; x++) {
        lo += "&ensp;";
    }
    return lo;
}

function getshort() {
    var lo = "";
    for (var x = 0; x < 12; x++) {
        lo += "&ensp;";
    }
    return lo;
}

function Resetheres(link, ID, Name) {
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
                        notify("Reset Password!", "Password Reset", "success");
                        //Initializepage();
                        //Clearall();
                    }
                    else {
                        swal("Cannot be Reset " + Name);
                    }

                }
            });


        } else {
            swal("Cancelled", "Reset Cancelled", "error");
        }
    });
}

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

function Dropdown_selectFileType(id) {
    var option = '<option value="">--SELECT--' + getshort() + '</option>';
    var daa = ["Individual", "Group"];
    $('#' + id).html(option);
    var counterID = 1;
    $.each(daa, function (i, x) {
        option = '<option value="' + counterID + '">' + x + getshort() + '</option>';
        counterID++;
        //$('.selectpicker').selectpicker('refresh');
        $('#' + id).append(option);
    });

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

function Dropdown_selectApp(id) {
    var option = '<option value="">--SELECT--' + getlong() + '</option>';
    var daa = ["Cancelled", "Rejected", "Pending", "Supervisor approved", "Manager approved", "General approved", "Factory General Manager approved"];
    var data = ["-2", "-1", "0", "1", "2", "3", "4"];
    $('#' + id).html(option);

    $.each(daa, function (i, x) {
        option = '<option value="' + data[i] + '">' + x + getlongadj2() + '</option>';

        //$('.selectpicker').selectpicker('refresh');
        $('#' + id).append(option);
    });

}

function Dropdown_selectMP(id, url) {
    var option = '<option value="">--SELECT--' + getlong() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlongadj() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        //GetUser();

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectWT(id, url) {
    var option = '<option value="">--SELECT--' + getlongadj() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getlongadjWorktimeSelect() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });
        GetUser();

    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
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
function SuccessTap_confirm() {

    swal({
        title: "Time Keeping Confirm",
        text: "Data Saved",
        timer: 400,
        showConfirmButton: false
    });
}

function ContinueApproved() {
    swal({
        title: "Uncheck Employees will not be approve",
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

function Dropdown_selectD(id, url) {
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
       //var optionadd = '<option value="Agency">Agency</option>';

       // //$('.selectpicker').selectpicker('refresh');
       // $('#' + id).append(optionadd);

        $("#FileType").trigger("change");
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}

function Dropdown_selectD_all(id, url) {
    var option = '<option value="">All Employees</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
       
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + '</option>';
            
            $('#' + id).append(option);
        });
      
      
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });

}

function Dropdown_selectD_Line(id, url) {
    var option = '<option value="">All Groups</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {

        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + '</option>';

            $('#' + id).append(option);
        });


    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });

}



function Dropdown_selectL(id, url) {
    var option = '<option value="">--SELECT-- ' + getlongadjLineView() + '</option>';
    $('#' + id).html(option);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        $.each(data.list, function (i, x) {
            option = '<option value="' + x.value + '">' + x.text + getshort() + '</option>';

            //$('.selectpicker').selectpicker('refresh');
            $('#' + id).append(option);
        });

        $("#FileType").trigger("change");
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
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
