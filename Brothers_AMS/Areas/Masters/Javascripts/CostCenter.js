$(function () {
    Initializepage();

    $("#Syncit").on("click", SyncCostCenter);
})

function Initializepage() {
    $('#CostCentertable').DataTable({
        ajax: {
            url: '../CostCenter/GetCostCenterList',
            type: "POST",
            datatype: "json"
        },
        lengthMenu: [100, 200, 300, 500],
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
            { title: "Cost Center", data: "Cost_Center" },
            { title: "Cost Center Name", data: "Section" },
            {
                title: "Section", className: "AddSection", data: function (x) {
                    var SectionGroup = (x.GroupSection == null) ? "" : x.GroupSection;
                  
                    return data =   "<div class='form-group'>" +
                                    "    <div class='input-group'>" +
                                    "        <input onfocusout='disablethis(this)' type='text' class='form-control' id='" + x.Cost_Center + "' name='" + x.Cost_Center + "'  value=" + SectionGroup + ">" +
                                    "    </div>" +
                                    "</div>";
                }},
        ],

    });
    $('#CostCentertable tbody').on('click', '.AddSection', function () {
        var tabledata = $('#CostCentertable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#"+data.Cost_Center).prop("disabled",false);
    });

}

function SyncCostCenter() {
    $("#loading_modal").modal("show")
    $.ajax({
        type: 'POST',
        url: '../CostCenter/SyncIT',
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.msg == "Success") {
                swal("Cost Center Successfully Sync");
                $("#loading_modal").modal("hide");
                Initializepage();
            }
            else {
                $("#loading_modal").modal("hide");
                swal("An Error Occured, Please Contact your Admin");
                
            }
        },
        error: function (error) {

        }
    });
}

function disablethis(d) {
    //$(d).prop("disabled", true);
    //alert($(d).val());
    //alert($(d).attr('id'));

    $.ajax({
        url: '../CostCenter/UpdateGroup',
        data: {
            CostCode: $(d).attr('id'),
            SectionGroup: $(d).val()
        },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            notify("Saved!", "Successfully Saved", "success");
        }
    });
}