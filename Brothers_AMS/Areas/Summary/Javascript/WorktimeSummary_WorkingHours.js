var totalHours = 0;
var total = 0;



function Initializedpage_WorkingHours() {
    var d = new Date();

    $('#AttenanceTbl_WorkingHours').DataTable({
        ajax: {
            url: '../WorkTimeSummary/GeAttendanceMonitoringList_WorkingHours',
            data: {
                Month: $("#Month").val(),
                Year: $("#Year").val(),
                Section: selectedSection,
                Agency: $("#BIPH_Agency").val(),
            },
            type: "GET",
            datatype: "json",
        },
        dom: 'lBfrtip',
        buttons: [
            {
                extend: 'excel',
                title: "WorkTimeSummary_OTBreakdown"
            }
        ],
        lengthChange: true,
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        pagelength: 10,
        loadonce: false,
        scrollX: true,
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
            { title: "Current Schedule", data: "Schedule" },
            {
                title: "Process", data: function (x) {

                    return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCode + "')>Show Process</button>";

                },
            },
            {
                title: "1", data: function (x) {
                    total += parseFloat(x.C1 );
                    return (x.C1 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C1 + "</p>" : x.C1;
                }
            },
            {
                title: "2", data: function (x) {
                    total += parseFloat(x.C2);
                    return (x.C2 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C2 + "</p>" : x.C2;
                }
            },
            {
                title: "3", data: function (x) {
                    total += parseFloat(x.C3);
                    return (x.C3 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C3 + "</p>" : x.C3;
                }
            },
            {
                title: "4", data: function (x) {
                    total += parseFloat(x.C4);
                    return (x.C4 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C4 + "</p>" : x.C4;
                }
            },
            {
                title: "5", data: function (x) {
                    total += parseFloat(x.C5);
                    return (x.C5 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C5 + "</p>" : x.C5;
                }
            },
            {
                title: "6", data: function (x) {
                    total += parseFloat(x.C6);
                    return (x.C6 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C6 + "</p>" : x.C6;
                }
            },
            {
                title: "7", data: function (x) {
                    total += parseFloat(x.C7);
                    return (x.C7 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C7 + "</p>" : x.C7;
                }
            },
            {
                title: "8", data: function (x) {
                    total += parseFloat(x.C8);
                    return (x.C8 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C8 + "</p>" : x.C8;
                }
            },
            {
                title: "9", data: function (x) {
                    total += parseFloat(x.C9);
                    return (x.C9 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C9 + "</p>" : x.C9;
                }
            },
            {
                title: "10", data: function (x) {
                    total += parseFloat(x.C10);
                    return (x.C10 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C10 + "</p>" : x.C10;
                }
            },
            {
                title: "11", data: function (x) {
                    total += parseFloat(x.C11);
                    return (x.C11 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C11 + "</p>" : x.C11;
                }
            },
            {
                title: "12", data: function (x) {
                    total += parseFloat(x.C12);
                    return (x.C12 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C12 + "</p>" : x.C12;
                }
            },
            {
                title: "13", data: function (x) {
                    total += parseFloat(x.C13);
                    return (x.C13 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C13 + "</p>" : x.C13;
                }
            },
            {
                title: "14", data: function (x) {
                    total += parseFloat(x.C14);
                    return (x.C14 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C14 + "</p>" : x.C14;
                }
            },
            {
                title: "15", data: function (x) {
                    total += parseFloat(x.C15);
                    return (x.C15 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C15 + "</p>" : x.C15;
                }
            },
            {
                title: "16", data: function (x) {
                    total += parseFloat(x.C16);
                    return (x.C16 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C16 + "</p>" : x.C16;
                }
            },
            {
                title: "17", data: function (x) {
                    total += parseFloat(x.C17);
                    return (x.C17 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C17 + "</p>" : x.C17;
                }
            },
            {
                title: "18", data: function (x) {
                    total += parseFloat(x.C18);
                    return (x.C18 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C18 + "</p>" : x.C18;
                }
            },
            {
                title: "19", data: function (x) {
                    total += parseFloat(x.C19);
                    return (x.C19 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C19 + "</p>" : x.C19;
                }
            },
            {
                title: "20", data: function (x) {
                    total += parseFloat(x.C20);
                    return (x.C20 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C20 + "</p>" : x.C20;
                }
            },
            {
                title: "21", data: function (x) {
                    total += parseFloat(x.C21);
                    return (x.C21 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C21 + "</p>" : x.C21;
                }
            },
            {
                title: "22", data: function (x) {
                    total += parseFloat(x.C22);
                    return (x.C22 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C22 + "</p>" : x.C22;
                }
            },
            {
                title: "23", data: function (x) {
                    total += parseFloat(x.C23);
                    return (x.C23 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C23 + "</p>" : x.C23;
                }
            },
            {
                title: "24", data: function (x) {
                    total += parseFloat(x.C24);
                    return (x.C24 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C24 + "</p>" : x.C24;
                }
            },
            {
                title: "25", data: function (x) {
                    total += parseFloat(x.C25);
                    return (x.C25 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C25 + "</p>" : x.C25;
                }
            },
            {
                title: "26", data: function (x) {
                    total += parseFloat(x.C26);
                    return (x.C26 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C26 + "</p>" : x.C26;
                }
            },
            {
                title: "27", data: function (x) {
                    total += parseFloat(x.C27);
                    return (x.C27 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C27 + "</p>" : x.C27;
                }
            },
            {
                title: "28", data: function (x) {
                    total += parseFloat(x.C28);
                    return (x.C28 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C28 + "</p>" : x.C28;
                }
            },
            {
                title: "29", data: function (x) {
                    total += parseFloat(x.C29);
                    return (x.C29 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C29 + "</p>" : x.C29;
                }
            },
            {
                title: "30", data: function (x) {
                    if (x.C30 >= null) {
                        total += parseFloat(x.C30);
                        return (x.C30 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C30 + "</p>" : x.C30;
                    }
                    else {
                        return "";
                    }
                }
            },
            {
                title: "31", data: function (x) {
                    if (x.C31 >= null) {
                        total += parseFloat(x.C31);
                        return (x.C31 >= 0) ? "<p class='text-green Adjustbrand'> " + x.C31 + "</p>" : x.C31;
                    }
                    else {
                        return "";
                    }
                }
            },
        ],
        drawCallback: function (settings) {

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
            for (var x = 1; x <= numDays; x++) {
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
    
}