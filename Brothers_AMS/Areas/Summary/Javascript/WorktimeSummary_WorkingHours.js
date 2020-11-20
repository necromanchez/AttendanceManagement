var totalHours = 0;
var total = 0;



function Initializedpage_WorkingHours() {
    var d = new Date();
    $.ajax({
        url: '../WorkTimeSummary/GeAttendanceMonitoringList_WorkingHours',
        data: {
            Month: $("#Month").val(),
            Year: $("#Year").val(),
            Section: selectedSection,//$("#Section").val()
            Agency: $("#BIPH_Agency").val(),
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            //console.log(returnData.data);
            var obj = JSON.parse(returnData.data);
            $('#AttenanceTbl_WorkingHours').DataTable({
                data: obj,
                scrollX: true,
                pageLength: 10,
                //lengthMenu: [10, 100, 500, 1000, 5000],
                lengthMenu: [[10, 50, 100], [10, 50, 100]],
                lengthChange: true,
                loadonce: false,
                dom: 'lBfrtip',
                buttons: [
                    {
                        extend: 'excel',
                        title: "WorkTimeSummary_DTRBreakdown" + formatDate(d) +"_"+ selectedSection
                    }
                ],
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
                scrollY: "600px",
                scrollCollapse: true,
                //lengthChange: false,
                columns: [
                    { title: "No", data: "Rownum", className: "reloadclass", name: "Rownum"},
                    { title: "Employee No", data: "EmpNo", name: "EmpNo" },
                    { title: "Employee Name", data: "EmployeeName", className: "reloadclass", name: "EmployeeName" },
                    { title: "Position", data: "Position", name: "Position" },
                    { title: "Cost Center", data: "CostCode", name: "CostCode" },
                    { title: "Current Schedule", data: "Schedule", name: "Schedule" },
                      {
                          title: "Process", data: function (x) {

                              return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                          }, 
                      },
                       {
                           title: "1", data: function (x) {
                               total += parseFloat(x[1]);
                               return (x[1] != 0)?"<p class='text-green Adjustbrand'> " + x[1] + "</p>":x[1];
                           }
                       },
                      {
                          title: "2", data: function (x) {
                              total += parseFloat(x[2]);
                              return (x[2] != 0) ? "<p class='text-green Adjustbrand'> " + x[2] + "</p>" : x[2];
                          }
                      },
                      {
                          title: "3", data: function (x) {
                              total += parseFloat(x[3]);
                              return (x[3] != 0) ? "<p class='text-green Adjustbrand'> " + x[3] + "</p>" : x[3];
                          }
                      },
                      {
                          title: "4", data: function (x) {
                              total += parseFloat(x[4]);
                              return (x[4] != 0) ? "<p class='text-green Adjustbrand'> " + x[4] + "</p>" : x[4];
                          }
                      },
                      {
                          title: "5", data: function (x) {
                              total += parseFloat(x[5]);
                              return (x[5] != 0) ? "<p class='text-green Adjustbrand'> " + x[5] + "</p>" : x[5];
                          }
                      },
                      {
                          title: "6", data: function (x) {
                              total += parseFloat(x[6]);
                              return (x[6] != 0) ? "<p class='text-green Adjustbrand'> " + x[6] + "</p>" : x[6];
                          }
                      },
                      {
                          title: "7", data: function (x) {
                              total += parseFloat(x[7]);
                              return (x[7] != 0) ? "<p class='text-green Adjustbrand'> " + x[7] + "</p>" : x[7];
                          }
                      },
                      {
                          title: "8", data: function (x) {
                              total += parseFloat(x[8]);
                              return (x[8] != 0) ? "<p class='text-green Adjustbrand'> " + x[8] + "</p>" : x[8];
                          }
                      },
                      {
                          title: "9", data: function (x) {
                              total += parseFloat(x[9]);
                              return (x[9] != 0) ? "<p class='text-green Adjustbrand'> " + x[9] + "</p>" : x[9];
                          }
                      },
                      {
                          title: "10", data: function (x) {
                              total += parseFloat(x[10]);
                              return (x[10] != 0) ? "<p class='text-green Adjustbrand'> " + x[10] + "</p>" : x[10];
                          }
                      },
                      {
                          title: "11", data: function (x) {
                              total += parseFloat(x[11]);
                              return (x[11] != 0) ? "<p class='text-green Adjustbrand'> " + x[11] + "</p>" : x[11];
                          }
                      },
                      {
                          title: "12", data: function (x) {
                              total += parseFloat(x[12]);
                              return (x[12] != 0) ? "<p class='text-green Adjustbrand'> " + x[12] + "</p>" : x[12];
                          }
                      },
                      {
                          title: "13", data: function (x) {
                              total += parseFloat(x[13]);
                              return (x[13] != 0) ? "<p class='text-green Adjustbrand'> " + x[13] + "</p>" : x[13];
                          }
                      },
                      {
                          title: "14", data: function (x) {
                              total += parseFloat(x[14]);
                              return (x[14] != 0) ? "<p class='text-green Adjustbrand'> " + x[14] + "</p>" : x[14];
                          }
                      },
                      {
                          title: "15", data: function (x) {
                             total += parseFloat(x[15]);
                             return (x[15] != 0) ? "<p class='text-green Adjustbrand'> " + x[15] + "</p>" : x[15];
                          }
                      },
                      {
                          title: "16", data: function (x) {
                              total += parseFloat(x[16]);
                              return (x[16] != 0) ? "<p class='text-green Adjustbrand'> " + x[16] + "</p>" : x[16];
                          }
                      },
                      {
                          title: "17", data: function (x) {
                              total += parseFloat(x[17]);
                              return (x[17] != 0) ? "<p class='text-green Adjustbrand'> " + x[17] + "</p>" : x[17];
                          }
                      },
                      {
                          title: "18", data: function (x) {
                              total += parseFloat(x[18]);
                              return (x[18] != 0) ? "<p class='text-green Adjustbrand'> " + x[18] + "</p>" : x[18];
                          }
                      },
                      {
                          title: "19", data: function (x) {
                              total += parseFloat(x[19]);
                              return (x[19] != 0) ? "<p class='text-green Adjustbrand'> " + x[19] + "</p>" : x[19];
                          }
                      },
                      {
                          title: "20", data: function (x) {
                              total += parseFloat(x[20]);
                              return (x[20] != 0) ? "<p class='text-green Adjustbrand'> " + x[20] + "</p>" : x[20];
                          }
                      },
                      {
                          title: "21", data: function (x) {
                              total += parseFloat(x[21]);
                              return (x[21] != 0) ? "<p class='text-green Adjustbrand'> " + x[21] + "</p>" : x[21];
                          }
                      },
                      {
                          title: "22", data: function (x) {
                              total += parseFloat(x[22]);
                              return (x[22] != 0) ? "<p class='text-green Adjustbrand'> " + x[22] + "</p>" : x[22];
                          }
                      },
                      {
                          title: "23", data: function (x) {
                              total += parseFloat(x[23]);
                              return (x[23] != 0) ? "<p class='text-green Adjustbrand'> " + x[23] + "</p>" : x[23];
                          }
                      },
                      {
                          title: "24", data: function (x) {
                              total += parseFloat(x[24]);
                              return (x[24] != 0) ? "<p class='text-green Adjustbrand'> " + x[24] + "</p>" : x[24];
                          }
                      },
                      {
                          title: "25", data: function (x) {
                              total += parseFloat(x[25]);
                              return (x[25] != 0) ? "<p class='text-green Adjustbrand'> " + x[25] + "</p>" : x[25];
                          }
                      },
                      {
                          title: "26", data: function (x) {
                              total += parseFloat(x[26]);
                              return (x[26] != 0) ? "<p class='text-green Adjustbrand'> " + x[26] + "</p>" : x[26];
                          }
                      },
                      {
                          title: "27", data: function (x) {
                              total += parseFloat(x[27]);
                              return (x[27] != 0) ? "<p class='text-green Adjustbrand'> " + x[27] + "</p>" : x[27];
                          }
                      },
                      {
                          title: "28", data: function (x) {
                              total += parseFloat(x[28]);
                              return (x[28] != 0) ? "<p class='text-green Adjustbrand'> " + x[28] + "</p>" : x[28];
                          }
                      },
                      {
                          title: "29", data: function (x) {
                              total += parseFloat(x[29]);
                              return (x[29] != 0) ? "<p class='text-green Adjustbrand'> " + x[29] + "</p>" : x[29];
                          }
                      },
                      {
                          title: "30", data: function (x) {
                              if (x[30] != null) {
                                  total += parseFloat(x[30]);
                                  return (x[30] != 0) ? "<p class='text-green Adjustbrand'> " + x[30] + "</p>" : x[30]; 
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          title: "31", data: function (x) {
                              if (x[31] != null) {
                                  total += parseFloat(x[31]);
                                  return (x[31] != 0) ? "<p class='text-green Adjustbrand'> " + x[31] + "</p>" : x[31]; 
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          title: "Total Hours", data: function (x) {
                              totalHours = total;
                               total = 0;
                               return totalHours;
                          }
                      },

                ],
                drawCallback: function (settings) {
                    $("#loading_modal2").modal("hide");
                    var table = $('#AttenanceTbl_WorkingHours').DataTable();
                    table.columns.adjust();
                },
                initComplete: function () {


                    var table = $('#AttenanceTbl_WorkingHours').DataTable();
                    var start = 7;


                    var numDays = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
                    for (var x = numDays; x < 31; x++) {
                        table.column(x + 7).visible(false);
                    }
                    for (var x = 1; x <= 31; x++) {
                        var daywk = GetResult(x);
                        $(table.column(start).header()).text(daywk + '\n' + x);
                        start++;
                    }
                    table.columns.adjust();

                    $("#loading_modal").modal("hide");
                    table = $('#AttenanceTbl_WorkingHours').DataTable();
                    table.columns.adjust();
                    $("#DTRBreak").show();
                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 7
                    //rightColumns: 1
                },
                destroy: true
            });
            var table = $('#AttenanceTbl_WorkingHours').DataTable();
            $('#AttenanceTbl_WorkingHours').on('length.dt', function (e, settings, len) {
                console.log('New page length: ' + len);
                $("#loading_modal2").modal("show");
            });
        }
    });
}