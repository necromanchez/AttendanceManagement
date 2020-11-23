$(function () {
    //Initializepage();
    $("#DateFilter").datepicker().datepicker("setDate", new Date());
    $("#DateFilter2").datepicker().datepicker("setDate", new Date());
    $("#DateFilter").on("change", InitializepageTT);
    $("#DateFilter2").on("change", InitializepageTT);
    Dropdown_selectMPMain22('Section', "/Helper/GetDropdown_SectionAMS?Dgroup=");

    //$("#Section").on("change", InitializepageTT);

});

function InitializepageTT() {
    //$("#loading_modal").modal("show");
    var d = new Date();
    $('#TapTable').DataTable({
        ajax: {
            url: '/Summary/Employeetap/GetTapList',
            type: "POST",
            data: {
                searchdate: $("#DateFilter").val(),
                searchdate2: $("#DateFilter2").val(),
                Sectiontap: $("#Section").val(),
                Agency: $("#BIPH_Agency").val(),
            },
            datatype: "json"
        },
        dom: 'lBfrtip',
        buttons: [
            {
                extend: 'excel',
                title: "EmployeeTap" + formatDate(d) + "_" + selectedSection
            }
        ],
        ordering:false,
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        lengthChange: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "Employee No", data: "EmployeeNo", name: "EmployeeNo" },
            { title: "RFID", data: "Employee_RFID", name: "EmployeeNo" },
            { title: "Employee Name", data: "EmployeeName", name: "EmployeeNo" },
            { title: "Section", data: "SectionGroup", name: "SectionGroup" },
            { title: "Process", data: "Type", name: "Type"},
            { title: "Date", data: "TapDate", name: "TapDate" },
            { title: "Time", data: "TapTime", name: "TapTime"},
            { title: "Type", data: "Taptype", name: "Taptype" },
            
            //{
            //    title: "Tap", data: function (x) {
            //        return (x.Tap != null) ? moment(x.Tap).format("MM/DD/YYYY HH:mm:ss") : ""
            //    }, name: "Tap"
            //},
        ],
        initComplete: function () {
            //$("#loading_modal").modal("hide");
        },
        drawCallback: function (settings) {
            $("#loading_modal2").modal("hide");
          
        },
    });

    var table = $('#TapTable').DataTable();
    $('#TapTable').on('length.dt', function (e, settings, len) {
        console.log('New page length: ' + len);
        $("#loading_modal2").modal("show");
    });
   
}