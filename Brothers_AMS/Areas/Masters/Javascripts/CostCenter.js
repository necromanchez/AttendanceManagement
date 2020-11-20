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
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        
        lengthChange: true,
        ordering:false,
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
         scrollY: "600px",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "ID", data: "ID", visible: false },
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "Cost Center", data: "Cost_Center", name: "Cost_Center" },
            { title: "Cost Center Name", data: "Section", name: "Cost_Center" },
            {
                title: "Section", className: "AddSection", data: function (x) {
                    var SectionGroup = (x.GroupSection == null) ? "" : x.GroupSection;
                  
                    return data =   "<div class='form-group'>" +
                                    "    <div class='input-group'>" +
                                    "        <input onfocusout='disablethis(this)' type='text' class='form-control' id='" + x.Cost_Center + "' name='" + x.Cost_Center + "'  value='" + SectionGroup + "'>" +
                                    "    </div>" +
                                    "</div>";
                }, name: "GroupSection"
            },
            {
                title: "Department", className: "AddDepartment", data: function (x) {
                    var DepartmentGroup = (x.DepartmentGroup == null) ? "" : x.DepartmentGroup;

                    return data = "<div class='form-group'>" +
                        "    <div class='input-group'>" +
                        "        <input onfocusout='disablethisDept(this)' type='text' class='form-control' id='" + x.Cost_Center + "' name='" + x.Cost_Center + "'  value='" + DepartmentGroup + "'>" +
                        "    </div>" +
                        "</div>";
                }, name: "DepartmentGroup"
            },
        ],

    });
    $('#CostCentertable tbody').on('click', '.AddSection', function () {
        var tabledata = $('#CostCentertable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#"+data.Cost_Center).prop("disabled",false);
    });
    $('#CostCentertable tbody').on('click', '.AddDepartment', function () {
        var tabledata = $('#CostCentertable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#" + data.Cost_Center).prop("disabled", false);
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
                console.log(response);
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

function disablethisDept(d) {
    $.ajax({
        url: '../CostCenter/UpdateGroupDept',
        data: {
            CostCode: $(d).attr('id'),
            DepartmentGroup: $(d).val()
        },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            notify("Saved!", "Successfully Saved", "success");
        }
    });
}