$(function () {
    Dropdown_selectEmpSection('SectionGroup', "/Helper/GetDropdown_SectionAMS");
    $("#SectionGroup").on("change", Initializepage);
    //$('#Skillmodal').on('hidden.bs.modal', function (e) {
    //    setTimeout(function () { location.reload(); }, 1000);
    //})

    //Dropdown_select('Section', "/Helper/GetDropdown_Section");
    $("#btnskillsave").on("click", saveskill);
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
                GetSkilltable($("#LineID").val());
            },
            error: function (error) {
                $('#uploadMsg').text('Error has occured. Upload is failed');
            }
        });

    });

    Initializepage();
    $('#LineProcessTeamForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#LineProcessTeam').val() != ""
            && $('#Status').val() != ""
            && ($('#Section').val() != "" || $('#SectionGroup').val() != "")
            ) {
            if ($('#ID').val() == "") {
                AddLineProcessTeam($(this));
            }
            else {
                EditLineProcessTeam($(this));
            }
        }
    });
    GetUserSection();

    $('#Skillmodal').on('hidden.bs.modal', function (e) {
        //location.reload();
        $("#picturepackage").val("")
    })
    //$("#Count").prop("disabled", true);
    //$("#Type").on("change", function () {
    //    if ($("#Type").val() == "2") {
    //        $("#Count").prop("disabled", false);
    //    }
    //    else {
    //        $("#Count").prop("disabled", true);
    //        $("#Count").val("");
    //    }

    //})
})

function Initializepage() {
    $("#Line").val('');
    $("#Manpower").val("");
    $("#ID").val("");
    $('#LineProcessTeamTable').DataTable({
        ajax: {
            url: '../Process/GetLineProcessTeamList',
            type: "POST",
            data:{GroupSection:$("#SectionGroup").val()},
            datatype: "json"
        },
        lengthMenu: [[10, 50, 100], [10, 50, 100]],

        lengthChange: true,

        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        scrollY: "600px",
        language: {
            "processing": "processing... please wait"
        },
        destroy: true,
        language: {
            "processing": "processing... please wait"
        },
        destroy: true,
        columns: [
            { title: "ID", data: "ID", visible: false },
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "Section", data: "SectionName", name: "SectionName" },
            { title: "Line/Team", data: "Line", name: "Line" },
            //{ title: "Ideal Man Power Count", data: "Manpower" },
            {
                title: "Process", data: function (x) {
                    var label = "<button type='button' class='btn btn-xs bg-blue' onclick=ShowSkills('" + x.SectionID + "','" + x.ID + "')>Process</button>"
                    return label

                }, name:"Process"
            },
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true) ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                    return label

                }, name:"Status"
            },
            {
                title: "Action", data: function (x) {
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
    $('#LineProcessTeamTable tbody').off('click');
    $('#LineProcessTeamTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#LineProcessTeamTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        //$('#Section').val(data.SectionID);
        //$('#Section option[value=' + data.SectionID + ']').prop('selected', true);
        $('#Line').val(data.Line);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#Manpower').val(data.Manpower);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#LineProcessTeamTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#LineProcessTeamTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../Process/DeleteLineProcessTeam', data.ID, data.Line);

    });

}

function UploadSkill() {
    $("#loading_modal").modal("show")

    var files = new FormData();
    var file1 = document.getElementById("UploadedFile").files[0];
    files.append('LineID', $("#LineID").val());
    files.append('files[0]', file1);
    $.ajax({
        type: 'POST',
        url: '../Process/UploadSkills',
        data:files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            GetSkilltable($("#LineID").val());
            //swal("Skills Saved");
            msg("Skill Saved", "success");
            $("#loading_modal").modal("hide")

        },
        error: function (error) {
            $('#uploadMsg').text('Error has occured. Upload is failed');
        }
    });
}

function ShowSkills(Section, Line) {
    $("#LineID").val(Line);
    GetSkilltable(Line);
    $.ajax({
        type: 'POST',
        url: '../Process/GetLineName',
        data: {ID:Line},
        success: function (response) {
            var data= "Line Name: " + response.linename;
            $("#myModalLabelProcess").text(data);
            $("#Skillmodal").modal("show");
        }
    });
   
}

function GetSkilltable(Line) {
    $('#SkillsTable').DataTable({
        ajax: {
            url: '../Skills/GetSkillsList?LineID=' + Line,
            type: "POST",
            datatype: "json"
        },
        
        lengthChange: false,
       
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columnDefs: [
          {
              "targets": 3, // your case first column
              "className": "text-center"
              
          },
          ],
        columns: [
            { title: "ID", data: "ID", visible: false },
            { title: "Process", data: "Skill" },
            {
                title: "Logo", data: function (x) {
                    var logO = (x.Logo == null) ? "no-logop.png" : x.Logo;
                    return "<img class='card-img-top img-responsive' style='width:50px;height:30px;' src='/PictureResources/ProcessLogo/" + logO + "' alt='Card image cap'>";
                }
            },
            //{
            //    title: "Type", data: function (x) {
            //        return (x.Type == "1")?"Per Employee":"Common"
            //    }
            //},
            {
                title: "Ideal Man Power", data: "Count"
                
            },
           
            {
                title: "Action", data: function (x) {
                    var logO = (x.Logo == null) ? "no-logop.png" : x.Logo;
                    return "<button type='button' class='btn btn-sm bg-blue btnreditskill' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-edit'></i> Edit" +
                            "</button> "+

                            "<button type='button' class='btn btn-sm' style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid' id=logo" + x.ID + " onclick=idlogof('logo" + x.ID + "','" + logO + "')>" +
                                "<i class='fa fa-upload'></i> Logo" +
                            "</button> " +

                            //"<button type='button' data-toggle='modal' data-target='#Logoup' class='btn btn-sm' style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid' id=logo" + x.ID + " onclick=idlogof('logo" + x.ID + "','" + logO + "')>" +
                            //    "<i class='fa fa-upload'></i> Logo" +
                            //"</button> " +
                         
                            "<button type='button' class='btn btn-sm bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-trash'></i> Delete" +
                            "</button>"
                }
            },
        ],
    });

    $('#SkillsTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#SkillsTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        DeletionheresSkill('../Skills/DeleteSkills', data.ID, data.Skills,Section,Line);
    });
    $('#SkillsTable tbody').on('click', '.btnreditskill', function () {
        var tabledata = $('#SkillsTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#SkillID').val(data.ID);
        $('#Skill').val(data.Skill);
        //$('#Type').val(data.Type);
        $('#Count').val(data.Count);
        //if (data.Type == "2") {
        //    $("#Count").prop("disabled", false);
        //}
        //else {
        //    $("#Count").prop("disabled", true);
        //}
    });
}

function DeletionheresSkill(link, ID, Name,Section,Line) {
    swal({
        title: "Are you sure?",
        //text: "You will not be able to recover this imaginary file!",   
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        closeOnConfirm: true,
        closeOnCancel: true
    }, function (isConfirm) {
        if (isConfirm) {

            $.ajax({
                url: link,
                data: { ID: ID },
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        //swal("Deleted!", "Data has been deleted.", "success");
                        notify("Saved!", "Deleted", "success");
                        GetSkilltable($("#LineID").val());
                        Initializepage();
                    }
                    else {
                        swal("Cannot be Delete " + Name);
                    }

                }
            });


        } else {
            swal("Cancelled", "Deletion Cancelled", "error");
        }
    });
}

function saveskill() {
    if ($("#SkillID").val() == "") {
        if ($("#Skill").val() != "") {
            var datanow = {
                Line: $("#LineID").val(),
                Skill: $("#Skill").val(),
                Type: $("#Type").val(),
                Count: ($("#Count").val() == "") ? 1 : $("#Count").val()
            }
            $.ajax({
                url: '../Skills/CreateSkills',
                data: datanow,
                type: 'POST',
                datatype: "json",
                success: function (returnData) {
                    if (returnData.msg == "Success") {
                        //Initializepage();
                        GetSkilltable($("#LineID").val());
                        //swal("Skill Saved");
                        notify("Saved!", "Successfully Saved", "success");
                    }
                    else {
                        swal("Skill Already Exist in this Line");
                    }

                }
            });
        }
        else {
            swal("Input Skill");
        }
    }
    else {
        var datanow = {
            Line: $("#LineID").val(),
            ID : $("#SkillID").val(),
            Skill: $("#Skill").val(),
            Type: $("#Type").val(),
            Count: ($("#Count").val() == "") ? 1 : $("#Count").val()

        }
        $.ajax({
            url: '../Skills/EditSkills',
            data: datanow,
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                if (returnData.msg == "Success") {
                    //Initializepage();
                    $("#SkillID").val("");
                    GetSkilltable($("#LineID").val());
                    //swal("Skill Saved");
                    msg("Skill Saved", "success");
                }
                else {
                    swal("Skill Already Exist in this Line");
                }

            }
        });
    }
}

function confirmnow(re) {
    var files = new FormData();
    var file1 = document.getElementById(re.id).files[0];
    files.append('files[0]', file1);
    files.append('filecode', re.id);
    loadModalConfirmUp('Confirmupload', '', "Upload selected file?", '../MRPCalculation/UploadFiles', files);
}

function AddLineProcessTeam(data) {
    var Sectionchosen = ($("#Section").val() == "") ? "'"+$("#SectionGroup").val()+"'" : $("#Section").val()
    var datanow = $("#LineProcessTeamForm").serialize() + '&Section=' + Sectionchosen;
    
    $.ajax({
        url: '../Process/CreateLineProcessTeam',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Line Saved");
                notify("Saved!", "Successfully Saved", "success");
            }
            else {
                swal("Line Already Exist");
            }

        }
    });
}

function EditLineProcessTeam(data) {
    var Sectionchosen = ($("#Section").val() == "") ? $("#SectionGroup").val() : $("#Section").val()
    var datanow = data.serialize() + '&Section=' + Sectionchosen;
    $.ajax({
        url: '../Process/EditLineProcessTeam',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Line Saved");
                notify("Saved!", "Successfully Saved", "success");
            }
            else {
                swal("Line Already Exist");
            }

        }
    });
}

function idlogof(data, link) {
    //$("#idlogo").val(data);
    //$('#packImage').attr('src', "/PictureResources/ProcessLogo/" + link);
    $("#idlogo").val(data);
    //$('#packImage').attr('src', "/PictureResources/AgencyLogo/"+link);
    $("#picturepackage").trigger("click");

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

function GetUserSection() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section2').val(returnData.usersection);
            $('#Section').val(returnData.usercost);
            $('#Section2').prop("disabled",true);
        }
    });
}