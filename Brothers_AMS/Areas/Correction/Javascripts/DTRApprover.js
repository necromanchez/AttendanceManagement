$(function () {

    Initializedpage();
    $("#checkall_emp").on("change", function () {
        if (this.checked) {
            $('.empmod').prop('checked', true);
        }
        else {
            $('.empmod').prop('checked', false);
        }
    })
    $("#btnApprovedRequest").on("click", ApprovedDTR);
    $("#btnRejectRequest").on("click", RejectedDTR);
    $("#btnCancel").on("click", CancelRequest);
    $(".Viewall").hide();
})

function Initializedpage() {
    $('#DTRApproverTable').DataTable({
        ajax: {
            url: '../ApproverDTR/GetApproverDTRList',
            type: "GET",
            datatype: "json",
        },
      
        lengthMenu: [100, 200, 300, 500],
        pagelength: 5000,
        lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        initComplete: function () {
            var Overtimetype = getParameterByName("OverTimeType");
            var Approved = getParameterByName("Approved");
            var table = $('#DTRApproverTable').DataTable();

           
            if (Overtimetype != null) {
                $(".refnoe").trigger("click");
                if (!table.data().any()) {
                    var Refno = getParameterByName("RefNo");
                    swal("DTR Request \n" + Refno + " is Finished");
                }
            }
            if (Approved != null) {
                swal("DTR Already approved by " + Approved);
               
            }
        },
        columns: [
              //{ title: "DTR Reference No.", data: "DTR_RefNo" },
              {
                   title: "DTR Reference No.", className: "refnoe", data: function (x) {
                       return data = "<button type='button' class='btn btn-s bg-green'> <i class='fa fa-expand' ></i> " + x.DTR_RefNo + "</button>"

                   }
              },
              { title: "Section", data: "Section" },
              //{ title: "Overtime Type", data: "OverTimeType" },
              {
                  title: "Date Created", data: function (x) {
                      return moment(x.CreateDate).format("MM/DD/YYYY")
                  }, name: "CreateDate"
              },
        
                {
                    title: "Supervisor", data: function (x) {
                        if (x.ApprovedSupervisor != null) {
                            return x.ApprovedSupervisor
                        }
                        else {
                            return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                        }
                    }
                },
               {
                   title: "Manager", data: function (x) {
                       if (x.ApprovedManager != null) {
                           return x.ApprovedManager
                       }
                       else if (x.StatusMax == 1) {
                           return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"
                       }
                       else {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                       }
                   }
               },
                //{
                //    title: "General Manager", data: function (x) {
                //        if (x.StatusMax == 2) {
                //            return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"
                //        }
                //        else if (x.StatusMax == 1) {
                //            return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"
                //        }
                //        else {
                //            return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                //        }
                //        //if (x.ApprovedGeneralManager != null) {
                //        //    return x.ApprovedGeneralManager
                //        //}
                //        //else {
                //        //    return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                //        //}
                //    }
                //},
        ],

    });
    $('#DTRApproverTable tbody').off('click');
   
    $('#DTRApproverTable tbody').on('click', '.refnoe', function () {
            var table = $('#DTRApproverTable').DataTable();
            var data = table.row(this).data();

        $.ajax({
            url: '../ApproverDTR/VerifyUser',
            type: 'POST',
            data: { refNo: data.DTR_RefNo },
            datatype: "json",
            success: function (returnData) {
                if (returnData.releasebtn == false) {
                    $(".theapprovebtn").prop("disabled", true);
                    $(".Noteme").show();
                }
                else {
                    $(".theapprovebtn").prop("disabled", false);
                    $(".Noteme").hide();
                }
                //if (returnData.releasebtnCancel == false) {
                //    $("#btnCancel").hide();
                //}
                //else {
                    $("#btnCancel").show();
                //}
                GetDetails(data.DTR_RefNo, data.OverTimeType);
                table.ajax.reload();
                $("#DTRDetails").modal("show");
            }
        });


    });
    $('#DTRApproverTable tbody').on('click', '.btnAppr', function () {
        var table = $('#DTRApproverTable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApprovers(data.DTR_RefNo);
        $("#AF_ApproversModal").modal("show");
    });
}


function GetDetails(data, OTType) {
    $('#DTRApproverDetails').DataTable({
        ajax: {
            url: '../ApproverDTR/GetApproverDTRDetailsList',
            type: "GET",
            datatype: "json",
            data: { DTRRefNo: data, OTType: OTType },

        },
        createdRow: function (row, data, dataIndex) {
            $(row).addClass(data.EmployeeNo);
        },
        lengthMenu: [100, 200, 300, 500],
        pagelength: 5000,
        lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
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
                 data: function (data, type, row, meta) {
                     var checked = (data.AccessType == true) ? ' checked ' : '';
                     return " <input type='checkbox' id=DTR_here_" + data.ID + " class='empmod filled-in chk-col-light-blue' " + checked + " name='employchosen' " + "/>" +
                             " <label class=checker for=DTR_here_" + data.ID + "></label>"

                 }, orderable: false, searchable: false
              },
              //{ data: "DTR_RefNo", sWidth: "10%" },
              { data: "EmployeeNo" },
              {
                  data: function (x) {
                      return x.First_Name + " " + x.Family_Name
                  }
              },
              { data: "SectionName" },
              //{ title: "Line", data: "LineName" },
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
              //{ data: "OTin" },
              //{ data: "OTout" },
              { data: "Timein" },
              { data: "TimeOut" },
              { data: "Requestor" }


        ],

    });
    setTimeout(function () { $('#DTRApproverDetails').DataTable().ajax.reload(); }, 500);
}


function GetApprovers(data) {
    $('#AF_ApproverStatustable').DataTable({
        ajax: {
            url: '../ApproverDTR/GetApproverList',
            type: "GET",
            datatype: "json",
            data: { DTRRefNo: data },

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
                          if (x.Position == "GeneralManager") {
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
                      return label
                  }
              },
        ],

    });

}

function ApprovedDTR() {
    var table = $('#DTRApproverDetails').DataTable();
    var ApprovedDTRrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    var Type = "";
    table.rows().every(function () {
        var d = this.data();
        Type = d.OvertimeType;
        d.counter++;
        var item = {
            ID: d.ID,
            DTR_RefNo: d.DTR_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#DTR_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedDTRrows.push(item);
    });
    if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../ApproverDTR/ApprovedDTR',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedDTRrows,
                ifalter: "norm",
                OTType: Type
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("DTR Approved Successfully");
                notify("Saved!", "DTR Successfully Filed", "success");
                $("#DTRDetails").modal("hide");
                Initializedpage();
            },
             error: function (xhr, ajaxOptions, thrownError) {
                 notify("Saved!", "DTR Successfully Filed", "success");
                 $("#DTRDetails").modal("hide");
                 Initializedpage();
            }
        });
    }
    else {
        ContinueApproved();
    }

}

function RejectedDTR() {
    var table = $('#DTRApproverDetails').DataTable();
    var ApprovedDTRrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            ID: d.ID,
            DTR_RefNo: d.DTR_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#CS_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedDTRrows.push(item);
    });
    //if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../ApproverDTR/RejectedDTR',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedDTRrows,
                ifalter: "norm"
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("DTR Rejected");
                notify("Saved!", "DTR Rejected", "success");
                $("#DTRDetails").modal("hide");
                Initializedpage();
            }
        });
    //}
    //else {
    //    ContinueApproved();
    //}

}

function CancelRequest() {
    var table = $('#DTRApproverDetails').DataTable();
    var SelectedRefNo = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    var EmployeeList = $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();

    //table.rows().every(function () {
    //    var d = this.data();
    //    d.counter++;
    //    SelectedRefNo.push(d.DTR_RefNo);
    //});

    $.ajax({
        url: '../ApproverDTR/CancelledRefNo',
        type: 'POST',
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            RefNo: EmployeeList,
        }),
        datatype: "json",
        success: function (returnData) {
            if (returnData.EmpnoCannotCancel.length > 0) {
                returnData.EmpnoCannotCancel.forEach(function myFunction(item) {
                    $("." + item).addClass("ipinagbawal");
                });
                swal("Cannot cancel by current user");
            }
            else {
                notify("Saved!", "DTR Request Cancelled", "success");
                $("#DTRDetails").modal("hide");

            }
        }
    });
}