function Initializepage_AbsentDetails() {
    var d = new Date();
    $('#AbsentDetailsTable').DataTable({
        ajax: {
            url: '../WorkTimeSummary/GetAbsentDetails',
            type: "POST",
            data: {
                Month: $("#Month").val(),
                Year: $("#Year").val(),
                Section: selectedSection,
                Agency: $("#BIPH_Agency").val(),
            },
            datatype: "json"
        },
        scrollCollapse: true,
        order: [0, "asc"],
        processing: "true",
        scrollY: "600px",
        serverSide: "true",
        pageLength: 10,
        //lengthMenu: [10, 100, 500, 1000, 5000],
        lengthMenu: [[10, 50, 100], [10, 50, 100]],

        lengthChange: true,
        loadonce: false,
        dom: 'lBfrtip',
        //buttons: [
        //     'excel', 'print'
        //],
        buttons: [
            {
                text: "Excel",
                action: function () {
                    window.open('../WorkTimeSummary/ExportWorktimeSummary_AbsentDetails?Month=' + $("#Month").val() + '&Year=' + $("#Year").val() + '&Section=' + selectedSection + '&Agency=' + $("#BIPH_Agency").val());

                }
            },
        ],
       
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            {
                title: "Date", data: function (x) {
                    return (x.Date != null) ? moment(x.Date).format("MM/DD/YYYY") : ""
                }, name: "Date"
            },
            { title: "Agency", data: "Company", name: "Company" },
            { title: "EmployeeNo", data: "EmpNo", name: "EmpNo" },
            { title: "Employee Name", data: "EmployeeName", name: "EmployeeName" },
            { title: "Position", data: "ModifiedPosition", name: "ModifiedPosition" },
            { title: "Cost Center", data: "CostCenter_AMS", name: "CostCenter_AMS" },
            { title: "Type of Absence", data: "LeaveType", name: "LeaveType" },
            { title: "Reason of Absence", data: "Reason", name: "Reason" },
            {
                title:"Line/Team", data: function (x) {
                    return "<button type='button' class='btn btn-xs bg-green' onclick=GetProcess('" + x.EmpNo + "','" + x.CostCenter_AMS + "')>Show Process</button>";
                }
            },
        ],
        initComplete: function () {
            $("#loading_modal").modal("hide");
            $("#ABdetails").show();
            var table = $('#AbsentDetailsTable').DataTable();
            table.columns.adjust();
        }

    });
 

}