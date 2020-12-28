$(function(){

    Initializepage();
    $("#DateFilter").datepicker().datepicker("setDate", new Date());
    $("#DateFilter").on("change", Initializepage)
})

function Initializepage() {
    $('#ErrorLogTable').DataTable({
        ajax: {
            url: '../ErrorLogs/GetErrorList',
            type: "GET",
            data: { searchdate: $("#DateFilter").val()},
            datatype: "json"
        },
       
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
            { title: "ID", data: "ID", visible: false },
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "Module", data: "PageModule",  name: "PageModule" },
            { title: "ErrorLog", data: "ErrorLog", name: "ErrorLog" },
            {
                title: "Date Occured", data: function (x) {
                    return (x.DateLog != null) ? moment(x.DateLog).format("MM/DD/YYYY") : ""
                }, name: "DateLog"},
            //{
            //    title: "Date Occured", data: function (x) {
            //        var ss = (x.DateLog != null) ? moment(x.DateLog).format("MM/DD/YYYY") : "";
            //        return (x.DateLog != null) ? moment(x.DateLog).format("MM/DD/YYYY") : ""
            //    }, data: "DateLog", name: "DateLog"
            //},
            { title: "User", data: "Username", data: "Username", name: "Username"},
            { title: "Employee Name", data: "EmployeeName", data: "EmployeeName", name: "EmployeeName" },
        ],

    });
   
}