$(function () {
    Initializepage();
    $('#PositionForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#Position').val() != ""
            && $('#Status').val() != ""
            ){
            if ($('#ID').val() == "") {
                AddPosition($(this));
            }
            else {
                EditPosition($(this));
            }
        }
    });
})

function Initializepage() {
    $("#PositionForm")[0].reset();
    $("#ID").val("");
    $('#PositionTable').DataTable({
        ajax: {
            url: '../Position/GetPositionList',
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
            { title: "Position", data: "Position"},
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true)?"Active":"InActive"
                    return label

                }},
            {
                title: "Action", data: function (x) {
                    return "<button type='button' class='btn bg-blue btnedit' id=data" + x.ID + ">" +
                                "<i class='fa fa-edit ' ></i> Edit"+
                            "</button>"+
                            "<button type='button' class='btn bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                                "<i class='fa fa-trash '></i> Delete"+
                            "</button>"
                }
            },
        ],

    });
    $('#PositionTable tbody').off('click');
    $('#PositionTable tbody').on('click', '.btnedit', function () {
        
        var tabledata = $('#PositionTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#Position').val(data.Position);
        $('#Status').val(data.Status);
        $('#Status option[value='+data.Status+']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");
       
    });
    $('#PositionTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#PositionTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../Position/DeletePosition', data.ID, data.Position);
        
    });

}

function AddPosition(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Position/CreatePosition',
        data:  datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                swal("Position Saved");
            }
            else {
                swal("Position Already Exist");
            }

        }
    });
}

function EditPosition(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Position/EditPosition',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                swal("Position Saved");
            }
            else {
                swal("Position Already Exist");
            }

        }
    });
}

