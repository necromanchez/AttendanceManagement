var totalHours = 0;
var total = 0;
function Initializedpage_WorkingHours() {
    $.ajax({
        url: '../WorkTimeSummary/GeAttendanceMonitoringList_WorkingHours',
        data: {
            Month: $("#Month").val(),
            Year: $("#Year").val(),
            Section: $("#Section").val()
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
                lengthChange: false,
                scrollY: "600px",
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
                lengthChange: false,
                columns: [
                      { data: "EmpNo", className: "reloadclass" },
                      { data: "EmployeeName" },
                      { data: "Position" },
                      { data: "CostCenter_AMS" },
                      { data: "Schedule", visible: false },
                      {
                          data: function (x) {

                              return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCenter_AMS + "')>Show Process</button>";

                          }, visible:false
                      },
                       {
                           data: function (x) {
                               total += parseFloat(x[1]);
                               return (x[1] != 0)?"<p class='text-green' style='font-size:16px !important';>" + x[1] + "</p>":x[1];
                           }
                       },
                      {
                          data: function (x) {
                              total += parseFloat(x[2]);
                              return (x[2] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[2] + "</p>" : x[2];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[3]);
                              return (x[3] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[3] + "</p>" : x[3];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[4]);
                              return (x[4] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[4] + "</p>" : x[4];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[5]);
                              return (x[5] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[5] + "</p>" : x[5];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[6]);
                              return (x[6] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[6] + "</p>" : x[6];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[7]);
                              return (x[7] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[7] + "</p>" : x[7];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[8]);
                              return (x[8] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[8] + "</p>" : x[8];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[9]);
                              return (x[9] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[9] + "</p>" : x[9];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[10]);
                              return (x[10] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[10] + "</p>" : x[10];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[11]);
                              return (x[11] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[11] + "</p>" : x[11];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[12]);
                              return (x[12] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[12] + "</p>" : x[12];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[13]);
                              return (x[13] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[13] + "</p>" : x[13];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[14]);
                              return (x[14] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[14] + "</p>" : x[14];
                          }
                      },
                      {
                          data: function (x) {
                             total += parseFloat(x[15]);
                             return (x[15] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[15] + "</p>" : x[15];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[16]);
                              return (x[16] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[16] + "</p>" : x[16];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[17]);
                              return (x[17] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[17] + "</p>" : x[17];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[18]);
                              return (x[18] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[18] + "</p>" : x[18];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[19]);
                              return (x[19] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[19] + "</p>" : x[19];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[20]);
                              return (x[20] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[20] + "</p>" : x[20];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[21]);
                              return (x[21] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[21] + "</p>" : x[21];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[22]);
                              return (x[22] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[22] + "</p>" : x[22];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[23]);
                              return (x[23] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[23] + "</p>" : x[23];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[24]);
                              return (x[24] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[24] + "</p>" : x[24];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[25]);
                              return (x[25] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[25] + "</p>" : x[25];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[26]);
                              return (x[26] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[26] + "</p>" : x[26];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[27]);
                              return (x[27] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[27] + "</p>" : x[27];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[28]);
                              return (x[28] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[28] + "</p>" : x[28];
                          }
                      },
                      {
                          data: function (x) {
                              total += parseFloat(x[29]);
                              return (x[29] != 0) ? "<p class='text-green' style='font-size:16px !important';>" + x[29] + "</p>" : x[29];
                          }
                      },
                      {
                          data: function (x) {
                              if (x[30] != null) {
                                  total += parseFloat(x[30]);
                                  return "<p class='text-green' style='font-size:16px !important';>" + x[30] + "</p>";
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          data: function (x) {
                              if (x[31] != null) {
                                  total += parseFloat(x[31]);
                                  return "<p class='text-green' style='font-size:16px !important';>" + x[31] + "</p>";
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          data: function (x) {
                              totalHours = total;
                               total = 0;
                               return totalHours;
                          }
                      },

                ],
                initComplete: function () {
                    var tables = $('#AttenanceTbl_WorkingHours').DataTable();
                    var numDays = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
                    for (var x = numDays; x < 31; x++) {
                        tables.column(x + 6).visible(false);
                    }
                    $('.dataTables_filter input').addClass('form-control form-control-sm');
                    Initializedpage_OTHours();
                    //$("#loading_modal").modal("hide")
                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 6
                    //rightColumns: 1
                },
                destroy: true
            });

        }
    });
}