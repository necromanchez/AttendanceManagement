$(function () {
    Initializepage();
    $('#AgencyForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#AgencyName').val() != ""
            && $('#Address').val() != ""
            && $('#ISO').val() != ""
            && $('#Status').val() != ""
            && $("#EmailAddress").val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddAgency($(this));
            }
            else {
                EditAgency($(this));
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
        files.append('AgencyID', PackID);
        var sa = this;
        $.ajax({
            type: 'POST',
            url: '../FormatorTemplate/UploadImagePackage',
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
    $("#AddAgencyEmail").on("click", AddEmail);
    $("#SaveAgencyEmail").on("click", SaveEmails);
})

function idlogof(data,link) {
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
var ID = 0;
function Initializepage() {
    //$("#AgencyForm").hide();
    $('#AgencyForm *').prop('disabled', true);
    $("#AgencyForm")[0].reset();
    $("#ID").val("");
    $('#AgencyTable').DataTable({
        ajax: {
            url: '../FormatorTemplate/GetAgencyList',
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
            { title: "AgencyCode", data: "AgencyCode" },
            { title: "Agency", data: "AgencyName" },
            { title: "Address", data: "Address" },
            { title: "Telephone No", data: "TelNo" },
            { title: "ISO Details (OT)", data: "ISO_OT" },
            { title: "ISO Details (CS)", data: "ISO_CS" },
            { title: "ISO Details (DTR)", data: "ISO_DTR" },
            {
                    title: "Email", data: function (x) {
                        return "<button type='button' class='btn btn-sm' onclick=getAgencyEmail('" + x.AgencyCode + "') style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid'>" +
                                "<i class='fa fa-envelope'></i> Email" +
                            "</button> "
                    }
            },
            {
                title: "Logo", data: function (x) {
                    var logO = (x.Logo == "") ? "no-logop.png" : x.Logo;
                    return "<img class='card-img-top img-responsive' style='width:50px;height:30px;' src='/PictureResources/AgencyLogo/" + logO + "' alt='Card image cap'>";
            }},
            {
                title: "Status", data: function (x) {
                    var label = (x.Status == true) ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                    return label

                }
            },
            
            {
                title: "Action", data: function (x) {
                    var logO = (x.Logo == "") ? "no-logop.png" : x.Logo;
                    return "<button type='button' class='btn btn-sm' style='background-color:#039a8c; color:white; width:40px' alt='alert' class='model_img img-fluid' id=logo" + x.ID + " onclick=idlogof('logo" + x.ID + "','" + logO + "')>" +
                                "<i class='fa fa-upload'></i> Logo" +
                            "</button> " +
                            //"<button type='button' data-toggle='modal' data-target='#Logoup' class='btn btn-sm' style='background-color:#039a8c; color:white' alt='alert' class='model_img img-fluid' id=logo" + x.ID + " onclick=idlogof('logo" + x.ID + "','" + logO + "')>" +
                            //    "<i class='fa fa-upload'></i> Logo" +
                            //"</button> "+
                            "<button type='button' style='width:40px' class='btn btn-sm bg-blue btnedit' id=data" + x.ID + ">" +
                                "<i class='fa fa-edit' ></i> Edit" +
                            "</button> "
                            //"<button type='button' class='btn btn-sm bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                            //    "<i class='fa fa-trash'></i> Delete" +
                            //"</button>"
                           
                }
            },
        ],

    });
    $('#AgencyTable tbody').off('click');
    $('#AgencyTable tbody').on('click', '.btnedit', function () {
        $('#AgencyForm *').prop('disabled', false);
        var tabledata = $('#AgencyTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#AgencyCode").val(data.AgencyCode);
        $('#AgencyName').val(data.AgencyName);
        $('#Address').val(data.Address);
        $('#ISO_OT').val(data.ISO_OT);
        $('#ISO_CS').val(data.ISO_CS);
        $('#ISO_DTR').val(data.ISO_DTR);
        $('#Status').val(data.Status);
        $('#TelNo').val(data.TelNo);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");
    });
    $('#AgencyTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#AgencyTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../FormatorTemplate/DeleteAgency', data.ID, data.Agency);
      
    });

}

function AddAgency(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../FormatorTemplate/CreateAgency',
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
                swal("Agency Already Exist");
            }

        }
    });
}

function EditAgency(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../FormatorTemplate/EditAgency',
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
                swal("Agency Already Exist");
            }

        }
    });
}

function getAgencyEmail(data) {
    $('#AgencyEmailmodal').modal({
        backdrop: 'static',
        keyboard: false
    })
    $("#AgencyCodehere").val(data);
    $("#agencyemail").html('');
     $.ajax({
        url: '/FormatorTemplate/GetEmail',
        type: 'GET',
        datatype : "json",
        data: { AgencyCode: data },
        success : function (returnData) {
            if (returnData.EmailAgency.length > 0) {
                for (var x = 0; x < returnData.EmailAgency.length; x++) {
                    AddEmail();
                    $("#EmailA" + ID).val(returnData.EmailAgency[x].EmailAddress);
                    ID = ID +1;
                }
            }
            var defaultemail = 5;
            for (var y = 0; y < defaultemail - returnData.EmailAgency.length; y++) {
                AddEmail();
                $("#EmailA" + ID).val("");
                ID = ID + 1;
            }
  
        $("#AgencyEmailmodal").modal("show");

    },
        error : function (xhr, ajaxOptions, thrownError) {
        alert(xhr.status);
        alert(thrownError);
    }
    });
}

function AddEmail() {
    ID = ID + 1;
    var row = "<div class='row' id='row" + ID + "'>" +
                "<div class='col-md-2'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group outut'>" +
                            "<span class='input-group-addon' style='border-color:white;'>Email </span>" +
                        "</div>"+
                    "</div>"+
                "</div>"+
             
                "<div class='col-md-5'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group'>"+
                            "<input type='email' placeholder='Input E-Mail Address' class='form-control Emailinput' id='EmailA" + ID + "' name='SupervisorName' />" +
                        "</div>"+
                    "</div>"+
                "</div>" +
                 "<div class='col-md-1'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group'>"+
                            "<button class='btn btn-google' onclick='removerow(" + ID + ")'><i class='fa fa-close'></i></button>" +
                        "</div>" +
                    "</div>"+
                "</div>" +
            "</div>";
    $("#agencyemail").append(row);
   
}

function removerow(data) {
    $("#row"+data).html('');
    //alert(data);
}

function SaveEmails() {
    var emaillist = [];
    $(".Emailinput").each(function () {
        var item = {
            AgencyCode: $("#AgencyCodehere").val(),
            EmailAddress: $(this).val()
        }
        emaillist.push(item)
    });
    console.log(emaillist);
    $.ajax({
        url: '../FormatorTemplate/SaveAgencyMail',
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            EmailList: emaillist,
        }),
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "") {
                swal("Email Saved");
                $("#AgencyEmailmodal").modal("hide");
            }
            else {
                swal(returnData.msg);
                $("#AgencyEmailmodal").modal("hide");
            }
               
        }
    });
}
