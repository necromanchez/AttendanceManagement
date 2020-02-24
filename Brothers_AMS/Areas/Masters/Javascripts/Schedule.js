﻿$(function () {
    Initializepage();
    $('#ScheduleForm').on('submit', function (e) {
        e.preventDefault();
        if ($('#Type').val() != ""
            && $('#Status').val() != ""
            && $('#Timein').val() != ""
            && $('#TimeOut').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddSchedule($(this));
            }
            else {
                EditSchedule($(this));
            }
        }
    });
    $("#btnAddBreaks").on("click", Addbreaks);


    //$('#TimeOut22').timepicker({ timeFormat: 'h:mm:ss p' });
    

 
})

function Initializepage() {
    $("#ScheduleForm")[0].reset();
    $("#ID").val("");
    $('#ScheduleTable').DataTable({
        ajax: {
            url: '../Schedule/GetScheduleList',
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
           
            { title: "Schedule Name", data: "Type" },
            //{ title: "Time In", data: "TimeInData" },
            //{ title: "Time Out", data: "TimeOutData" },
            { title: "Time In", data: "TimeIn" },
            { title: "Time Out", data: "TimeOut" },
            {
                 title: "Breaks", data: function (x) {
                     return "<a class='btn btn-sm bg-blue btnBreaks'>"+
                            "<i class='fa fa-edit'></i> Break"+
            			    "</a>"
                            
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
    $('#ScheduleTable tbody').off('click');
    $('#ScheduleTable tbody').on('click', '.btnedit', function () {

        var tabledata = $('#ScheduleTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#ScheduleCode').val(data.ScheduleCode);
        $('#Type').val(data.Type);
        $('#Timein').val(data.TimeIn);
        $('#TimeOut').val(data.TimeOut);
        $('#Status').val(data.Status);
        $('#Status option[value=' + data.Status + ']').prop('selected', true);
        $('#ID').val(data.ID);
        $("tr").removeClass("row_selected");
        $(this).parents('tr').addClass("row_selected");

    });
    $('#ScheduleTable tbody').on('click', '.btndelete', function () {
        var tabledata = $('#ScheduleTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.ID);
        Deletionheres('../Schedule/DeleteSchedule', data.ID, data.Schedule);

    });

    $('#ScheduleTable tbody').on('click', '.btnBreaks', function () {
        var tabledata = $('#ScheduleTable').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $("#ScheduleID").val(data.ID);
        InitializedBreaks(data.ID)
       
        $("#BreakAdd").modal("show");
    });
}

function AddSchedule(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Schedule/CreateSchedule',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Schedule Saved");
                notify("Saved!", "Successfully Saved", "success");
            }
            else if (returnData.msg == "zero") {
                swal("Please recheck Schedule");

            }
            else {
                swal("Schedule Already Exist");
            }

        }
    });
}

function EditSchedule(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../Schedule/EditSchedule',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage();
                //swal("Schedule Saved");
                notify("Saved!", "Successfully Saved", "success");
            }
            else {
                swal("Schedule Already Exist");
            }

        }
    });
}

function Addbreaks() {
    if ($("#BreakID").val() != "") {
        EditBreaks();
    }
    else {
        var datanow = $("#BreaksForm").serialize();
        $.ajax({
            url: '../Schedule/AddBreaks',
            data: datanow,
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                if (returnData.msg == "Success") {
                    notify("Saved!", "Successfully Saved", "success");
                    InitializedBreaks(returnData.ID);
                }
                else if (returnData.msg == "zero") {
                    swal("Please recheck breaks");
                }
                else {
                    swal("Breaks Already Exist");
                }

            }
        });
    }

}

function InitializedBreaks(ID) {
     $('#tbl_ScheduleBreaks').DataTable({
            ajax: {
                url: '../Schedule/GetBreaks',
                type: "POST",
                datatype: "json",
                data: { ID: ID }
            },
            pagelength: 5000,
            lengthChange: false,
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
                { title: "Break Out", data: "BreakOut" },
                { title: "Break In", data: "BreakIn" },
                { title: "Break Time", data: "BreakTime" },
                {
                    title: "Action", data: function (x) {
                        return "<button type='button' class='btn btn-sm bg-blue btnEdit' alt='alert' class='model_img img-fluid'>" +
                                "<i class='fa fa-pencil-square-o'></i> Edit" +
                                "</button>" +
                             "<button type='button' class='btn btn-sm bg-red btndeletebreak' alt='alert' class='model_img img-fluid'>" +
                            "<i class='fa fa-trash'></i> Delete" +
                            "</button>"
                    }
                },
            ],

     });

     $('#tbl_ScheduleBreaks tbody').on('click', '.btndeletebreak', function () {
         var tabledata = $('#tbl_ScheduleBreaks').DataTable();
         var data = tabledata.row($(this).parents('tr')).data();
         $('#ID').val(data.ID);
         DeletionheresBreaks('../Schedule/DeleteScheduleBreak', data.ID, "");
         $("#brekbtn").text("Add");
     });

     $('#tbl_ScheduleBreaks tbody').on('click', '.btnEdit', function () {
         var tabledata = $('#tbl_ScheduleBreaks').DataTable();
         var data = tabledata.row($(this).parents('tr')).data();
         $("#BreakOut").val(data.BreakOut);
         $("#BreakIn").val(data.BreakIn);
         $("#BreakID").val(data.ID);
         $("#ScheduleID").val(data.ScheduleID);
         //EditBreaks(data.ID);
         $("#brekbtn").text("Edit");
     });
}

function DeletionheresBreaks(link, ID, Name) {
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
                        notify("Deleted!", "Data has been deleted.", "success");
                        Initializepage();
                        //Clearall();
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

function EditBreaks() {
    
    $.ajax({
        url: '../Schedule/EditBreaks',
        data: {
            BreakOut: $("#BreakOut").val(),
            BreakIn: $("#BreakIn").val(),
            ID: $("#BreakID").val(),
            ScheduleID: $("#ScheduleID").val()
        },
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                InitializedBreaks($("#ScheduleID").val());
                //swal("Breaks Saved");
                notify("Saved!", "Successfully Saved", "success");
                $("#BreakID").val("");
                $("#brekbtn").text("Add");
            }
            else {
                swal("Breaks Already Exist");
            }

        }
    });
}
