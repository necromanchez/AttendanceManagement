$(function(){

    Initializepage();
})

function Initializepage() {
    $('#ErrorLogTable').DataTable({
        ajax: {
            url: '../ErrorLogs/GetErrorList',
            type: "POST",
            datatype: "json"
        },
        lengthMenu: [5000, 200, 300, 500],
        pagelength: 5000,
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
            { title: "ID", data: "ID", visible: false },
            { title: "Module", data: "PageModule" },
            { title: "ErrorLog", data: "ErrorLog" },
            {
            title: "Date Occured", data: function (x) {
                return (x.DateLog != null) ? moment(x.DateLog).format("MM/DD/YYYY hh:mm:ss") : ""
            }
            },
            { title: "User", data: "Username" },
        ],

    });
   
}