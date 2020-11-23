function initDatePicker(dp) {
    

    var months = $("#Month").val() < 10 ? '0' + $("#Month").val() : $("#Month").val();

    var lastDay = new Date($("#Year").val(), $("#Month").val(), 0).getDate();
    var minDate = $("#Year").val() + '-' + months + '-' + '01';
    var maxDate = $("#Year").val() + '-' + months + '-' + lastDay;
    
    $('#' + dp).datepicker({
        todayBtn: "linked",
        orientation: "top right",
        autoclose: true,
        todayHighlight: true,
        minDate: new Date(minDate),
        maxDate: new Date(maxDate),
    });
}

function Initializedpage_EmployeeTimeinout222123() {
    var d = new Date();
    initDatePicker("hrDateFrom");
    initDatePicker("hrDateTo");

   
    //$('#hrDateFrom').attr('min', minDate);
    //$('#hrDateTo').attr('min', minDate);

    //$('#hrDateFrom').attr('max', maxDate);
    //$('#hrDateTo').attr('max', maxDate);

    //$('#wsDateFrom').attr('min', minDate);
    //$('#wsDateTo').attr('min', minDate);

    //$('#wsDateFrom').attr('max', maxDate);
    //$('#wsDateTo').attr('max', maxDate);


    $.ajax({
        url: '../WorkTimeSummary/GETEmployeeTimeinout',
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
            $('#Employeetimetbl').DataTable({
                data: obj,
                scrollX: true,
                pageLength: 10,
                //lengthMenu: [10, 100, 500, 1000, 5000],
                lengthMenu: [[10, 50, 100], [10, 50, 100]],
                serverSide: "true",
                lengthChange: true,
                loadonce: false,
                dom: 'lBfrtip',
                buttons: [
                    {
                        extend: 'excel',
                        title: "WorkTimeSummary_TimeInandOut" + formatDate(d) + "_" + selectedSection
                    },
                    {
                        text: 'HR Format',
                        action: function (e, dt, node, config) {
                            $("#HRExportmodal").modal("show");
                        }
                    }
                    
                ],
                scrollCollapse: true,
                order: [0, "asc"],
                processing: "true",
                scrollY: "600px",
                //scrollX: "1000px",
                scrollCollapse: true,
                //lengthChange: false,
                columns: [
                    { title: "No", data: "Rownum", className: "reloadclass", name: "Rownum" },
                    { title: "Employee No", data: "EmpNo", name: "EmpNo" },
                    { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
                    { title: "Position", data: "Position", name: "Position" },
                    { title: "Cost Center", data: "CostCode", name: "CostCode" },
                    { title: "Current Schedule", data: "Schedule", visible: true },
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

                    var table = $('#Employeetimetbl').DataTable();
                    table.columns.adjust();
                },
                initComplete: function () {

                    var table = $('#Employeetimetbl').DataTable();
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
                    table = $('#Employeetimetbl').DataTable();
                    table.columns.adjust();
                    $("#EmployeeTime").show();
                },
                fixedColumns: true,
                fixedColumns: {
                    leftColumns: 7
                    //rightColumns: 1
                },
                destroy: true
            });
        }
    });
}


function Initializedpage_EmployeeTimeinout() {
    var d = new Date();
    initDatePicker("hrDateFrom");
    initDatePicker("hrDateTo");
    $('#Employeetimetbl').DataTable({
        ajax: {
            url: '../WorkTimeSummary/GETEmployeeTimeinout',
            data: {
                Month: $("#Month").val(),
                Year: $("#Year").val(),
                Section: selectedSection,
                Agency: $("#BIPH_Agency").val(),
            },
            type: "GET",
            datatype: "json",
        },

        lengthChange: true,
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        pagelength: 10,
        loadonce: false,
        scrollX: true,
        dom: 'lBfrtip',
        buttons: [
            {
                extend: 'excel',
                action: function () {
                    window.open('../WorkTimeSummary/ExportEmployeeTimeinout?Month=' + $("#Month").val() + '&Year=' + $("#Year").val() + '&Section=' + selectedSection + '&Agency=' + $("#BIPH_Agency").val());

                }
                //title: "WorkTimeSummary_TimeInandOut" + formatDate(d) + "_" + selectedSection
            },
            {
                text: 'HR Format',
                action: function (e, dt, node, config) {
                    $("#HRExportmodal").modal("show");
                }
            }

        ],
        ordering: false,
        serverSide: "true",
        scrollCollapse: true,
        order: [0, "asc"],
        processing: "true",
        scrollY: "600px",
        scrollCollapse: true,
        columns: [
            { title: "No", data: "Rownum", className: "reloadclass", name: "Rownum" },
            { title: "Employee No", data: "EmpNo", name: "EmpNo" },
            { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
            { title: "Position", data: "Position", name: "Position" },
            { title: "Cost Center", data: "CostCode", name: "CostCode" },
            { title: "Current Schedule", data: "Schedule"},
            {
                title: "Process", data: function (x) {

                    return"<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                },
            },
            { title: "1", data: "C1" },
            { title: "2", data: "C2" },
            { title: "1", data: "C3" },
            { title: "1", data: "C4" },
            { title: "1", data: "C5" },
            { title: "1", data: "C6" },
            { title: "1", data: "C7" },
            { title: "1", data: "C8" },
            { title: "1", data: "C9" },
            { title: "1", data: "C10" },
            { title: "1", data: "C11" },
            { title: "1", data: "C12" },
            { title: "1", data: "C13" },
            { title: "1", data: "C14" },
            { title: "1", data: "C15" },
            { title: "1", data: "C16" },
            { title: "1", data: "C17" },
            { title: "1", data: "C18" },
            { title: "1", data: "C19" },
            { title: "1", data: "C20" },
            { title: "1", data: "C21" },
            { title: "1", data: "C22" },
            { title: "1", data: "C23" },
            { title: "1", data: "C24" },
            { title: "1", data: "C25" },
            { title: "1", data: "C26" },
            { title: "1", data: "C27" },
            { title: "1", data: "C28" },
            { title: "1", data: "C29" },
           
            {
                title: "30", data: function (x) {
                    if (x.C30 != null) {
                        return x.C30
                    }
                    else {
                        return "";
                    }
                }
            },
            {
                title: "31", data: function (x) {
                    if (x.C31 != null) {
                        return x.C31
                    }
                    else {
                        return "";
                    }
                }
            },
        ],
        drawCallback: function (settings) {

            var table = $('#Employeetimetbl').DataTable();
            table.columns.adjust();
        },
        initComplete: function () {

            var table = $('#Employeetimetbl').DataTable();
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
            table = $('#Employeetimetbl').DataTable();
            table.columns.adjust();
            $("#EmployeeTime").show();
        },
        fixedColumns: true,
        fixedColumns: {
            leftColumns: 7
            //rightColumns: 1
        },
        destroy: true
    });
}