$(function () {


    Initializepage();
    Yearspopulate();
    $("#btnAddYear").on("click", function () {
        $.ajax({
            url: '../ForecastSetting/SaveYear',
            data: {Year:$("#Years").val()},
            type: 'POST',
            datatype: "json",
            success: function (returnData) {
                Initializepage();
            }
        })
    })


    Initializepage2();

    $("#ForecastPostForm").on("submit", function (e) {
        e.preventDefault();
        if ($('#Position').val() != ""
            && $('#ClassJ').val() != ""
            && $('#ClassE').val() != ""
            && $('#Unit').val() != ""
            ) {
            if ($('#ID').val() == "") {
                AddPosForecast($(this));
            }
            else {
                EditPosForecast($(this));
            }
        }

    })


  
})


function Initializepage() {
    $('#Forecasttbls').DataTable({
        ajax: {
            url: '../ForecastSetting/GetForecastYearList',
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        lengthChange: false,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "Year", data: "Year" },
            {
                title: "Apr", data: function (x) {
                    if (x.Apr == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Apr>"
                    }
                    else {
                        return "<input type='text' value="+x.Apr+" onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Apr>"
                    }
                }
            },
            {
                title: "May", data: function (x) {
                    if (x.May == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "May>"
                    }
                    else {
                        return "<input type='text' value=" + x.May + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "May>"
                    }
                }
            },
            {
                title: "Jun", data: function (x) {
                    if (x.Jun == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jun>"
                    }
                    else {
                        return "<input type='text' value=" + x.Jun + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jun>"
                    }
                }
            },
            {
                title: "Jul", data: function (x) {
                    if (x.Jul == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jul>"
                    }
                    else {
                        return "<input type='text' value=" + x.Jul + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jul>"
                    }
                }
            },
            {
                title: "Aug", data: function (x) {
                    if (x.Aug == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Aug>"
                    }
                    else {
                        return "<input type='text' value=" + x.Aug + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Aug>"
                    }
                }
            },
            {
                title: "Sep", data: function (x) {
                    if (x.Sep == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Sep>"
                    }
                    else {
                        return "<input type='text' value=" + x.Sep + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Sep>"
                    }
                }
            },
            {
                title: "Oct", data: function (x) {
                    if (x.Oct == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Oct>"
                    }
                    else {
                        return "<input type='text' value=" + x.Oct + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Oct>"
                    }
                }
            },
            {
                title: "Nov", data: function (x) {
                    if (x.Nov == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Nov>"
                    }
                    else {
                        return "<input type='text' value=" + x.Nov + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Nov>"
                    }
                }
            },
            {
                title: "Dec", data: function (x) {
                    if (x.Dec == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Dec>"
                    }
                    else {
                        return "<input type='text' value=" + x.Dec + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Dec>"
                    }
                }
            },
            {
                title: "Jan", data: function (x) {
                    if (x.Jan == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jan>"
                    }
                    else {
                        return "<input type='text' value=" + x.Jan + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Jan>"
                    }
                }
            },
            {
                title: "Feb", data: function (x) {
                    if (x.Feb == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Feb>"
                    }
                    else {
                        return "<input type='text' value=" + x.Feb + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Feb>"
                    }
                }
            },
            {
                title: "Mar", data: function (x) {
                    if (x.Mar == null) {
                        return "<input type='text' onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Mar>"
                    }
                    else {
                        return "<input type='text' value=" + x.Mar + " onfocusout='updateforecast(this)' class='form-control input-sm' id=" + x.Year + "Mar>"
                    }
                }
            },
           
        ],

    });
}

function Yearspopulate() {
    var currentYear = (new Date()).getFullYear() + 5;
    var option = '<option hidden></option>';
    for (var i = 2020; i <= currentYear; i++) {
        option = '<option value="' + i + '">' +i+ '</option>';
        $('#Years').append(option);
    }
}

function updateforecast(d) {

    var theyear = $(d).attr('id').substring(0, 4);
    var data = {
          Year:$(d).attr('id').substring(0, 4),
          Apr:$("#"+theyear+"Apr").val(),
          May:$("#"+theyear+"May").val(),
          Jun:$("#"+theyear+"Jun").val(),
          Jul:$("#"+theyear+"Jul").val(),
          Aug:$("#"+theyear+"Aug").val(),
          Sep:$("#"+theyear+"Sep").val(),
          Oct:$("#"+theyear+"Oct").val(),
          Nov:$("#"+theyear+"Nov").val(),
          Dec:$("#"+theyear+"Dec").val(),
          Jan:$("#"+theyear+"Jan").val(),
          Feb:$("#"+theyear+"Feb").val(),
          Mar:$("#"+theyear+"Mar").val(),
    }

    $.ajax({
        url: '../ForecastSetting/Updateforecast',
        data:data,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            Initializepage();
            notify("Saved!", "Successfully Saved", "success");
        }
    });
}


function Initializepage2() {
    $('#Forecasttbls_pos').DataTable({
        ajax: {
            url: '../ForecastSetting/GetForecastPositionList',
            type: "POST",
            datatype: "json"
        },
        serverSide: "true",
        order: [0, "asc"],
        processing: "true",
        lengthChange: false,
        language: {
            "processing": "processing... please wait"
        },
        //dom: 'Bfrtip',
        destroy: true,
        columns: [
            { title: "Position", data: "Position" },
            { title: "Class(J)", data: "ClassJ" },
            { title: "Class(E)", data: "ClassE" },
            { title: "Unit", data: "Unit" },
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

    $('#Forecasttbls_pos tbody').on('click', '.btnedit', function () {

        var tabledata = $('#Forecasttbls_pos').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();

        $('#Position').val(data.Position);
        $('#ClassJ').val(data.ClassJ);
        $('#ClassE').val(data.ClassE);
        $('#Unit').val(data.Unit);
        $('#ID').val(data.ID);
    });

    $('#Forecasttbls_pos tbody').on('click', '.btndelete', function () {
        var tabledata = $('#Forecasttbls_pos').DataTable();
        var data = tabledata.row($(this).parents('tr')).data();
        $('#ID').val(data.UserName);
        Deletionheres('../ForecastSetting/DeleteForecast', data.ID, data.Position);

    });

}

function AddPosForecast(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../ForecastSetting/CreateForecastPos',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage2();
                //swal("Agency Saved");
                msg("Position Saved", "success");
            }
            else {
                swal("Position Already Exist");
            }

        }
    });
}

function EditPosForecast(data) {
    var datanow = data.serialize();
    $.ajax({
        url: '../ForecastSetting/EditForecastPos',
        data: datanow,
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            if (returnData.msg == "Success") {
                Initializepage2();
                //swal("Agency Saved");
                msg("Position Saved", "success");
            }
            else {
                swal("Position Already Exist");
            }

        }
    });
}