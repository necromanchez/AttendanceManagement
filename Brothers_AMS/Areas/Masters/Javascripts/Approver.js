$(function () {
    Dropdown_select('Section', "/Helper/GetDropdown_Section");
    Dropdown_select('BIPH_Agency', "/Helper/GetDropdown_Agency");

    Initializepage();
    $('#ApproverForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#Approver').val() != ""
            && $('#Status').val() != ""
            && $('#EmailAdd').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddApprover($(this));
            }
            else {
                EditApprover($(this));
            }
        }
    });

    
})

function Initializepage() {
    $("#ApproverForm")[0].reset();
    $("#ID").val("");
    $('#ApproverTable').DataTable({
        ajax: {
            url: '../Approver/GetApproverList',
            type: "POST",
            datatype: "json"
        },
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
            { title: "Company", data: "BIPH_Agency" },
            { title: "EmployeeNo", data: "EmployeeNo" },
            { title: "Employee Name", data: "EmployeeName" },
            { title: "EmailAdd", data: "EmailAdd" },
            { title: "Section", data: "Section" },
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true) ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                    return label

                }
            },
            {
                title: "Action", data: function (x) {
                    return "<button type='button' class='btn bg-blue btnedit' id=data" + x.ID + ">" +
                                "<i class='fa fa-edit ' ></i> Edit" +
                            "</button>" +
                            "<button type='button' class='btn bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                                "<i class='fa fa-trash '></i> Delete" +
                            "</button>"
                }
            },
        ],

    });
    $('#ApproverTable tbody').off('click');
    $('#ApproverTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#ApproverTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#BIPH_Agency').val(data.BIPH_Agency);
        $('#EmployeeNo').val(data.EmployeeNo);
        //$('#Section').val(data.SectionID);
        $('#Section option[value=' + data.SectionID + ']').prop('selected', true);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

        $("#Section option").filter(function () {
            return $(this).text() == data.Section;
        }).prop('selected', true);

      

    });
    $('#ApproverTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#ApproverTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../Approver/DeleteApprover', data.ID, data.Approver);

    });

}

function AddApprover(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Approver/CreateApprover',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Approver Saved");
                msg("Approver Saved", "success");
            }
            else {
                swal("Approver Already Exist");
            }

        }
    });
}

function EditApprover(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Approver/EditApprover',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Approver Saved");
                msg("Approver Saved", "success");
            }
            else {
                swal("Approver Already Exist");
            }

        }
    });
}