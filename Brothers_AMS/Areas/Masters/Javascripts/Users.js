$(function () {
    //Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");
    Dropdown_selectMPMain2('Section', "/Helper/GetDropdown_SectionAMS?Dgroup=");
    GetUser();
   
    $('#UsersForm').on('submit', function (e) {
        e.preventDefault();
    
        if ($('#ID').val() == "") {
            AddUsers($(this));
        }
        else {
            EditUsers($(this));
        }
        
    });
    
    $("#checkall_section").on("change", function () {
        if (this.checked) {
            $('.secmods').prop('checked', true);
        }
        else {
            $('.secmods').prop('checked', false);
        }
    })

    $("#checkall_line").on("change", function () {
        if (this.checked) {
            $('.linemods').prop('checked', true);
        }
        else {
            $('.linemods').prop('checked', false);
        }
    })

    $("#checkall_master").on("change", function () {
        if (this.checked) {
            $('.mastermod').prop('checked', true);
        }
        else {
            $('.mastermod').prop('checked', false);
        }
    })

    $("#checkall_ApplicationForm").on("change", function () {
        if (this.checked) {
            $('.afmod').prop('checked', true);
        }
        else {
            $('.afmod').prop('checked', false);
        }
    })

    $("#checkall_Reports").on("change", function () {
        if (this.checked) {
            $('.reportsmod').prop('checked', true);
        }
        else {
            $('.reportsmod').prop('checked', false);
        }
    })

    $('#btn_save_PageAccess').on('click', SavePageAccess);
    $("#btn_save_SectionAccess").on("click", SaveSectionAccess);
    $("#btn_save_LineAccess").on("click", SaveLineAccess);

    $("#downloadbtnusers").on("click", function () { window.open('../Users/ExportUsers?Section=' + $("#Section").val()); });

    $("#Section").on("change", function () {

        Initializepage();
        Initializepage_Normal();
    });
    $("#closepagemodal").on("click", function () {
        var changes = SavePageAccessChecker();
        if (changes) {
            ConfirmChanges();
        }
        else {
            $('#ModalPageAccess').modal("hide");
        }
       
    })


    $('#tabs').on('shown.bs.tab', function (event) {
        var x = $(event.target)[0].id;         // active tab
        $(".padhider").hide();
            switch (x) {
                case "SuperUser":
                  
                    $("#NormalUsertab").hide();
                    $("#SuperUsertab").show();
                    break;
                case "NormalUser":
                    
                    $("#NormalUsertab").show();
                    $("#SuperUsertab").hide();
                    
                    break;
               
            }
     

        //var y = $(event.relatedTarget).text();  // previous tab

    });
})
var currentSectionuser = "";
function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            currentSectionuser = returnData.usersection;
            Initializepage();
            Initializepage_Normal();
        }
    });
}

var currentuser;
var GoodCount;
var SaveGoodCount = 0;
var pagecount = 0;
function Initializepage() {
    //$("#UsersForm")[0].reset();
    //$("#ID").val("");
    $('#UsersTable').DataTable({
        ajax: {
            url: '../Users/GetUsersList',
            type: "POST",
            datatype: "json",
            data:{supersection:$("#Section").val()}
        },
        lengthMenu: [[10, 50, 100], [10, 50, 100]],

        lengthChange: true,
        scrollY: "600px",
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        initComplete: function () {

            if (currentSectionuser == "Production Engineering") {
                var table = $('#UsersTable').DataTable();
                table.column(10).visible(true);
            }


        },
        columns: [
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "ID", data: "ID", name: "ID", visible: false },
           
            { title: "UserName", data: "UserName", name: "UserName" },
            { title: "First Name", data: "FirstName", name: "UserName" },
            { title: "Last Name", data: "LastName", name: "UserName" },
            { title: "Email", data: "Email", name: "UserName" },
            //{
            //       title: "Section", data: function (x) {
            //           return "<button type='button' data-toggle='modal' data-target='#SectionAdd' class='btn bg-blue btnsection' id=data" + x.ID + ">" +
            //                "<i class='fa fa-user-secret' ></i> Section" +
            //            "</button>"
            //       }
            //},
            {
                title: "Section", data: "SectionGroup", name: "SectionGroup"
                
            },
            //{
            //    title: "Line", data: function (x) {
            //        return "<button type='button' data-toggle='modal' data-target='#LineAdd' class='btn bg-blue btnline' id=data" + x.ID + ">" +
            //             "<i class='fa fa-line-chart ' ></i> LINE" +
            //         "</button>"
            //    }
            //},
            {
                   title: "Page Access", data: function (x) {
                       return "<button type='button' class='btn bg-blue btnPageAccess' id=data" + x.ID + ">" +
                            "<i class='fa fa-newspaper-o' ></i> Pages" +
                        "</button>"
                   }
            },
            {
                title: "Status", data: function (x) {
                    if (x.Status != null) {
                        var label = (x.Status.toLowerCase() == "active") ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                        return label
                    }
                    else {
                        return "";
                    }
                }
            },
            {
                title: "Delete", data: function (x) {
                  
                    return "<button type='button' class='btn bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                        "<i class='fa fa-trash '></i> Delete" +
                        "</button>"
                       
                }
            },
            {
                title: "Reset", data: function (x) {
                  
                    return "<button type='button' class='btn bg-blue btnreset' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-refresh '></i> Reset Password" +
                            "</button>"
                }, visible: false
            },
        ],

    });
    $('#UsersTable tbody').off('click');
    $('#UsersTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#UserName').val(data.UserName);
        $('#FirstName').val(data.FirstName);
        $('#LastName').val(data.LastName);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#UsersTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.UserName);
        Deletionheres('../Users/DeleteUsers', data.ID, data.Users);

    });
    $('#UsersTable tbody').on('click', '.btnsection', function () {
        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        GetSectionAccess(data.UserName);

    });
    $('#UsersTable tbody').on('click', '.btnline', function () {
        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        GetLineAccess(data.UserName, data.Section);

    });
    $('#UsersTable tbody').on('click', '.btnreset', function () {
        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.UserName);
        Resetheres('../Users/ResetPassUsers', data.ID, data.Users);

    });

    $('#UsersTable tbody').on('click', '.btnPageAccess', function () {
        $('#ModalPageAccess').modal({
            backdrop: 'static',
            keyboard: false
        })
        $("#ModalPageAccess").modal("show");
        var tabledata = $('#UsersTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        $.ajax({
            url: '../Users/GetPageAccess',
            data: { UserName : data.UserName},
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                GoodCount = returnData.GoodCount;
                SaveGoodCount = 0;
                //--Master
                $('#tbl_PageAccess_Master').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.MasterPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Master_" + data.ID + " class='mastermod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                        " <label class=checker for=Master_" + data.ID + "></label>"
                                      
                            }, orderable: false, searchable: false
                        },
                    ]
                });
               
                //--END of Master


                //--Application Form
                $('#tbl_PageAccess_ApplicationForm').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.ApplicationFormPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=ApplicationForm_" + data.ID + " class='afmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                        " <label class=checker for=ApplicationForm_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form


                //--Application Form
                $('#tbl_PageAccess_Reports').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.SummaryPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Reports_" + data.ID + " class='reportsmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                        " <label class=checker for=Reports_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form

                //--Application Form
                $('#tbl_PageAccess_Forecast').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.ForeCastList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Forecast_" + data.ID + " class='reportsmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                        " <label class=checker for=Forecast_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form

            }
        });
    });
    
    pagecount = 0;
}

function Initializepage_Normal() {
    //$("#UsersForm")[0].reset();
    //$("#ID").val("");
    $('#NormalUserTable').DataTable({
        ajax: {
            url: '../Users/GetUsersList_Normal',
            type: "POST",
            datatype: "json",
            data: { supersection: $("#Section").val() }
        },
        lengthMenu: [[10, 50, 100], [10, 50, 100]],

        lengthChange: true,
        scrollY: "600px",
        scrollCollapse: true,
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        initComplete: function () {

            if (currentSectionuser == "Production Engineering") {
                var table = $('#NormalUserTable').DataTable();
                table.column(10).visible(true);
            }


        },
        columns: [
            { title: "No", data: "Rownum", name: "Rownum" },
            { title: "ID", data: "ID", name: "ID", visible: false },

            { title: "UserName", data: "UserName", name: "UserName" },
            { title: "First Name", data: "FirstName", name: "UserName" },
            { title: "Last Name", data: "LastName", name: "UserName" },
            { title: "Email", data: "Email", name: "UserName" },
            
            {
                title: "Section", data: "SectionGroup", name: "SectionGroup"

            },
            
            {
                title: "Page Access", data: function (x) {
                    return "<button type='button' class='btn bg-blue btnPageAccess' id=data" + x.ID + ">" +
                        "<i class='fa fa-newspaper-o' ></i> Pages" +
                        "</button>"
                }
            },
            {
                title: "Status", data: function (x) {
                    if (x.Status != null) {
                        var label = (x.Status.toLowerCase() == "active") ? "<button type='button' class='btn btn-xs bg-green'>Active</button>" : "<button type='button' class='btn btn-xs bg-red'>Inactive</button>"
                        return label
                    }
                    else {
                        return "";
                    }
                }
            },
            {
                title: "Delete", data: function (x) {

                    return "<button type='button' class='btn bg-red btndelete' alt='alert' class='model_img img-fluid'>" +
                        "<i class='fa fa-trash '></i> Delete" +
                        "</button>"

                }
            },
            {
                title: "Reset", data: function (x) {

                    return "<button type='button' class='btn bg-blue btnreset' alt='alert' class='model_img img-fluid'>" +
                        "<i class='fa fa-refresh '></i> Reset Password" +
                        "</button>"
                }, visible:false
            },
        ],

    });
    $('#NormalUserTable tbody').off('click');
    $('#NormalUserTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#UserName').val(data.UserName);
        $('#FirstName').val(data.FirstName);
        $('#LastName').val(data.LastName);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#NormalUserTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.UserName);
        Deletionheres('../Users/DeleteUsers', data.ID, data.Users);

    });
    $('#NormalUserTable tbody').on('click', '.btnreset', function () {
        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.UserName);
        Resetheres('../Users/ResetPassUsers', data.ID, data.Users);

    });
    $('#NormalUserTable tbody').on('click', '.btnsection', function () {
        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        GetSectionAccess(data.UserName);

    });
    $('#NormalUserTable tbody').on('click', '.btnline', function () {
        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        GetLineAccess(data.UserName, data.Section);

    });


    $('#NormalUserTable tbody').on('click', '.btnPageAccess', function () {
        $('#ModalPageAccess').modal({
            backdrop: 'static',
            keyboard: false
        })
        $("#ModalPageAccess").modal("show");
        var tabledata = $('#NormalUserTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        currentuser = data.UserName;
        $.ajax({
            url: '../Users/GetPageAccess',
            data: { UserName: data.UserName },
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                GoodCount = returnData.GoodCount;
                SaveGoodCount = 0;
                //--Master
                $('#tbl_PageAccess_Master').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.MasterPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Master_" + data.ID + " class='mastermod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=Master_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });

                //--END of Master


                //--Application Form
                $('#tbl_PageAccess_ApplicationForm').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.ApplicationFormPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=ApplicationForm_" + data.ID + " class='afmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=ApplicationForm_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form


                //--Application Form
                $('#tbl_PageAccess_Reports').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.SummaryPageList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Reports_" + data.ID + " class='reportsmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=Reports_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form

                //--Application Form
                $('#tbl_PageAccess_Forecast').DataTable({
                    destroy: true,
                    searching: false,
                    paging: false,
                    data: returnData.ForeCastList,
                    columns: [
                        { data: "PageName" },
                        {
                            data: function (data, type, row, meta) {
                                var checked = (data.AccessType == true) ? ' checked ' : '';
                                return " <input type='checkbox' id=Forecast_" + data.ID + " class='reportsmod filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=Forecast_" + data.ID + "></label>"

                            }, orderable: false, searchable: false
                        },
                    ]
                });
                //--END of Application Form

            }
        });
    });

    pagecount = 0;
}

function AddUsers(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Users/CreateUsers',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                swal("Users Saved");
                var tabledata = $('#UsersTable').DataTable();
                var info = tabledata.page.info();
                pagecount = pagecount + (info.page * 10);
                $('#UsersForm').trigger("reset");
                Initializepage();
            }
            else {
                swal("Users Already Exist");
            }

        }
    });
}

function EditUsers(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Users/EditUsers',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                swal("Users Saved");
                var tabledata = $('#UsersTable').DataTable();
                var info = tabledata.page.info();
                pagecount = pagecount + (info.page * 10);
                Initializepage();
                swal("Users Saved");
            }
            else {
                swal("Users Already Exist");
            }

        }
    });
}

function SavePageAccess() {
    $("#loading_modal").modal("show")

    var table = $('#tbl_PageAccess_Master').DataTable();
    var pagelist = [];
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Master",
            //PageName: d.PageName,
            PageAccess: ($('#Master_' + d.ID).is(":checked")) ? true : false
        }
        pagelist.push(item);
    });

    var table2 = $('#tbl_PageAccess_ApplicationForm').DataTable();
    table2.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Application Form",
            //PageName: d.PageName,
            PageAccess: ($('#ApplicationForm_' + d.ID).is(":checked")) ? true : false
        }
        pagelist.push(item);
    });

    var table3 = $('#tbl_PageAccess_Reports').DataTable();
    table3.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Reports",
            //PageName: d.PageName,
            PageAccess: ($('#Reports_' + d.ID).is(":checked")) ? true : false
        }
        pagelist.push(item);
    });

    var table4 = $('#tbl_PageAccess_Forecast').DataTable();
    table4.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Reports",
            //PageName: d.PageName,
            PageAccess: ($('#Forecast_' + d.ID).is(":checked")) ? true : false
        }
        pagelist.push(item);
    });
    
    $.ajax({
        url: '../Users/UpdatePageAccess',
        type: 'POST',
        datatype: "json",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            PA_userpage: pagelist,
        }),
        success: function (returnData) {
            if (returnData.msg == "Success") {
                $("#loading_modal").modal("hide")

                var tabledata = $('#UsersTable').DataTable();
                var info = tabledata.page.info();
                pagecount = pagecount + (info.page * 10);
                Initializepage();
                notify("Saved!", "Successfully Saved", "success");

            }
            else {
               
            }

        }
    });
        


}

function SaveSectionAccess() {
    var table = $('#tbl_SectionAccess').DataTable();
    var sectionlist = [];
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            SectionID: d.ID,
            SectionAccess: ($('#Section_' + d.ID).is(":checked")) ? true : false
        }
        sectionlist.push(item);
    });

    $.ajax({
        url: '../Users/UpdateSectionAccess',
        type: 'POST',
        datatype: "json",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            PA_section: sectionlist,
        }),
        success: function (returnData) {
            if (returnData.msg == "Success") {
                location.reload();
            }
            else {

            }

        }
    });

}

function GetSectionAccess(UserName) {
    $.ajax({
        url: '../Users/GetSectionAccess',
        data: { UserName: UserName },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {

            //--Section
            $('#tbl_SectionAccess').DataTable({
                destroy: true,
                searching: false,
                paging: false,
                data: returnData.SectionList,
                columns: [
                    { data: "Section" },
                    {
                        data: function (data, type, row, meta) {
                            var checked = (data.AccessType == true) ? ' checked ' : '';
                            return " <input type='checkbox' id=Section_" + data.ID + " class='secmods filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=Section_" + data.ID + "></label>"

                        }, orderable: false, searchable: false
                    },
                ]
            });

            //--END of Section

        }
    });
}


function SaveLineAccess() {
    var table = $('#tbl_LineAccess').DataTable();
    var linelist = [];
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            LineID: d.ID,
            LineAccess: ($('#Line_' + d.ID).is(":checked")) ? true : false
        }
        linelist.push(item);
    });

    $.ajax({
        url: '../Users/UpdateLineAccess',
        type: 'POST',
        datatype: "json",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({
            PA_line: linelist,
        }),
        success: function (returnData) {
            if (returnData.msg == "Success") {
                location.reload();
            }
            else {

            }

        }
    });
}

function GetLineAccess(UserName,Section) {
    $.ajax({
        url: '../Users/GetLineAccess',
        data: {
            UserName: UserName,
            Section: Section
        },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {

            //--Section
            $('#tbl_LineAccess').DataTable({
                destroy: true,
                searching: false,
                paging: false,
                data: returnData.LineList,
                columns: [
                    { data: "Line" },
                    {
                        data: function (data, type, row, meta) {
                            var checked = (data.AccessType == true) ? ' checked ' : '';
                            return " <input type='checkbox' id=Line_" + data.ID + " class='linemods filled-in chk-col-light-blue' " + checked + " name=PageView_" + data.ID + "/>" +
                                    " <label class=checker for=Line_" + data.ID + "></label>"

                        }, orderable: false, searchable: false
                    },
                ]
            });

            //--END of Section

        }
    });
}


function SavePageAccessChecker() {
    var Good = false;
    var table = $('#tbl_PageAccess_Master').DataTable();
    var pagelist = [];
    table.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Master",
            //PageName: d.PageName,
            PageAccess: ($('#Master_' + d.ID).is(":checked")) ? true : false
        }
        if ($('#Master_' + d.ID).is(":checked")) {
            SaveGoodCount++;
        }
        pagelist.push(item);
    });

    var table2 = $('#tbl_PageAccess_ApplicationForm').DataTable();
    table2.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Application Form",
            //PageName: d.PageName,
            PageAccess: ($('#ApplicationForm_' + d.ID).is(":checked")) ? true : false
        }
        if ($('#ApplicationForm_' + d.ID).is(":checked")) {
            SaveGoodCount++;
        }
        pagelist.push(item);
    });

    var table3 = $('#tbl_PageAccess_Reports').DataTable();
    table3.rows().every(function () {
        var d = this.data();
        d.counter++;
        var item = {
            UserName: currentuser,
            PageID: d.ID,
            //PageModule: "Reports",
            //PageName: d.PageName,
            PageAccess: ($('#Reports_' + d.ID).is(":checked")) ? true : false
        }
        if ($('#Reports_' + d.ID).is(":checked")) {
            SaveGoodCount++;
        }
        pagelist.push(item);
    });
    
    Good = (SaveGoodCount != GoodCount) ? true : false;
    return Good;
   
}

function ConfirmChanges() {
    swal({
        title: "Save Changes?",
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
            SavePageAccess();
        } else {
            $('#ModalPageAccess').modal("hide");
        }
    });
}

function UploadPageAccess() {
    $("#loading_modal").modal("show")
    var files = new FormData();
    var file1 = document.getElementById("UploadedAccess").files[0];
    files.append('files[0]', file1);
    $.ajax({
        type: 'POST',
        url: '../Users/UploadPageAccess',
        data: files,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        success: function (response) {
            if (response.result == "success") {
                $("#loading_modal").modal("hide")
                swal("User Page Access Updated");
                location.reload();
            }
            else {
                swal("An error occured");

            }
        },
        error: function (error) {

        }
    });
}