$(function () {
    Initializepage();
    $('#ComputerForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#ComputerName').val() != ""
            && $('#ComputerIP').val() != ""
            && $('#Status').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddComputer($(this));
            }
            else {
                EditComputer($(this));
            }
        }
    });
});


function Initializepage() {
    //$("#AgencyForm").hide();
   
    $("#ComputerForm")[0].reset();
    $("#ID").val("");
    $('#ComputerTable').DataTable({
        ajax: {
            url: '../ComputerRegistration/GetComputerRegistrationList',
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
            { title: "Computer Name", data: "ComputerName" },
            { title: "Computer IP", data: "ComputerIP" },
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true) ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                    return label
                }
            },
            {
                title: "Action", data: function (x) {
                    var logO = (x.Logo == "") ? "no-logop.png" : x.Logo;
                    return "<button type='button' class='btn btn-sm bg-blue btnedit' id=data" + x.ID + ">" +
                      "<i class='fa fa-edit' ></i> Edit" +
                      "</button> " +
                      "<button type='button' class='btn btn-sm bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                      "<i class='fa fa-trash'></i> Delete" +
                      "</button>"
                }
            },
        ],

    });
    $('#ComputerTable tbody').off('click');
    $('#ComputerTable tbody').on('click', '.btnedit', function () {
        $('#ComputerForm *').prop('disabled', false);
        var tabledata = $('#ComputerTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#ComputerName").val(data.ComputerName);
        $('#ComputerIP').val(data.ComputerIP);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");
    });
    $('#ComputerTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#ComputerTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../ComputerRegistration/DeleteComputer', data.ID, data.ComputerName);

    });

}

function AddComputer(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../ComputerRegistration/CreateComputer',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Agency Saved");
                msg("Computer Saved", "success");
            }
            else {
                swal("Computer Already Exist");
            }

        }
    });
}

function EditComputer(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../ComputerRegistration/EditComputer',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Agency Saved");
                notify("Saved!", "Successfully Saved", "success");
            }
            else {
                swal("Computer Already Exist");
            }

        }
    });
}