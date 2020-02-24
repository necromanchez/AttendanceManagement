$(function () {
    Initializepage();
    Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeam");

    $('#SkillsForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#Skills').val() != ""
            && $('#Status').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddSkills($(this));
            }
            else {
                EditSkills($(this));
            }
        }
    });

    $("#pusher").on("click", function () {
        $("#picturepackage").click();

    })

    $(".file-upload").on('change', function () {
        var files = new FormData();
        var file1 = document.getElementById("picturepackage").files[0];
        files.append('files[0]', file1);
        var PackID = $("#idlogo").val().replace("logo", "");
        files.append('SkillID', PackID);
        var sa = this;
        $.ajax({
            type: 'POST',
            url: '../Skills/UploadImageLogo',
            data: files,
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (response) {
                readURL(sa);
                Initializepage();
            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });

    });
})

function idlogof(data, link) {
    $("#idlogo").val(data);
    $('#packImage').attr('src', "/PictureResources/ProcessLogo/" + link);

}
function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            $('#packImage').attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function Initializepage() {
    $("#SkillsForm")[0].reset();
    $("#ID").val("");
    $('#SkillsTable').DataTable({
        ajax: {
            url: '../Skills/GetSkillsList',
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
            { title: "Line/Team", data: "Line" },
            { title: "Skill", data: "Skill" },
            {
                 title: "Logo", data: function (x) {
                     var logO = (x.Logo == null) ? "no-logop.png" : x.Logo;
                     return "<img class='card-img-top img-responsive' style='width:50px;height:30px;' src='/PictureResources/ProcessLogo/" + logO + "' alt='Card image cap'>";
                 }
            },
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true) ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                    return label

                }
            },
            {
                title: "Action", data: function (x) {
                    var logO = (x.Logo == null) ? "no-logop.png" : x.Logo;
                    return "<button type='button' data-toggle='modal' data-target='#Logoup' class='btn btn-sm' style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid' id=logo" + x.ID + " onclick=idlogof('logo" + x.ID + "','" + logO + "')>" +
                                "<i class='fa fa-upload'></i> Logo" +
                            "</button> " +
                            "<button type='button' class='btn btn-sm bg-blue btnedit' id=data" + x.ID + ">" +
                            "<i class='fa fa-edit' ></i> Edit" +
                            "</button> " +
                            "<button type='button' class='btn btn-sm bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-trash'></i> Delete" +
                            "</button>"
                }
            },
        ],

    });
    $('#SkillsTable tbody').off('click');
    $('#SkillsTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#SkillsTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#Line').val(data.LineID);
        $('#Skill').val(data.Skill);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#SkillsTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#SkillsTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        DeletionheresSkill('../Skills/DeleteSkills', data.ID, data.Skills);

    });

}




function AddSkills(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Skills/CreateSkills',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Skills Saved");
                msg("Skills Saved", "success");
            }
            else {
                swal("Skills Already Exist");
            }

        }
    });
}

function EditSkills(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Skills/EditSkills',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Skills Saved");
                msg("Skills Saved.", "success");
            }
            else {
                swal("Skills Already Exist");
            }

        }
    });
}
