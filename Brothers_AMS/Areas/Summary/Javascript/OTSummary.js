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
    $("#btnExport").on("click", ExportOT);
    $("#btnExportbatch").on("click", ExportOTbatch);
   
    $(".autof").on("change", function () {
        $("#btnFilter").click();
    })
    $("#OTRefno").focusout(function () {
        $("#btnFilter").click();
    });
    
   
})
var currentRefNo;
var currentStatus;
var datacounter = 0;
function Initializedpage() {
    $('#OTSummaryTable').DataTable({
        ajax: {
            url: '../OTSummary/GetApproverOTSummaryList',
            type: "GET",
            datatype: "json",
            data: {
                Refno: $("#OTRefno").val(),
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
                     datacounter++;
                     return " <input type='checkbox' id=OT_here_" + datacounter + " class='empmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + datacounter + "/>" +
                             " <label class=checker for=OT_here_" + datacounter + "></label>"

                 }, orderable: false, searchable: false
             },
              {
                   className: "refnoe", data: function (x) {
                      return data = "<button type='button' class='btn btn-s bg-green'>" + x.OT_RefNo + "</button>"

                  }
              },
              { data: "Section" },
              { data: "OvertimeType" },
              {
                  data: function (x) {
                      return moment(x.CreateDate).format("MM/DD/YYYY")
                  }, name: "CreateDate"
              },
           
               {
                   title: "Supervisor", data: function (x) {
                       if (x.ApprovedSupervisor != null && x.Status > 0) {
                           return x.ApprovedSupervisor
                       }
                       else if (x.Status < 0) {
                           switch (x.Status) {
                               case -4:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Factory General Manager</button>"
                                   break;
                               case -3:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by General Manager</button>"
                                   break;
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
                   title: "Manager", data: function (x) {
                       if (x.ApprovedManager != null && x.Status > 0) {
                           return x.ApprovedManager
                       }
                       else if (x.Status < 0) {
                           switch (x.Status) {
                               case -4:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Factory General Manager</button>"
                                   break;
                               case -3:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by General Manager</button>"
                                   break;
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
                    
                       if (x.StatusMax > 2 && x.ApprovedGeneralManager == null) {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                       }
                       else if (x.ApprovedGeneralManager == null) {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>-</button>"
                       }
                       else {
                           return x.ApprovedGeneralManager
                       }
                       if (x.Status < 0) {
                           switch (x.Status) {
                               case -4:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Factory General Manager</button>"
                                   break;
                               case -3:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by General Manager</button>"
                                   break;
                               case -2:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Manager</button>"
                                   break;
                               case -5:
                                   return "<button type='button' class= 'btn btn-s bg-red'>Cancelled</button>"
                                   break;
                           }
                       }
                    }
                },
                  {
                      title: "Factory General Manager", data: function (x) {
                      
                          if (x.StatusMax > 2 && x.ApprovedFactoryGeneralManager == null) {
                              return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                          }
                          else if (x.ApprovedFactoryGeneralManager == null) {
                              return data = "<button type='button' class= 'btn btn-s bg-orange'>-</button>"
                          }
                          else {
                              return x.ApprovedFactoryGeneralManager
                          }
                          if (x.Status < 0) {
                              switch (x.Status) {
                                  case -4:
                                      return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Factory General Manager</button>"
                                      break;
                                  case -3:
                                      return "<button type='button' class= 'btn btn-s bg-red'>Rejected by General Manager</button>"
                                      break;
                                  case -2:
                                      return "<button type='button' class= 'btn btn-s bg-red'>Rejected by Manager</button>"
                                      break;
                                  case -5:
                                      return "<button type='button' class= 'btn btn-s bg-red'>Cancelled</button>"
                                      break;
                              }
                          }
                          
                      }
                  },
        ],

    });
    $('#OTSummaryTable tbody').off('click');
    $('#OTSummaryTable tbody').on('click', '.refnoe', function () {
        var table = $('#OTSummaryTable').DataTable();
        var data = table.row(this).data();
        currentRefNo = data.OT_RefNo;
        currentStatus = data.Status;
        GetDetails(data.OT_RefNo, data.Status, data.OvertimeType);
       
        $("#OTDetails").modal("show");
    });
    $('#OTSummaryTable tbody').on('click', '.btnAppr', function () {
        var table = $('#OTSummaryTable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApproversSummary(data.OT_RefNo);
        $("#AF_ApproversModalSummary").modal("show");
    });

}

function GetDetails(data,status, OTType) {
    $('#OTApproverDetails').DataTable({
        ajax: {
            url: '../OTSummary/GetApproverOTDetailsList',
            type: "GET",
            datatype: "json",
            data: { OTRefNo: data, status: status,OTType:OTType },

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
        scrollx: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
              { data: "OT_RefNo", sWidth: "10%" },
              { data: "EmployeeNo" },
              { data: "EmployeeName" },
              { data: "Section" },
              //{ data: "LineName" },
              { data: "Purpose" },
              { data: "OvertimeType" },
              {
                  data: function (x) {
                      return moment(x.DateFrom).format("MM/DD/YYYY")
                  }, name: "DateFrom"
              },
              //{
              //    data: function (x) {
              //        return moment(x.DateTo).format("MM/DD/YYYY")
              //    }, name: "DateTo"
              //},
              { data: "OTin" },
              { data: "OTout" },
              //{ data: "Status" }


        ],

    });
    setTimeout(function () { $('#OTApproverDetails').DataTable().ajax.reload(); }, 500);

}

function GetOTReflist() {
    var options = '';
    var datas = document.getElementsByName("OTRefno")[0].value;

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //FOR FG
    $.ajax({
        url: '/OTSummary/GetOTRefnoList',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { otrefno: $("#OTRefno").val() },
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
            $("#OTRefNoList").empty().append(options);
            document.getElementById('OTRefNoList').innerHTML = options;

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

var ApprovedOTrows = [];
function ExportOTbatch() {
    var table = $('#OTSummaryTable').DataTable();
    ApprovedOTrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        var ch = ($('#OT_here_' + d.OT_RefNo).is(":checked")) ? true : false
        d.counter++; 
        if (ch) {
            var details = {
                RefNo: d.OT_RefNo,
                Status:d.Status
            }
            ApprovedOTrows.push(details);
            console.log(details);
        }
    });
    ExportOT();
}

function ExportOT() {
    
    if (ApprovedOTrows.length == 0) {
        window.location = '/OTSummary/ExportOTSummary?RefNo=' + currentRefNo + "&Status=" + currentStatus;
    }
    else {
        var arrRefNo = [];
        var arrStatus = [];
        ApprovedOTrows.forEach(function (item) {
            arrRefNo.push(item.RefNo);
            arrStatus.push(item.Status);
        })
        window.location = '/OTSummary/ExportOTSummary?RefNo=' + arrRefNo.join() + "&Status=" + arrStatus.join();
    }
}

 

//function resolveAfter2Seconds() {
//    return new Promise(resolve => {
//        setTimeout(() => {
//            resolve('resolved');
//        }, 2000);
//    });
//}

// function asyncCall() {
//    console.log('calling');
//    var result = await resolveAfter2Seconds();
//    console.log(result);
//    // expected output: 'resolved'
//}

//asyncCall();