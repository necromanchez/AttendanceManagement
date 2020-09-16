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

    $("#btnApprovedRequest").on("click", ApprovedOT);
    $("#btnRejectRequest").on("click", RejectedOT);

    $('#OTDetails').on('hidden.bs.modal', function (e) {
        $(".Viewall").trigger("click");
    })

    $("#Supervisor").focusout(function () {
        $.ajax({
            url: '/Masters/Section/GetEmployeeName',
            data: { EmployeeNo: $(this).val() },
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                $("#SupervisorName").val(returnData.completename);
            }
        });
    });

    $("#btnSend").on("click", Sendmail);
    $("#btnCancel").on("click", CancelRequest);

    $('#OTDetails').on('hidden.bs.modal', function (e) {
        $('#OTApproverDetails').empty();
    });
    $(".Viewall").hide();
})
var currentRefno = "";
var ifalter = getParameterByName("status");


function Initializedpage() {
    $('#OTApproverTable').DataTable({
        ajax: {
            url: '../Approval_OT/GetApproverOTList',
            type: "GET",
            datatype: "json",
            //success: function () {
            //    alert("asd")
            //}
        },
      
       
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        
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
        initComplete:function(){
            var Overtimetype = getParameterByName("OverTimeType");
            var Approved = getParameterByName("Approved");
            var table = $('#OTApproverTable').DataTable();

          
            if (Overtimetype != null) {
                $(".refnoe").trigger("click");
                if (!table.data().any()) {
                    var Refno = getParameterByName("RefNo");
                    swal("OT Request \n"+Refno+" is Finished");
                }
            }
            if (Approved != null) {
                swal("OT Already approved by " + Approved);
             
            }
        },
        columns: [
              {
                  title: "OT Reference No.", className: "refnoe", data: function (x) {
                      //var Overtimetype = getParameterByName("OverTimeType");
                      //if (Overtimetype != "") {
                      //    $(".refnoe").trigger("click");
                      //}
                      return data = "<button type='button' class='btn btn-s bg-green'> <i class='fa fa-expand' ></i> " + x.OT_RefNo + "</button>"

                  }
              },
              { title: "Section", data: "Section" },
              {
                  title: "Date Created", data: function (x) {
                      return moment(x.CreateDate).format("MM/DD/YYYY")
                  }, name: "CreateDate"
              },
              {
                  title: "Overtime Type", data: "OvertimeType"
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
                           return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"
                       }
                       else {
                           return x.ApprovedGeneralManager
                       }

                   }
               },
              {
                   title: "Factory General Manager", data: function (x) {
                       if (x.StatusMax > 2 && x.ApprovedFactoryGeneralManager == null) {
                           return data = "<button type='button' class= 'btn btn-s bg-orange'>Pending</button>"
                       }
                       else if (x.ApprovedFactoryGeneralManager == null) {
                           return data = "<button type='button' class= 'btn btn-s bg-green'>-</button>"
                       }
                       else {
                           return x.ApprovedFactoryGeneralManager
                       }
                   }
               },

        ],

    });
    $('#OTApproverTable tbody').off('click');
    $('#OTApproverTable tbody').on('click', '.refnoe', function () {
        var table = $('#OTApproverTable').DataTable();
        var data = table.row(this).data();
        
        $.ajax({
            url: '../Approval_OT/VerifyUser',
            type: 'POST',
            data: { refNo: data.OT_RefNo, ifalter: ifalter },
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
                GetDetails(data.OT_RefNo, data.OvertimeType);
                $("#OTDetails").modal("show");
            }
        });

        
    });
    $('#OTApproverTable tbody').on('click', '.btnAppr', function () {
        var table = $('#OTApproverTable').DataTable();
        var data = table.row($(this).parents('tr')).data();
        GetApprovers(data.OT_RefNo);
        $("#AF_ApproversModal").modal("show");
    });
   
}

function GetDetails(data,OTType) {
   $('#OTApproverDetails').DataTable({
                    ajax: {
                        url: '../Approval_OT/GetApproverOTDetailsList',
                        type: "GET",
                        datatype: "json",
                        data: {
                            OTRefNo: data,
                            OTType: OTType
                        },

                    },
                    createdRow: function (row, data, dataIndex) {
                        $(row).addClass(data.EmployeeNo);
                    },
                    lengthMenu: [[10, 50, 100], [10, 50, 100]],
                    
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
                                    return " <input type='checkbox' id=OT_here_" + data.ID + " class='empmod filled-in chk-col-light-blue' " + checked + " name='employchosen' "+"/>" +
                                            " <label class=checker for=OT_here_" + data.ID + "></label>"

                                }, orderable: false, searchable: false
                          },
                          //{ data: "OT_RefNo" },
                          { data: "EmployeeNo" },
                          {
                              data: function (x) {
                                  return x.First_Name + " " + x.Family_Name
                              }
                          },
                          { data: "SectionName" },
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
                          { data: "CumulativeOT", className:"text-center"},
                          { data: "Requestor", className: "text-center" },
                    { data: "ActualOut", className: "text-center" }

                    ],

                });
   setTimeout(function () { $('#OTApproverDetails').DataTable().ajax.reload(); }, 500);
}

function GetApprovers(data) {
    $('#AF_ApproverStatustable').DataTable({
        ajax: {
            url: '../Approval_OT/GetApproverList',
            type: "GET",
            datatype: "json",
            data: { OTRefNo: data },

        },
        lengthChange: false,
        searching:false,
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
                          if (x.Position == "General Manager") {
                              label = "<button type='button' class='btn btn-sm bg-green'>Not Necessary</button>"
                          }
                          else {
                              if (x.Approved == 1)
                              {
                                  label= "<button type='button' class='btn btn-sm bg-green'>Approved</button>" 
                              }
                              else if (x.Approved == 0){
                                  label= "<button type='button' class='btn btn-sm bg-orange'>Pending</button>"
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
              //{
              //    title: "Resend", data: function (x) {
              //        var label = "<button type='button' class='btn btn-sm bg-green'>Done</button>"
              //        if (x.Approved == false) {
              //            label = "<button type='button' class='btn btn-info' onclick=Resend('" + x.Position.replace(/ /g, '') + "','" + x.RefNo + "','" + x.EmployeeNo + "','Resend')> Resend <i class='fa fa-share'></i> </button> " +
              //                    "<button type='button' class='btn btn-info' onclick=SetAlternatives('" + x.Position.replace(/ /g, '') + "','" + x.RefNo + "','" + x.EmployeeNo + "','Alter')> Mail Alternatives <i class='fa fa-share'></i> </button>"
              //        }
              //        return label
              //    }
              
              //},
             

        ],

    });

}

function ApprovedOT() {
    var table = $('#OTApproverDetails').DataTable();
    var ApprovedOTrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    var Type = "";
    table.rows().every(function () {
        var d = this.data();
        Type = d.OvertimeType;
        d.counter++;
        var item = {
            ID: d.ID,
            OT_RefNo: d.OT_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#OT_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedOTrows.push(item);
    });
    
    if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../Approval_OT/ApprovedOT',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedOTrows,
                ifalter: ifalter,
                OTType: Type
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("OT Approved Successfully");
                notify("Saved!", "OT Approved Successfully", "success");

                $("#OTDetails").modal("hide");
                Initializedpage();
            },
            error: function (xhr, ajaxOptions, thrownError) {
                notify("Saved!", "OT Approved Successfully", "success");

                $("#OTDetails").modal("hide");
                Initializedpage();
            }
        });
    }
    else {
        ContinueApproved();
    }
    
}

function CommentforRejection() {

}

function RejectedOT() {
    var table = $('#OTApproverDetails').DataTable();
    var ApprovedOTrows = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            ID: d.ID,
            OT_RefNo: d.OT_RefNo,
            EmployeeNo: d.EmployeeNo,
            Approved: ($('#OT_here_' + d.ID).is(":checked")) ? true : false
        }
        ApprovedOTrows.push(item);
    });
    //if (allrow || GlobalAcceptance) {
        $.ajax({
            url: '../Approval_OT/RejectedOT',
            type: 'POST',
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({
                GetApproved: ApprovedOTrows,
                ifalter: ifalter
            }),
            datatype: "json",
            success: function (returnData) {
                //swal("OT Rejected");
                notify("Saved!", "OT Rejected", "success");
                $("#OTDetails").modal("hide");
                Initializedpage();
            }
        });
    //}
    //else {
    //    ContinueApproved();
    //}

}

function SetAlternatives(Pos, RefNo, EmployeeNo, ResendAlter) {
    $("#posname").text(Pos.replace(/([A-Z])/g, ' $1').trim());
    $("#AlternativesModal").modal("show");
    currentRefno = RefNo;
}

function Sendmail() {
    Resend($("#posname").text(), currentRefno, $("#Supervisor").val(), "Alter");
    $("#AlternativesModal").modal("hide");
}

function Resend(Pos, RefNo, EmployeeNo, ResendAlter) {
    $.ajax({
        url: '../Approval_OT/Resendmail',
        type: 'POST',
        data: {
            RefNo: RefNo,
            Position : Pos,
            EmployeeNo: EmployeeNo,
            ResendAlter: ResendAlter
        },
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                    swal("Email sent");
            }
            else {
                    swal(returnData.msg);
            }
        }
    });
}

function getEmployeeNo_SectionSupervisor() {
    var options = '';
    var datas = document.getElementsByName("Supervisor")[0].value;

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
        data: { Agency: $("#Supervisor").val() },
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
                options += '<option value="' + returnData.list[i].ADID + '" />';
            }
            $("#EmployeeNoList_Supervisor").empty().append(options);
            document.getElementById('EmployeeNoList_Supervisor').innerHTML = options;

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}



function CancelRequest() {
    var table = $('#OTApproverDetails').DataTable();
    var SelectedRefNo = [];
    var allrow = $('.empmod:checked').length == $('.empmod').length;
    var EmployeeList = $('input[type="checkbox"][name="employchosen"]:checked').map(function () { return this.id; }).get();

    //table.rows().every(function () {
    //    var d = this.data();
    //    d.counter++;
    //    SelectedRefNo.push(d.OT_RefNo);
    //});

    $.ajax({
        url: '../Approval_OT/CancelledRefNo',
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
                //swal("OT Request Cancelled");
                notify("Saved!", "OT Request Cancelled", "success");
                $("#OTDetails").modal("hide");
                //Initializedpage();
            }
        }
    });
}

