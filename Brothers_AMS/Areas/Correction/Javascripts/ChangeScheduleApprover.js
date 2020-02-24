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
    $("#btnApprovedRequest").on("click", ApprovedCS);
    $("#btnRejectRequest").on("click", RejectedCS);
    $("#btnCancel").on("click", CancelRequest);
    $(".Viewall").hide();
})

function Initializedpage() {
    $('#ChangeScheduleApprovertable').DataTable({
        ajax: {
            url: '../ApproverChangeSchedule/GetApproverCSList',
            type: "GET",
            datatype: "json",
        },
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        lengthMenu: [100, 200, 300, 500],
        pagelength: 5000,
        lengthChange: false,
        scrollY: "600px",
        scrollCollapse: true,
        language: {
            "processing": "processing... please wait"
        },
        destroy: true,
        initComplete: function () {
            var CSType = getParameterByName("CSType");
            var Approved = getParameterByName("Approved");
            var table = $('#ChangeScheduleApprovertable').DataTable();

           
            if (CSType != null) {
                $(".refnoe").trigger("click");
                if (!table.data().any()) {
                    var Refno = getParameterByName("RefNo");
                    swal("CS Request \n" + Refno + " is Finished");
                }
            }
            if (Approved != null) {
                swal("CS Already approved by " + Approved);
                $(".Viewall").show();
            }
        },
        columns: [
              {
                  title: "CS Reference No.", className: "refnoe", data: function (x) {
                      return data = "<button type='button' class='btn btn-s bg-green'> <i class='fa fa-expand' ></i> " + x.CS_RefNo + "</button>"

                  }
              },
              { title: "Section", data: "Section" },
              { title: "Schedule", data: "Schedule" },
              {
                  title: "Date Created", data: function (x) {
                      return moment(x.CreateDate).format("MM/DD/YYYY")
                  }, name: "CreateDate"
              },
              //{
              //    title: "Status", data: function (x) {
              //        var data = "";
              //        if (x.Status == 0) {
              //            data = "<button type='button' class='btn btn-s bg-orange'>Pending</button>"
              //        }
              //        else if (x.Status == 1) {
              //            data = "<button type='button' class='btn btn-s bg-olive'>Approved by Section Supervisor</button>"
              //        }
              //        else if (x.Status == 2) {
              //            data = "<button type='button' class='btn btn-s bg-teal'>Approved by Section Manager</button>"
              //        }
              //        else if (x.Status == 3) {
              //            data = "<button type='button' class='btn btn-s bg-green'>Approved by General Manager</button>"
              //        }
              //        else {
              //            data = "<button type='button' class='btn btn-s bg-red'>Rejected</button>"

              //        }
              //        return data

              //    }
              //},
              //{
              //    title: "Approver", data: function (x) {
              //        return "<button type='button' class='btn btn-sm bg-blue btnAppr' id=data" + x.ID + ">" +
              //            "<i class='fa fa-paper-plane' ></i> Approver" +
              //            "</button> "
              //    }
              //},
                {
                    title: "Supervisor", data: function (x) {
                        if (x.ApprovedSupervisor != null) {
                            return x.ApprovedSupervisor
                        }
                        else {
                            return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                        }
                    }},
                 {
                     title: "Manager", data: function (x) {
                         if (x.ApprovedManager != null) {
                             return x.ApprovedManager
                         }
                         else {
                             return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                         }
                     }
                 },
                 
        ],

    });
    $('#ChangeScheduleApprovertable tbody').off('click');
   
    $('#ChangeScheduleApprovertable tbody').on('click', '.refnoe', function () {
        var table = $('#ChangeScheduleApprovertable').DataTable();
        var data = table.row(this).data();

        $.ajax({
            url: '../ApproverChangeSchedule/VerifyUser',
            type: 'POST',
            data: { refNo: data.CS_RefNo },
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
                    GetDetails(data.CS_RefNo);
                    table.ajax.reload();
                    $("#CSDetails").modal("show");
            }
        });


    });
    $('#ChangeScheduleApprovertable tbody').on('click', '.btnAppr', function () {
        var table = $('#ChangeScheduleApprovertable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApprovers(data.CS_RefNo);
        $("#AF_ApproversModal").modal("show");
    });
}

function GetDetails(data) {
    $('#CSApproverDetails').DataTable({
        ajax: {
            url: '../ApproverChangeSchedule/GetApproverCSDetailsList',
            type: "GET",
            datatype: "json",
            data: { CSRefNo: data },

        },
        createdRow: function (row, data, dataIndex) {
            $(row).addClass(data.EmployeeNo);
        },
        serverSide: "true",
        lengthMenu: [100, 200, 300, 500],
        pagelength: 5000,
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
              {
                 data: function (data, type, row, meta) {
                     var checked = (data.AccessType == true) ? ' checked ' : '';
                     return " <input type='checkbox' id=CS_here_" + data.ID + " class='empmod filled-in chk-col-light-blue' " + checked + " name='employchosen' " + "/>" +
                             " <label class=checker for=CS_here_" + data.ID + "></label>"

                 }, orderable: false, searchable: false
              },
              //{ data: "CS_RefNo" },

              { data: "EmployeeNo" },
              {
                  data: function (x) {
                      return x.First_Name + " " + x.Family_Name
                  }
              },
              { data: "SectionName" },
              { data: "CSType" },
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
              {
                  data: function (x) {
                       return x.CSin +" - "+ x.CSout

                  }
              },
              { data: "Requestor" },


        ],

    });
    setTimeout(function () { $('#CSApproverDetails').DataTable().ajax.reload(); }, 500);

}

function GetApprovers(data) {
    $('#AF_ApproverStatustable').DataTable({
        ajax: {
            url: '../ApproverChangeSchedule/GetApproverList',
            type: "GET",
            datatype: "json",
            data: { CSRefNo: data },

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

function ApprovedCS() {
    var table = $('#CSApproverDetails').DataTable();
    var ApprovedCSrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            ID: d.ID,
            CS_RefNo: d.CS_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#CS_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedCSrows.push(item);
    });
    if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../ApproverChangeSchedule/ApprovedCS',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedCSrows,
                ifalter: "norm"
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("CS Approved Successfully");
                notify("Saved!", "CS Successfully Filed", "success");
                $("#CSDetails").modal("hide");
                Initializedpage();
            },
             error: function (xhr, ajaxOptions, thrownError) {
                 //swal("CS Approved Successfully");
                 notify("Saved!", "CS Successfully Filed", "success");
                 $("#CSDetails").modal("hide");
                 Initializedpage();
            }
        });
    }
    else {
        ContinueApproved();
    }

}

function RejectedCS() {
    var table = $('#CSApproverDetails').DataTable();
    var ApprovedCSrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            ID: d.ID,
            CS_RefNo: d.CS_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#CS_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedCSrows.push(item);
    });
    //if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../ApproverChangeSchedule/RejectedCS',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedCSrows,
                ifalter: "norm"
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("CS Rejected");
                notify("Saved!", "CS Rejected", "success");
                $("#CSDetails").modal("hide");
                Initializedpage();
            }
        });
    //}
    //else {
    //    ContinueApproved();
    //}

}

function CancelRequest() {
    var table = $('#CSApproverDetails').DataTable();
    var SelectedRefNo = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    var EmployeeList = $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();

    //table.rows().every(function () {
    //    var d = this.data();
    //    d.counter++;
    //    SelectedRefNo.push(d.OT_RefNo);
    //});

    $.ajax({
        url: '../ApproverChangeSchedule/CancelledRefNo',
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
                notify("Saved!", "CS Request Cancelled", "success");
                $("#CSDetails").modal("hide");
             
            }
        }
    });
}