$(function () {


   

});

function Initializedpage_EmployeeShift() {
    var d = new Date();
    $.ajax({
        url: '../WorkTimeSummary/GETEmployeeShift',
        data: {
            Month: $("#Month").val(),
            Year: $("#Year").val(),
            Section:selectedSection
        },
        type: 'GET',
        dataType: 'JSON',
        success: function (returnData) {
            //console.log(returnData.data);
            var obj = JSON.parse(returnData.data);
            $('#EmployeeShifttbl').DataTable({
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
                        title: "WorkTimeSummary_Shift" + formatDate(d) + "_" + selectedSection
                    }
                ],
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
               // lengthChange: false,
                columns: [
                    { title: "No", data: "Rownum", className: "reloadclass", name:"Rownum" },
                    { title: "Employee No", data: "EmpNo", name: "EmpNo" },
                    { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
                    { title: "Position", data: "Position", name: "Position" },
                    { title: "Cost Center", data: "CostCode", name: "CostCode" },
                    { title: "Schedule", data: "Schedule", name: "Schedule" },
                    {
                        title: "Process", data: function (x) {

                            return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                        },
                    },
                      {
                           title: "1", data: function (x) {

                               return x[1]
                           }
                      },
                     {
                           title: "2", data: function (x) {

                               return x[2]
                           }
                     },
                     {
                         title: "3", data: function (x) {

                             return x[3]
                         }
                     },
                     {
                         title: "4", data: function (x) {

                             return x[4]
                         }
                     },
                     {
                         title: "5", data: function (x) {

                             return x[5]
                         }
                     },
                     {
                         title: "6", data: function (x) {

                             return x[6]
                         }
                     },
                     {
                         title: "7", data: function (x) {

                             return x[7]
                         }
                     },
                     {
                         title: "8", data: function (x) {

                             return x[8]
                         }
                     },
                     {
                         title: "9", data: function (x) {

                             return x[9]
                         }
                     },
                     {
                         title: "10", data: function (x) {

                             return x[10]
                         }
                     },
                     {
                         title: "11", data: function (x) {

                             return x[11]
                         }
                     },
                     {
                         title: "12", data: function (x) {

                             return x[12]
                         }
                     },
                     {
                         title: "13", data: function (x) {

                             return x[13]
                         }
                     },
                     {
                         title: "14", data: function (x) {

                             return x[14]
                         }
                     },
                     {
                         title: "15", data: function (x) {

                             return x[15]
                         }
                     },
                     {
                         title: "16", data: function (x) {

                             return x[16]
                         }
                     },
                     {
                         title: "17", data: function (x) {

                             return x[17]
                         }
                     },
                     {
                         title: "18", data: function (x) {

                             return x[18]
                         }
                     },
                     {
                         title: "19", data: function (x) {

                             return x[19]
                         }
                     },
                     {
                         title: "20", data: function (x) {

                             return x[20]
                         }
                     },
                     {
                         title: "21", data: function (x) {

                             return x[21]
                         }
                     },
                     {
                         title: "22", data: function (x) {

                             return x[22]
                         }
                     },
                     {
                         title: "23", data: function (x) {

                             return x[23]
                         }
                     },
                     {
                         title: "24", data: function (x) {

                             return x[24]
                         }
                     },
                     {
                         title: "25", data: function (x) {

                             return x[25]
                         }
                     },
                     {
                         title: "26", data: function (x) {

                             return x[26]
                         }
                     },
                     {
                         title: "27", data: function (x) {

                             return x[27]
                         }
                     },
                     {
                         title: "28", data: function (x) {

                             return x[28]
                         }
                     },
                     {
                         title: "29", data: function (x) {

                             return x[29]
                         }
                     },
                     {
                         title: "30", data: function (x) {
                             if (x[30] != null) {
                                 return x[30]
                             }
                             else {
                                 return "";
                             }
                         }
                     },
                     {
                         title: "31", data: function (x) {
                             if (x[31] != null) {
                                 return x[31]
                             }
                             else {
                                 return "";
                             }
                         }
                     },
                ],
                drawCallback: function (settings) {
                    $("#loading_modal2").modal("hide");
                    var table = $('#EmployeeShifttbl').DataTable();
                    table.columns.adjust();
                },
                initComplete: function () {

                    var table = $('#EmployeeShifttbl').DataTable();
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
                    $("#loading_modal").modal("hide");
                    table = $('#EmployeeShifttbl').DataTable();
                    table.columns.adjust();
                    $("#EmployeeSchedule").show();
                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 7
                    //rightColumns: 1
                },
                destroy: true
            });
            $('#EmployeeShifttbl').on('length.dt', function (e, settings, len) {
                console.log('New page length: ' + len);
                $("#loading_modal2").modal("show");
            });
        }
    });
}