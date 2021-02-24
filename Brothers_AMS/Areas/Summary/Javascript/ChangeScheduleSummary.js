$(function () {
    Dropdown_selectMP('Section', "/Helper/GetDropdown_SectionAMS");
    initDatePicker('DateFrom');
    initDatePicker('DateTo');
    Dropdown_selectAppCS("Status");

    $('#CSDetails').on('hidden.bs.modal', function (e) {
        //window.location = '../ChangeScheduleSummary/ChangeScheduleSummary';
    })
    var d = new Date();

    var date = d.getDate();
    var month = d.getMonth() + 1;
    var year = d.getFullYear();
    var lastDay = new Date(year, month, 0).getDate();
    var dateStr = month + "/1/" + year;
    var dTo = month + "/" + lastDay + "/" + year;
    $("#DateFrom").datepicker().datepicker("setDate", dateStr);
    $("#DateTo").datepicker().datepicker("setDate", dTo);
    GetUser();
    $("#btnFilter").on("click", Initializedpage);
    
    $("#checkall_emp").on("change", function () {
        if (this.checked) {
            $('.empmod').prop('checked', true);
        }
        else {
            $('.empmod').prop('checked', false);
        }
    })
    $("#btnExport").on("click", ExportDTR);

    $("#btnApprovedRequest").on("click", ExportChangeSchedule);
    $(".autof").on("change", function () {
        $("#btnFilter").click();
    });
    $("#CSRefno").focusout(function () {
        $("#btnFilter").click();
    });
})

var currentRefNo;
var currentStatus;
var datacounter = 0;
function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section').val(returnData.usersection).trigger('change');
            $("#Search").trigger("click");
        }
    });
}

function GetCSReflist() {
    var options = '';
    var datas = document.getElementsByName("CSRefno")[0].value;

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //FOR FG
    $.ajax({
        url: '/ChangeScheduleSummary/GetCSRefnoList',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { csrefno: $("#CSRefno").val() },
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
            $("#CSRefNoList").empty().append(options);
            document.getElementById('CSRefNoList').innerHTML = options;

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

function Initializedpage() {
    var d = new Date();
    $('#CSSummaryTable').DataTable({
        ajax: {
            url: '../ChangeScheduleSummary/GetApproverCSSummaryList',
            type: "GET",
            datatype: "json",
            data: {
                Refno: $("#CSRefno").val(),
                Section: $("#Section").val(),
                DateFrom: $("#DateFrom").val(),
                DateTo: $("#DateTo").val(),
                Status: $("#Status").val()
            }
        },
        lengthChange: true,
        pagelength: 10000,
        scrollY: "600px",
        //dom: 'lBfrtip',
        //buttons: [
        //    {
        //        extend: 'excel',
        //        title: "Export Summary" + formatDate(d) + "_" + $("#Section").val()
        //    },
        //    {
        //        text: 'Export Detailed Summary',
        //        action: function (e, dt, node, config) {
        //            window.open('../ChangeScheduleSummary/ExportChangeSchedule?Section=' + $("#Section").val() + "&DateFrom=" + $("#DateFrom").val() + "&DateTo=" + $("#DateTo").val() + "&Status=" + $("#Status").val());
        //        }
        //    }
        //],
    
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        loadonce: true,
        destroy: true,
        initComplete: function () {
            var CSType = getParameterByName("CSType");
            var Approved = getParameterByName("Approved");
            var table = $('#CSSummaryTable').DataTable();


            if (CSType != null) {
                $(".refnoe").trigger("click");
                if (!table.data().any()) {
                    var Refno = getParameterByName("RefNo");
                    //swal("CS Request \n" + Refno + " is Finished");
                }
            }
            //if (Approved != null) {
            //    //swal("CS Already approved by " + Approved);
            //    $(".Viewall").show();
            //}
        },
        columns: [
              //{
              //   data: function (data, type, row, meta) {
              //       var checked = (data.AccessType == true) ? ' checked ' : '';
              //       datacounter++;
              //       return " <input type='checkbox' id=CS_here_" + datacounter + " class='empmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + datacounter + "/>" +
              //               " <label class=checker for=CS_here_" + datacounter + "></label>"

              //   }, orderable: false, searchable: false
              //},
              { data: "Rownum", name: "Rownum" },
              {
                  className: "refnoe", data: function (x) {
                      return data = "<button type='button' class='btn btn-s bg-green'>" + x.CS_RefNo + "</button>"

                  }
              },
              { data: "Section" },
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
              //            data = "<button type='button' class='btn btn-s bg-olive'>Approved by Section OTRefno</button>"
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
              //    data: function (x) {
              //        return "<button type='button' class='btn btn-sm bg-blue btnAppr' id=data" + x.CS_RefNo + ">" +
              //            "<i class='fa fa-paper-plane' ></i> Approver" +
              //            "</button> "
              //    }
              //},
             {
                 title: "Supervisor", data: function (x) {
                     if (x.Status == 0) {
                         return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                        
                     }
                     else {
                         return x.ApprovedSupervisor
                     }
                     
                 }
             },
               {
                   title: "Manager", data: function (x) {
                       if (x.Status == 0) {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"

                       }
                       else {
                           return x.ApprovedManager
                       }
                   }
               },
                //{
                //    title: "General Manager", data: function (x) {
                //        if (x.ApprovedGeneralManager != null) {
                //            return x.ApprovedGeneralManager
                //        }
                //        else {
                //            return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                //        }
                //    }
                //},
        ],

    });
    $('#CSSummaryTable tbody').off('click');
    $('#CSSummaryTable tbody').on('click', '.refnoe', function () {
        var table = $('#CSSummaryTable').DataTable();
        var data = table.row(this).data();
        currentRefNo = data.CS_RefNo;
        currentStatus = data.Status;

        GetDetails(data.CS_RefNo, data.Status);
        $("#CSDetails").modal("show");
    });
    $('#CSSummaryTable tbody').on('click', '.btnAppr', function () {
        var table = $('#CSSummaryTable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApproversSummary(data.CS_RefNo);
        $("#AF_ApproversModalSummary").modal("show");
    });

}

function GetDetails(data, status) {
    $('#CSApproverDetails').DataTable({
        ajax: {
            url: '../ChangeScheduleSummary/GetApproverCSDetailsList',
            type: "GET",
            datatype: "json",
            data: { CSRefNo: data, status: status },

        },
        dom: 'frtip',
        //buttons: [
        //  'excel'
        //],
        //lengthMenu: [[10, 50, 100], [10, 50, 100]],
        
        //lengthChange: false,
        pagelength: 10000,
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
            {  data: "Rownum", name: "Rownum" },
              { data: "CS_RefNo", sWidth: "10%" },
              { data: "EmployeeNo" },
              { data: "EmployeeName" },
              { data: "Section" },
              { data: "Reason" },
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
              { data: "CSin" },
              { data: "CSout" },
        ],

    });
    setTimeout(function () { $('#CSApproverDetails').DataTable().ajax.reload(); }, 500);
}

var ApprovedCSrows = [];
function ExportDTR() {
    var table = $('#CSSummaryTable').DataTable();
     ApprovedCSrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        var ch = ($('#CS_here_' + d.CS_RefNo).is(":checked")) ? true : false
        d.counter++;
        if (ch) {
            var details = {
                RefNo: d.CS_RefNo,
                Status: d.Status
            }
            ApprovedCSrows.push(details);
            console.log(details);
        }
    });
    ExportChangeSchedule();
}

function ExportChangeSchedule() {

    if (ApprovedCSrows.length == 0) {
        window.location = '/ChangeScheduleSummary/ExportChangeSched?RefNo=' + currentRefNo + "&Status=" + currentStatus;
    }
    else {
        var arrRefNo = [];
        var arrStatus = [];
        ApprovedCSrows.forEach(function (item) {
            arrRefNo.push(item.RefNo);
            arrStatus.push(item.Status);
        })

        window.location = '/ChangeScheduleSummary/ExportChangeSched?RefNo=' + arrRefNo.join() + "&Status=" + arrStatus.join();

    }
 }