$(function () {

    Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    initDatePicker('DateFrom');
    initDatePicker('DateTo');
    Initializedpage();
    $("#btnFilter").on("click", Initializedpage);
    $("#DateFrom").datepicker().datepicker("setDate", new Date());
    $("#DateTo").datepicker().datepicker("setDate", new Date());
    $("#checkall_emp").on("change", function () {
        if (this.checked) {
            $('.empmod').prop('checked', true);
        }
        else {
            $('.empmod').prop('checked', false);
        }
    })
    $("#btnExport").on("click", ExportDTR);

    $("#btnExportDTRSummary").on("click", ExportDTRSummary);
    $(".autof").on("change", function () {
        $("#btnFilter").click();
    });
    $("#DTRRefno").focusout(function () {
        $("#btnFilter").click();
    });
})
var currentRefNo;
var currentStatus;
function Initializedpage() {
    $('#DTRSummaryTable').DataTable({
        ajax: {
            url: '../DTRSummary/GetApproverDTRSummaryList',
            type: "GET",
            datatype: "json",
            data: {
                Refno: $("#DTR_RefNo").val(),
                Section: $("#Section").val(),
                DateFrom: $("#DateFrom").val(),
                DateTo: $("#DateTo").val(),
                Type: $("#OvertimeType").val(),
                Status: $("#Status").val(),
            }
        },
        lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        
        loadonce: true,
        destroy: true,
        columns: [
              {
                 data: function (data, type, row, meta) {
                     var checked = (data.AccessType == true) ? ' checked ' : '';
                     return " <input type='checkbox' id=DTR_here_" + data.DTR_RefNo + " class='empmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.DTR_RefNo + "/>" +
                             " <label class=checker for=DTR_here_" + data.DTR_RefNo + "></label>"

                 }, orderable: false, searchable: false
              },
              {
                  className: "refnoe", data: function (x) {
                      return data = "<button type='button' class='btn btn-s bg-green'>" + x.DTR_RefNo + "</button>"

                  }
              },
              { data: "Section" },
              { data: "OverTimeType" },
              {
                  data: function (x) {
                      return moment(x.CreateDate).format("MM/DD/YYYY")
                  }, name: "CreateDate"
              },
              //{
              //    data: function (x) {
              //        var data = "";
              //        if (x.Status == -1) {
              //            data = "<button type='button' class='btn btn-s bg-red'>Rejected</button>"
              //        }
              //        else if (x.Status == 0) {
              //            data = "<button type='button' class='btn btn-s bg-orange'>Pending</button>"
              //        }
              //        else if (x.Status == 1) {
              //            data = "<button type='button' class='btn btn-s bg-olive'>Approved by Section DTR_RefNo</button>"
              //        }
              //        else if (x.Status == 2) {
              //            data = "<button type='button' class='btn btn-s bg-teal'>Approved by Section Manager</button>"
              //        }
              //        else {
              //            data = "<button type='button' class='btn btn-s bg-green'>Approved by General Manager</button>"
              //        }
              //        return data

              //    }
              //},
              //{
              //     data: function (x) {
              //         return "<button type='button' class='btn btn-sm bg-blue btnAppr' id=data" + x.DTR_RefNo + ">" +
              //             "<i class='fa fa-paper-plane' ></i> Approver" +
              //             "</button> "
              //     }
              //},
              {
                  title: "Supervisor", data: function (x) {
                      if (x.ApprovedSupervisor != null && x.Status > 0) {
                          return x.ApprovedSupervisor
                      }
                      else if (x.Status < 0) {
                          switch (x.Status) {
                              case -1:
                                  return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Supervisor</button>"
                                  break;
                              case -2:
                                  return x.ApprovedSupervisor
                                  break;
                              case -5:
                                  return "<button type='button' class= 'btn btn-s bg-red'>Cancelled</button>"
                                  break;
                              default:
                                  return "<button type='button' class= 'btn btn-s bg-orange'></button>"
                                  break;

                          }
                      }
                      else {
                          return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                      }



                  }
              },
               {
                   title: "Manager", data: function (x) {
                       if (x.ApprovedManager != null && x.Status > 0) {
                           return x.ApprovedManager
                       }
                       else if (x.Status < 0) {
                           switch (x.Status) {
                               case -2:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Manager</button>"
                                   break;
                               case -5:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Cancelled</button>"
                                   break;
                               default:
                                   return data = "<button type='button' class= 'btn btn-s bg-orange'></button>"
                                   break;
                           }
                       }
                       else {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                       }
                   }
               },
                {
                    title: "General Manager", data: function (x) {
                        if (x.StatusMax == 3) {
                            if (x.ApprovedGeneralManager != null) {
                                return x.ApprovedGeneralManager
                            }
                            else {
                                return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                            }
                        }
                        else {
                            return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"

                        }
                    }
                },
        ],

    });
    $('#DTRSummaryTable tbody').off('click');
    $('#DTRSummaryTable tbody').on('click', '.refnoe', function () {
        var table = $('#DTRSummaryTable').DataTable();
        var data = table.row(this).data();
        GetDetails(data.DTR_RefNo, data.Status);
        
        currentRefNo = data.DTR_RefNo;
        currentStatus = data.Status;

        $("#DTRDetails").modal("show");
    });
    $('#DTRSummaryTable tbody').on('click', '.btnAppr', function () {
        var table = $('#DTRSummaryTable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApproversSummary(data.DTR_RefNo);
        $("#AF_ApproversModalSummary").modal("show");
    });

    
}

function GetDetails(data, status) {
    $('#DTRApproverDetails').DataTable({
        ajax: {
            url: '../DTRSummary/GetApproverDTRDetailsList',
            type: "GET",
            datatype: "json",
            data: { DTRRefNo: data, status: status },

        },
        dom: 'Bfrtip',
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ],
        lengthMenu: [100, 200, 300, 500],
        pagelength: 5000,
        lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
        scrollx:true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
              { data: "DTR_RefNo", sWidth: "10%" },
              { data: "EmployeeNo" },
              { data: "EmployeeName" },
              { data: "Section" },
              //{ data: "LineName" },
              { data: "Reason" },
              //{ data: "OvertimeType" },
              {
                  data: function (x) {
                      return moment(x.DateFrom).format("MM/DD/YYYY")
                  }, name: "DateFrom"
              },
              {
                  data: function (x) {
                      return moment(x.DateTo).format("MM/DD/YYYY")
                  }, name: "DateTo"
              },
              { data: "Timein" },
              { data: "TimeOut" },
              //{ data: "OTin" },
              //{ data: "OTout" }

        ],

    });
    setTimeout(function () { $('#DTRApproverDetails').DataTable().ajax.reload(); }, 500);
}

function GetDTRReflist() {
    var options = '';
    var datas = document.getElementsByName("DTR_RefNo")[0].value;

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //FOR FG
    $.ajax({
        url: '/DTRSummary/GetDTRRefnoList',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { dtrrefno: $("#DTR_RefNo").val() },
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
                options += '<option value="' + returnData.list[i].text + '" />';
            }
            $("#DTRRefNoList").empty().append(options);
            document.getElementById('DTRRefNoList').innerHTML = options;

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
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
var ApprovedDTRrows = [];
function ExportDTR() {
    var table = $('#DTRSummaryTable').DataTable();
    ApprovedDTRrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data(); 
        var ch = ($('#DTR_here_' + d.DTR_RefNo).is(":checked")) ? true : false
        d.counter++;
        if (ch) {
            var details = {
                RefNo: d.DTR_RefNo,
                Status: d.Status
            }
            ApprovedDTRrows.push(details);
            console.log(details);
        }
    });
    ExportDTRSummary()
}

function ExportDTRSummary() {

    if (ApprovedDTRrows.length == 0) {
        window.location = '/DTRSummary/ExportDTRSum?RefNo=' + currentRefNo + "&Status=" + currentStatus;
    }
    else {
        var arrRefNo = [];
        var arrStatus = [];
        ApprovedDTRrows.forEach(function (item) {
            arrRefNo.push(item.RefNo);
            arrStatus.push(item.Status);
        })
        window.location = '/DTRSummary/ExportDTRSum?RefNo=' + arrRefNo.join() + "&Status=" + arrStatus.join();

    }
}