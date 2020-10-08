var totalHoursOT = 0;
var totalOT = 0;


function DataConverter(data) {
    if (data.toLowerCase().indexOf('inc') > -1) {
        var res = data.split(" ");
        data = res[0];
        return (data == "0.0") ? "<p class='text Adjustbrand'>" + data + "</p>" : "<p class='text-red Adjustbrand'>" + data + "</p>"
        
    }
    //else if (data.toLowerCase().indexOf('noot') > -1) {
    //    var res = data.split(" ");
    //    data = res[0];
    //    if (data > 0) {
    //        totalOT += parseFloat(data);
    //    } 
    //     return (data == "0.0")?"<p class='text Adjustbrand'>" + data + "</p>":"<p class='text-red Adjustbrand'>" + data + "</p>"
    //}
    //else if (data.toLowerCase().indexOf('wot') > -1) {
    //    var res = data.split(" ");
    //    data = res[0];
    //    if (data > 0) {
    //        totalOT += parseFloat(data);
    //    }
    //    return "<p class='text-green Adjustbrand'>" + data + "</p>"
    //}
    else {
        totalOT += parseFloat(data);
        return "<p class='text Adjustbrand'>" + data + "</p>"
    }


}

function Initializedpage_OTHours() {
    var d = new Date();
    $.ajax({
        url: '../WorkTimeSummary/GeAttendanceMonitoringList_OTBreakDown',
        data: {
            Month: $("#Month").val(),
            Year: $("#Year").val(),
            Section: selectedSection,
            Agency: $("#BIPH_Agency").val(),
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            //console.log(returnData.data);
            var obj = JSON.parse(returnData.data);
            $('#AttenanceTbl_OTHours').DataTable({
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
                        title: "WorkTimeSummary_OTBreakdown" + formatDate(d) + "_" + selectedSection
                    }
                ],
                scrollY: "600px",
                //scrollX: "1000px",
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
                //lengthChange: false,
                columns: [
                    { title: "No", data: "Rownum", className: "reloadclass", name: "Rownum"  },
                    { title: "Employee No", data: "EmpNo", name: "EmpNo" },
                    { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
                    { title: "Position", data: "Position", name: "Position"  },
                    { title: "Cost Center", data: "CostCode", name: "CostCode" },
                    { title: "Schedule", data: "Schedule", name: "Schedule" },
                      //{ data: "Schedule", visible: false },
                      {
                          title: "Process", data: function (x) {

                              return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                          },
                      },
                      {
                          title: "1", data: function (x) {
                               
                               return DataConverter(x[1]);
                           }
                       },
                      {
                          title: "2", data: function (x) {
                             
                              return DataConverter(x[2]);
                          }
                      },
                      {
                          title: "3", data: function (x) {
                              
                              return DataConverter(x[3]);
                          }
                      },
                      {
                          title: "4", data: function (x) {
                             
                              return DataConverter(x[4]);
                          }
                      },
                      {
                          title: "5", data: function (x) {
                            
                              return DataConverter(x[5]);
                          }
                      },
                      {
                          title: "6", data: function (x) {
                           
                              return DataConverter(x[6]);
                          }
                      },
                      {
                          title: "7", data: function (x) {
                              
                              return DataConverter(x[7]);
                          }
                      },
                      {
                          title: "8", data: function (x) {
                             
                              return DataConverter(x[8]);
                          }
                      },
                      {
                          title: "9", data: function (x) {
                             
                              return DataConverter(x[9]);
                          }
                      },
                      {
                          title: "10", data: function (x) {
                             
                              return DataConverter(x[10]);
                          }
                      },
                      {
                          title: "11", data: function (x) {
                             
                              return DataConverter(x[11]);
                          }
                      },
                      {
                          title: "12", data: function (x) {
                             
                              return DataConverter(x[12]);
                          }
                      },
                      {
                          title: "13", data: function (x) {
                             
                              return DataConverter(x[13]);
                          }
                      },
                      {
                          title: "14", data: function (x) {
                             
                              return DataConverter(x[14]);
                          }
                      },
                      {
                          title: "15", data: function (x) {
                             
                              return DataConverter(x[15]);
                          }
                      },
                      {
                          title: "16", data: function (x) {
                              
                              return DataConverter(x[16]);
                          }
                      },
                      {
                          title: "17", data: function (x) {
                            
                              return DataConverter(x[17]);
                          }
                      },
                      {
                          title: "18", data: function (x) {
                             
                              return DataConverter(x[18]);
                          }
                      },
                      {
                          title: "19", data: function (x) {
                             
                              return DataConverter(x[19]);
                          }
                      },
                      {
                          title: "20", data: function (x) {
                              
                              return DataConverter(x[20]);
                          }
                      },
                      {
                          title: "21", data: function (x) {
                             
                              return DataConverter(x[21]);
                          }
                      },
                      {
                          title: "22", data: function (x) {
                             
                              return DataConverter(x[22]);
                          }
                      },
                      {
                          title: "23", data: function (x) {
                             
                              return DataConverter(x[23]);
                          }
                      },
                      {
                          title: "24", data: function (x) {
                             
                              return DataConverter(x[24]);
                          }
                      },
                      {
                          title: "25", data: function (x) {
                            
                              return DataConverter(x[25]);
                          }
                      },
                      {
                          title: "26", data: function (x) {
                             
                              return DataConverter(x[26]);
                          }
                      },
                      {
                          title: "27", data: function (x) {
                            
                              return DataConverter(x[27]);
                          }
                      },
                      {
                          title: "28", data: function (x) {
                            
                              return DataConverter(x[28]);
                          }
                      },
                      {
                          title: "29", data: function (x) {
                              
                              return DataConverter(x[29]);
                          }
                      },
                      {
                          title: "30", data: function (x) {
                              if (x[30] != null) {
                                 
                                  return DataConverter(x[30]);
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          title: "31", data: function (x) {
                              if (x[31] != null) {
                                  
                                  return DataConverter(x[31]);
                              }
                              else {
                                  return "";
                              }
                          }
                      },
                      {
                          title: "Total OT", data: function (x) {
                              totalHoursOT = totalOT;
                              totalOT = 0;
                              return totalHoursOT;
                          }
                      },

                ],
                drawCallback: function (settings) {
                    $("#loading_modal2").modal("hide");
                    var table = $('#AttenanceTbl_OTHours').DataTable();
                    table.columns.adjust();
                },
                initComplete: function () {
                   
                    var table = $('#AttenanceTbl_OTHours').DataTable();
                    var start = 7;


                    var numDays = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
                    for (var x = numDays; x < 31; x++) {
                        table.column(x + 7).visible(false);
                    }
                    for (var x = 1; x <= numDays; x++) {
                        var daywk = GetResult(x);
                        $(table.column(start).header()).text(daywk + '\n' + x);
                        start++;
                    }
                    table.columns.adjust();
                    table = $('#AttenanceTbl_OTHours').DataTable();
                    table.columns.adjust();
                    $("#OTV").show();
                    $("#loading_modal").modal("hide");
                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 7
                    //rightColumns: 1
                },
                destroy: true
            });

            var table = $('#AttenanceTbl_OTHours').DataTable();
            $('#AttenanceTbl_OTHours').on('length.dt', function (e, settings, len) {
                console.log('New page length: ' + len);
                $("#loading_modal2").modal("show");
            });
        }
    });
}



//var rawData = [[1582.3, 0], [28.95, 1], [1603, 2], [774, 3], [1245, 4], [85, 5], [1025, 6]];
//var dataSet = [{ label: "Precious Metal Price", data: rawData, color: "#E8E800" }];
//var ticks = [[0, "Gold"], [1, "Silver"], [2, "Platinum"], [3, "Palldium"], [4, "Rhodium"], [5, "Ruthenium"], [6, "Iridium"]];

//var options = {
//    series: {
//        bars: {
//            show: true
//        }
//    },
//    bars: {
//        align: "center",
//        barWidth: 0.5,
//        horizontal: true,
//        fillColor: { colors: [{ opacity: 0.5 }, { opacity: 1 }] },
//        lineWidth: 1
//    },
//    xaxis: {
//        axisLabel: "Price (USD/oz)",
//        axisLabelUseCanvas: true,
//        axisLabelFontSizePixels: 12,
//        axisLabelFontFamily: 'Verdana, Arial',
//        axisLabelPadding: 10,
//        max: 2000,
//        tickColor: "#5E5E5E",
      
//        color: "black"
//    },
//    yaxis: {
//        axisLabel: "Precious Metals",
//        axisLabelUseCanvas: true,
//        axisLabelFontSizePixels: 12,
//        axisLabelFontFamily: 'Verdana, Arial',
//        axisLabelPadding: 3,
//        tickColor: "#5E5E5E",
//        ticks: ticks,
//        color: "black"
//    },
//    legend: {
//        noColumns: 0,
//        labelBoxBorderColor: "#858585",
//        position: "ne"
//    },
//    grid: {
//        hoverable: true,
//        borderWidth: 2,
//        backgroundColor: { colors: ["#171717", "#4F4F4F"] }
//    }
//};

//$(document).ready(function () {
//    $.plot($("#flot-placeholder"), dataSet, options);
//    $("#flot-placeholder").UseTooltip();
//});

//var previousPoint = null, previousLabel = null;

//$.fn.UseTooltip = function () {
//    $(this).bind("plothover", function (event, pos, item) {
//        if (item) {
//            if ((previousLabel != item.series.label) ||
//         (previousPoint != item.dataIndex)) {
//                previousPoint = item.dataIndex;
//                previousLabel = item.series.label;
//                $("#tooltip").remove();

//                var x = item.datapoint[0];
//                var y = item.datapoint[1];

//                var color = item.series.color;
//                //alert(color)
//                //console.log(item.series.xaxis.ticks[x].label);                

//                showTooltip(item.pageX,
//                item.pageY,
//                color,
//                "<strong>" + item.series.label + "</strong><br>" + item.series.yaxis.ticks[y].label +
//                " : <strong>" + $.formatNumber(x, { format: "#,###", locale: "us" }) + "</strong> USD/oz");
//            }
//        } else {
//            $("#tooltip").remove();
//            previousPoint = null;
//        }
//    });
//};

//function showTooltip(x, y, color, contents) {
//    $('<div id="tooltip">' + contents + '</div>').css({
//        position: 'absolute',
//        display: 'none',
//        top: y - 10,
//        left: x + 10,
//        border: '2px solid ' + color,
//        padding: '3px',
//        'font-size': '9px',
//        'border-radius': '5px',
//        'background-color': '#fff',
//        'font-family': 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
//        opacity: 0.9
//    }).appendTo("body").fadeIn(200);
//}