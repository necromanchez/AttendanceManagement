$(function () {
    $(".textarea").wysihtml5();

    update($("#TheText").val(), mode);
    $("#btnupp").on('click', function () {
        mode = "ADD";
        update($("#TheText").val(), mode);
        
    })
   
});

var mode = "CALL";

function update(data, mode) {

    $.ajax({
        url: '../Home/UpdateBoard',
        type: "GET",
        data: {
            data: data,
            Mode: mode
        },
        contentType: "application/json; charset=utf-8",
        cache: false,
        //processing: true,
        dataType: "json",
        beforeSend: function () {
            $("#loading_modal").modal("show");
        },
        success: function (returndata) {
            if (mode == "CALL") {
            }
            else {
                notify("Information Updated", "Information Board Updated", "success");
            }

            if (returndata.accessType == true)
            {
                $("#btnupp").css('display', 'initial');
                $("#charts_dashboard").css('display', 'initial');
                
            }
            else
            {
                $("#btnupp").css('display', 'none');
                $("#charts_dashboard").css('display', 'none');
                
            }

            if (returndata.msg == null || returndata.msg =="") {
                document.getElementById("TheText").value = "Good day! :)"
            }
            else {
                document.getElementById("TheText").value = returndata.msg
            }
            $("#loading_modal").modal("hide");
        }


    });

    //document.getElementById("TheText").value = "demonyado";
    //$("#TheText").val("yeta")
}