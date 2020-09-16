$(function () {
    Initializepage();
    $('#SectionForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#Section').val() != ""
            && $('#Status').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddSection($(this));
            }
            else {
                EditSection($(this));
            }
        }
    });
    //Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    Dropdown_selectMPMain22('Section', "/Helper/GetDropdown_SectionAMS?Dgroup=");
  
    $("#Manager").focusout(function () {
        $.ajax({
            url: '../Section/GetEmployeeName',
            data: { EmployeeNo: $(this).val() },
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                $("#ManagerName").val(returnData.completename);
            }
        });
    });
    $("#General_Manager").focusout(function () {
        $.ajax({
            url: '../Section/GetEmployeeName',
            data: { EmployeeNo: $(this).val() },
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                $("#GenManagerName").val(returnData.completename);
            }
        });
    });
    $("#SaveApproverbtn").on("click", SaveApprover);

    $("#AddSupervisorapp").on("click", Addsupervisor);
    $("#AddManagerapp").on("click", AddManager);
    $("#AddGenManagerapp").on("click", AddGenManager);
    $("#AddFGManagerapp").on("click", AddFGenManager);

    $("#Section").on("change", Initializepage);

})
var ID = 0;

function Initializepage() {

   

    $("#SectionForm")[0].reset();
    $("#ID").val("");
    $('#SectionTable').DataTable({
        ajax: {
            url: '../Section/GetSectionList',
            type: "POST",
            datatype: "json",
            data: { supersection: $("#Section").val() }
        },
        dom: 'Blfrtip',
        buttons: [
            {
                text: 'Approvers',
                action: function ( e, dt, node, config ) {
                    getApprover();
                },
                className:"Approvebtn"
            }
        ],
        initComplete: function () {
            if ($("#Section").val() == "") {
                $(".Approvebtn").hide();
            }
            else {
                $(".Approvebtn").show();
            }
        },
        lengthMenu: [[10, 50, 100], [10, 50, 100]],
        
        lengthChange: true,
        
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        bAutoWidth:false,
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "Section", data: "GroupSection", name:"GroupSection" },
            { title: "Cost Code Name", data: "Section", name: "Section" },
            {
                title: "PureSection", visible:false ,data: function (x) {
                    $("#SectionIDhere").val(x.GroupSection);
                    return ""
                }}
            
            //{
            //    title: "Approver", data: function (x) {
            //        return "<button type='button' onclick=getApprover('" + x.ID + "') class='btn btn-sm bg-blue btnedit' id=data" + x.ID + ">" +
            //            "<i class='fa fa-user' ></i> Approvers" +
            //            "</button> "
            //    }
            //},
        ],

    });
    $('#SectionTable tbody').off('click');
    $('#SectionTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#SectionTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#Section').val(data.Section);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#SectionTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#SectionTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../Section/DeleteSection', data.ID, data.Section);

    });

}

function getApprover() {
    $('#Approvermodal').modal({
        backdrop: 'static',
        keyboard: false
    })
    $("#Supervisorpart").html('');
    $("#Managerpart").html('');
    $("#GenManpart").html('');
    $("#FGManagerpart").html('');
    //$("#SectionIDhere").val(data);
    $.ajax({
        url: '/Section/GetApprovers',
        type: 'GET',
        datatype: "json",
        data: { Section: $("#SectionIDhere").val() },
        success: function (returnData) {
            if (returnData.ApproversSupervisors.length > 0) {
                for (var x = 0; x < returnData.ApproversSupervisors.length; x++) {
                    Addsupervisor();
                    $("#Supervisor" + ID).val(returnData.ApproversSupervisors[x].EmployeeNo);
                    getname2(returnData.ApproversSupervisors[x].EmployeeNo, "Supervisor" + ID);
                    ID = ID + 1;
                }
            }
            if (returnData.ApproversManager.length > 0) {
                for (var x = 0; x < returnData.ApproversManager.length; x++) {
                    AddManager();
                    $("#Supervisor" + ID).val(returnData.ApproversManager[x].EmployeeNo);
                    getname2(returnData.ApproversManager[x].EmployeeNo, "Supervisor" + ID);
                    ID = ID + 1;
                }
            }
            if (returnData.ApproversGenManager.length > 0) {
                for (var x = 0; x < returnData.ApproversGenManager.length; x++) {
                    AddGenManager();
                    $("#Supervisor" + ID).val(returnData.ApproversGenManager[x].EmployeeNo);
                    getname2(returnData.ApproversGenManager[x].EmployeeNo, "Supervisor" + ID);
                    ID = ID + 1;
                }
            }
            if (returnData.ApproversFGenManager.length > 0) {
                for (var x = 0; x < returnData.ApproversFGenManager.length; x++) {
                    AddFGenManager();
                    $("#Supervisor" + ID).val(returnData.ApproversFGenManager[x].EmployeeNo);
                    getname2(returnData.ApproversFGenManager[x].EmployeeNo, "Supervisor" + ID);
                    ID = ID + 1;
                }
            }
            $("#Approvermodal").modal("show");
            
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });

   
}

function AddSection(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Section/CreateSection',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                swal("Section Saved");
            }
            else {
                swal("Section Already Exist");
            }

        }
    });
}

function EditSection(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Section/EditSection',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                swal("Section Saved");
            }
            else {
                swal("Section Already Exist");
            }

        }
    });
}

function getEmployeeNo(id) {
    var theID = $(id).attr('id')
    var options = '';
    var datas = $("#" + theID).val();

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //Dropdown_select('Line_Team', "/Helper/GetDropdown_LineProcessTeam");

    //FOR FG
    $.ajax({
        url: "/Helper/GetEmployeeNo",
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { Agency: $("#" + theID).val() },
        rowNum: 1000,
        success: function (returnData) {
            options = "";
            if (returnData.list.length > 20) {
                l = 10;
            }
            else {
                l = returnData.list.length;
            }
            for (var i = 0; i < l; i++) {
                options += '<option value="' + returnData.list[i].EmpNo + '" />';
            }
            $("#EmployeeNoList_Supervisor").empty().append(options);
            document.getElementById('EmployeeNoList_Supervisor').innerHTML = options;

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function getEmployeeUsername(id) {
    var theID = $(id).attr('id')
    var options = '';
    var datas = $("#" + theID).val();

    //partno
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    //Dropdown_select('Line_Team', "/Helper/GetDropdown_LineProcessTeam");

    //FOR FG
    $.ajax({
        url: "/Helper/GetUsername",
        type: 'GET',
        datatype: "json",
        loadonce: true,
        //async:true,
        data: { Agency: $("#" + theID).val() },
        rowNum: 1000,
        success: function (returnData) {
            options = "";
            if (returnData.list.length > 20) {
                l = 10;
            }
            else {
                l = returnData.list.length;
            }
            for (var i = 0; i < l; i++) {
                options += '<option value="' + returnData.list[i].UserName + '" />';
            }
            $("#EmployeeNoList_Supervisor").empty().append(options);
            document.getElementById('EmployeeNoList_Supervisor').innerHTML = options;

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function SaveApprover() {
    var approver = [];
    $(".approverdata_Supervisor").each(function () {
        var item = {
            Section: $("#SectionIDhere").val(),
            EmployeeNo: $(this).val(),
            Position : "Supervisor"
        }
        approver.push(item)
    });

    $(".approverdata_manager").each(function () {
        var item = {
            Section: $("#SectionIDhere").val(),
            EmployeeNo: $(this).val(),
            Position: "Manager"
        }
        approver.push(item)
    });
    
    $(".approverdata_genmanager").each(function () {
        var item = {
            Section: $("#SectionIDhere").val(),
            EmployeeNo: $(this).val(),
            Position: "GeneralManager"
        }
        approver.push(item)
    });

    $(".approverdata_fgenmanager").each(function () {
        var item = {
            Section: $("#SectionIDhere").val(),
            EmployeeNo: $(this).val(),
            Position: "FactoryGeneralManager"
        }
        approver.push(item)
    });

    $.ajax({
        url: '../Section/SaveApprover',
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            Approver: approver,
        }),
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "") {
                notify("Saved!", "Successfully Saved", "success");
                $("#Approvermodal").modal("hide");
            }
            else {
                swal(returnData.msg);
                $("#Approvermodal").modal("hide");
            }
               
        }
    });
}

function Addsupervisor() {
    ID = ID + 1;
    var row = "<div class='row' id='row" + ID + "'>" +
                "<div class='col-md-3'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group outut'>" +
                            "<span class='input-group-addon' style='border-color:white;'>Section Supervisor</span>"+
                        "</div>"+
                    "</div>"+
                "</div>"+
                "<div class='col-md-4'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group'>"+
                            //"<input list='EmployeeNoList_Supervisor' placeholder='Section Supervisor ID' name='Supervisor' id='Supervisor" + ID + "' class='form-control approverdata_Supervisor' onkeyup='getEmployeeNo(this)' onfocusout='getname(this)'>" +
                            "<input list='EmployeeNoList_Supervisor' placeholder='Input ID number' name='Supervisor' id='Supervisor" + ID + "' class='form-control approverdata_Supervisor' onkeyup='getEmployeeUsername(this)' onfocusout='getusername(this)'>" +

                            "<datalist id='EmployeeNoList_Supervisor'></datalist>" +
                        "</div>"+
                    "</div>"+
                "</div>"+

                "<div class='col-md-4'>"+
                    "<div class='form-group'>"+
                        "<div class='input-group'>"+
                            "<input type='text' class='form-control' id='Supervisor" + ID + "Name' name='SupervisorName' disabled />" +
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
    $("#Supervisorpart").append(row);
   
}

function AddManager() {
    ID = ID + 1;
    var row = "<div class='row' id='row" + ID + "'>" +
                "<div class='col-md-3'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<span class='input-group-addon' style='border-color:white;'>Section Manager</span>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +

                            "<input list='EmployeeNoList_Supervisor' placeholder='Input ADID' name='Supervisor' id='Supervisor" + ID + "' class='form-control approverdata_manager' onkeyup='getEmployeeUsername(this)' onfocusout='getusername(this)'>" +
                            "<datalist id='EmployeeNoList_Supervisor'></datalist>" +
                        "</div>" +
                    "</div>" +
                "</div>" +

                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<input type='text' class='form-control' id='Supervisor" + ID + "Name' name='Supervisor" + ID + "Name' disabled />" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                 "<div class='col-md-1'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<button class='btn btn-google' onclick='removerow(" + ID + ")'><i class='fa fa-close'></i></button>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
            "</div>";
    $("#Managerpart").append(row);

}

function AddGenManager() {
    ID = ID + 1;
    var row = "<div class='row' id='row" + ID + "'>" +
                "<div class='col-md-3'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<span class='input-group-addon' style='border-color:white;'>General Manager</span>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +

                            "<input list='EmployeeNoList_Supervisor' placeholder='Input ADID' name='Supervisor' id='Supervisor" + ID + "' class='form-control approverdata_genmanager' onkeyup='getEmployeeUsername(this)' onfocusout='getusername(this)'>" +
                            "<datalist id='EmployeeNoList_Supervisor'></datalist>" +
                        "</div>" +
                    "</div>" +
                "</div>" +

                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<input type='text' class='form-control' id='Supervisor"+ID+"Name' name='Supervisor" + ID + "Name' disabled />" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                 "<div class='col-md-1'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<button class='btn btn-google' onclick='removerow("+ID+")'><i class='fa fa-close'></i></button>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
            "</div>";
    $("#GenManpart").append(row);

}

function AddFGenManager() {
    ID = ID + 1;
    var row = "<div class='row' id='row" + ID + "'>" +
                "<div class='col-md-3'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<span class='input-group-addon' style='border-color:white;'>Factory General Manager</span>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +

                            "<input list='EmployeeNoList_Supervisor' placeholder='Input ADID' name='Supervisor' id='Supervisor" + ID + "' class='form-control approverdata_fgenmanager' onkeyup='getEmployeeUsername(this)' onfocusout='getusername(this)'>" +
                            "<datalist id='EmployeeNoList_Supervisor'></datalist>" +
                        "</div>" +
                    "</div>" +
                "</div>" +

                "<div class='col-md-4'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<input type='text' class='form-control' id='Supervisor" + ID + "Name' name='Supervisor" + ID + "Name' disabled />" +
                        "</div>" +
                    "</div>" +
                "</div>" +
                 "<div class='col-md-1'>" +
                    "<div class='form-group'>" +
                        "<div class='input-group'>" +
                            "<button class='btn btn-google' onclick='removerow(" + ID + ")'><i class='fa fa-close'></i></button>" +
                        "</div>" +
                    "</div>" +
                "</div>" +
            "</div>";
    $("#FGManagerpart").append(row);

}

function getname(data) {
    var ss = $(data).attr('id')
    $.ajax({
        url: '../Section/GetEmployeeName',
        data: { EmployeeNo: $(data).val() },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $("#" + ss +"Name").val(returnData.completename);
        }
    });
}

function getusername(data) {
    var ss = $(data).attr('id')
    $.ajax({
        url: '../Section/GetUserName',
        data: { EmployeeNo: $(data).val() },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $("#" + ss + "Name").val(returnData.completename);
        }
    });
}


function getname2(data,idname) {
    $.ajax({
        url: '../Section/GetEmployeeName',
        data: { EmployeeNo: data },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $("#" + idname + "Name").val(returnData.completename);
        }
    });
}

function removerow(data) {
    $("#row"+data).html('');
    //alert(data);
}


