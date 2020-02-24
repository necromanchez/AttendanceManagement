$(function () {
    //Initializedpage();
    Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    $("#DateAdjust").datepicker().datepicker("setDate", new Date());
  
    $("#Month").val(GetMonth());
    $("#Year").val(GetYear());
    $("#btnAdjustmentDownload").on("click", function () { window.open('../WorkTimeSummary/ExportAdjust?Month=' + $("#Month").val() + "&Year=" + $("#Year").val() + "&Section=" + $("#Section").val()); });

    $(".theshow").hide();
    $("#Search").on("click", function () {
        $("#loading_modal").modal("show")
        $(".theshow").show();
        GenerateDaysname();
        Initializedpage();
       
    });
    GetUser();
   

    $(".reloadtbl").on("click", function () {
        $(".reloadclass").trigger("click");
    });
   
});

var theDayShift = 0;
var theNightShift = 0;

var Pcountall = 0;
var Bcountall = 0; //DayShift
var Pcount = 0;
var Bcount = 0; //DayShift
var Ycount = 0;//NightShift
var Ycount = 0;
var MLcount = 0;

function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section').val(returnData.usersection);
            $("#Search").trigger("click");
        }
    });
}

function GetMonth() {
    var d = new Date();
    var n = d.getMonth() +1;
    return n;
}
function GetYear() {
    var d = new Date();
    var n = d.getFullYear();
    return n;
}

function HeaderData() {
    var table = $('#AttenanceTbl').DataTable();
    $.ajax({
        type: 'GET',
        url: '../WorkTimeSummary/GetHeaderData',
        data: {
            Month: $("#Month").val(),
            Year : $("#Year").val(),
            Section : $("#Section").val()
        },
        dataType: 'json',
        success: function (returnData) {
            $("#DStotal").text(returnData.Dayshift);
            $("#DSper").text(returnData.DayShiftper + "%");
            $("#NStotal").text(returnData.NightShift);
            $("#NSper").text(returnData.NightShiftper +"%");
            $("#total").text(table.data().count());
            var totalper = returnData.DayShiftper + returnData.NightShiftper;
            $("#per").text(totalper.toFixed(2) + "%");
        }

    });
}


function ShowOutput(data, day) {
    var today = new Date();
    var dd = today.getDate();//getDate().toString().padStart(2, 0);//String(today.getDate()).padStart(2, '0');
    var mm = today.getMonth()+1;//String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    data = (data == null) ? "" : data;
    today = mm + '/' + dd + '/' + yyyy;
    var Datereg = $("#Month").val() + "/"+day+"/"+$("#Year").val();

    var Weekday = GetResult(day);
    //console.log(data.indexOf('AB'));
   
    if (Date.parse(Datereg) <= Date.parse(today)) {
        if ((Weekday == "Sun" || Weekday == "Sat")) {
            return "<p class='text-aqua'>NW</p>"
        }
        else if ((Weekday == "Sun" || Weekday == "Sat")) {
            Pcount++;
            return "<p class='text-green'>" + data + "</p>"
        }
        else if (data.toLowerCase().indexOf('ab') > -1) {
            return "<p class='text-red'>" + data + "</p>"
        }
        else {
            Pcountall++;
            if (data != null && data == "P") {
                Pcount++;
                return "<p class='text-green'>" + data + "</p>"
            }
            else {
                console.log(data.indexOf('HD'));
                if (data.toLowerCase().indexOf('n') > -1) {
                    if (data.indexOf("HD") > -1) { Ycount += parseFloat('.5'); }
                    if (data.indexOf("ML") > -1) { MLcount++; }
                    else { Ycount++;}
                }
                else {
                    if (data.indexOf("HD") > -1) { Bcount += parseFloat('.5'); }
                    if (data.indexOf("ML") > -1) { MLcount++; }
                    else { Bcount++;}
                }
                Pcount++;
                return "<p class='text-green'>" + data + "</p>"
            }
        }
    }
    else {
        return "<p class='text-gray'>-</p>"

    }
   
}

function GetResult(day) {
    var dateString = $("#Month").val() + '-' + day + '-' + $("#Year").val();
    var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    var d = new Date(dateString);
    var dayName = days[d.getDay()];
    return dayName;
}

function daysInMonth(month, year) {
    return new Date(year, month, 0).getDate();
}

function GenerateDaysname(){

    $("#Daysname").empty();
    var loopstr = "";
    for (var x = 1; x <= 31; x++) {
        loopstr += "<td>" + GetResult(x) + "</td>"
    }
    $(".Daysname").empty().append(loopstr);
   
}


function Initializedpage() {
    $.ajax({
        url: '../WorkTimeSummary/GeAttendanceMonitoringList',
        data: {
            Month: $("#Month").val(),
            Year : $("#Year").val(),
            Section : $("#Section").val()
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            //console.log(returnData.data);
            var obj = JSON.parse(returnData.data);
            //console.log(obj);
            $('#AttenanceTbl').DataTable({
                data: obj,
                scrollX: true,
                //lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
                pageLength: 10,
                lengthChange: false,
                scrollY: "600px",
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
                lengthChange:false,
                columns: [

                      { data: "EmpNo", className: "reloadclass", },
                      { data: "EmployeeName" },
                      { data: "Position" },
                      { data: "CostCenter_AMS" },
                      { data: "Schedule", visible: false },
                      {
                          data: function (x) {

                              return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCenter_AMS + "')>Show Process</button>";

                          },
                      },
                         {
                             data: function (x) {
                                 Pcountall = 0;
                                 return ShowOutput(x[1],1)
                                 }
                         },
                      {
                          data: function (x) {
                              return ShowOutput(x[2],2)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[3],3)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[4],4)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[5],5)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[6],6)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[7],7)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[8],8)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[9],9)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[10],10)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[11],11)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[12],12)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[13],13)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[14],14)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[15],15)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[16],16)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[17],17)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[18],18)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[19],19)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[20],20)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[21],21)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[22],22)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[23],23)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[24],24)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[25],25)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[26],26)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[27],27)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[28], 28)
                              }
                      },
                      {
                          data: function (x) {
                              return ShowOutput(x[29], 29)
                              }
                      },
                      {
                          data: function (x) {
                              if (x[30] != null) {
                                  return ShowOutput(x[30], 30)
                              }
                              else { return '' }
                          }
                      },
                       {
                           data: function (x) {
                               if (x[31] != null) {
                                   return ShowOutput(x[31], 31)
                               }
                               else { return '' }
                           }
                       },

                      {
                          data: function (x) {
                              if (x.Status.toLowerCase() == "active") {
                                  colorhere = "#33bf7a";
                              }
                              else {
                                  colorhere = "#FF9898";
                              }
                              return "<button type='button' class='btn btn-sm' style='background-color:" + colorhere + "; color:white;' alt='alert' class='model_img img-fluid' onclick=UpdateStatus('" + x.EmpNo + "')>" +
                                       "<i class='fa fa-user-md'> " + x.Status + " </i>" +
                                   "</button> "
                          }
                      },
                      {
                          data: function (x) {
                              Pcountall = Pcount;
                              return Pcountall;
                          }
                      },
                       {
                           data: function (x) {
                               Bcountall = Bcount;
                               Bcount = 0;
                               return Bcountall;
                           }
                       },
                        {
                            data: function (x) {
                                Ycountall = Ycount;
                                Ycount = 0;
                                return Ycountall;
                            }
                        },
                         {
                             data: function (x) {
                                 //Pcountall = Pcount;
                                 //Pcount = 0;
                                 return MLcount;
                             }
                         },
                      {
                          data: function (x) {
                              Pcountall = Pcount;
                              Pcount = 0;
                              var days = daysInMonth($("#Month").val(), $("#Year").val());
                              var Ppercentage = ((Pcountall / days) * 100).toFixed(2);
                              return Ppercentage + "%";
                          }
                      },



                ],
                initComplete: function () {
                    var table = $('#AttenanceTbl').DataTable();
                    var numDays = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
                    for (var x = numDays; x < 31; x++) {
                        table.column(x + 6).visible(false);
                    }
                    $('.dataTables_filter input').addClass('form-control form-control-sm');
                    if (!table.data().any()) {
                        swal("No Data found");
                    }
                    else {
                        HeaderData();
                    }

                    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

                    var monthname = $("#Month").val();

                    $(".changehead").html(months[monthname-1] + ' ' + $("#Year").val());

                    Initializedpage_WorkingHours();
                   // $("#loading_modal").modal("hide")

                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 6
                    //rightColumns: 1
                },
                destroy:true
            });
        }
    });

}

function GetProcess(EmpNo, CostCode) {
    $.ajax({
        type: 'POST',
        url: '../WorkTimeSummary/GetAttendanceEmployeeProcess',
        data: {
                EmpNo: EmpNo,
                CostCode: CostCode
        },
        dataType: 'json',
        success: function (returnData) {
            var processtbl = "";
            $("#processtbl").html("");
            for (var x = 0; x < returnData.list.length; x++)
            {
                if (returnData.list[x].Line == null) {
                    processtbl += "<tr>" +
                                 "<td></td>" +
                                 "<td></td>" +
                                "</tr>";
                }
                else {
                    processtbl += "<tr>" +
                                  "<td>" + returnData.list[x].Line + "</td>" +
                                  "<td>" + returnData.list[x].Skill + "</td>" +
                                 "</tr>";
                }
                
            }
           
            $("#processtbl").append(processtbl);
            $("#ProcessModal").modal("show");
        }


    });

}

function UpdateLeave(Date, EmpNo) {
    //$("#DateLeavemodal").modal("show");
    //console.log(Date + EmpNo);

}

function UploadAdjustment() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("btnAdjustmentUpload").files[0];
    files.append('files[0]', file1);
    files.append('DateChange', $("#DateAdjust").val());
    $.ajax({
        type: 'POST',
        url: '../WorkTimeSummary/UploadAdjustment',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide")
                swal("Adjustment Updated");
                $("#btnAdjustmentUpload").val("");
                Initializedpage();
            }
            else {
                swal("An error occured");

            }
        },
        error: function (error) {

        }
    });
}

function PerDaychecker(Month, Year, Day, EmpNo) {

    $.ajax({
        url: '../WorkTimeSummary/CheckLeave',
        data: {
            Month: Month,
            Year: Year,
            Day: Day,
            EmpNo: EmpNo
        },
        type: 'GET',
        dataType: 'JSON',
    }).done(function (data, textStatus, xhr) {
        console.log(data);
    }).fail(function (xhr, textStatus, errorThrown) {
        console.log(errorThrown, textStatus);
    });
}