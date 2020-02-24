
(function () {
    
    Dropdown_select('Section', "/Helper/GetDropdown_SectionAMS");

    $("#loading_modal").modal("show")
    $("#Section").on("change", Initializedpage);


    $("#INN").click();
    $(".sidebar-mini").addClass("sidebar-collapse");
    $(".main-sidebar").hide();
    $(".sidebar-toggle").removeClass("sidebar-toggle");
    $(".navbar-custom-menu").hide();

    Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeam");

    $(".logo-mini").on("click", function () {
        location.href = "/Home/Index";
    })
    SectionSelectuser();
    window.setInterval(function () {
        if (autorefresh) {
            Initializedpage();
        }
    }, 5000);

    $("#togBtn").on("click", function () {

        if (autorefresh) {
            autorefresh = false;
        }
        else {

            autorefresh = true;
        }
    })


    var clock = function () {
        clearTimeout(timer);

        date = new Date();
        hours = date.getHours();
        minutes = date.getMinutes();
        seconds = date.getSeconds();
        dd = (hours >= 12) ? 'PM' : 'AM';
        hours = (hours > 12) ? (hours - 12) : hours
        var timer = setTimeout(clock, 1000);
        var minut = (Math.floor(minutes) < 10) ? "0" + Math.floor(minutes) : Math.floor(minutes);
        $('#Timehere').html(Math.floor(hours) + ':' + minut + ' ' + dd)

        thetime = Math.floor(hours) + ':' + minut + ' ' + dd;
    };
    clock();

    var val = date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear();
    $('#datess').html(formatDate(new Date()))
    var delay = (function () {
        var timer = 0;
        return function (callback, ms) {
            clearTimeout(timer);
            timer = setTimeout(callback, ms);
        };
    })();

    $("#btnSearch").on("click", SearchEmployee);
    $("#btnGo").on("click", SearchEmployeeGo);

    $('#tabs').on('shown.bs.tab', function (event) {
        var x = $(event.target).text();         // active tab
        Shiftmode = x.trim();
        Initializedpage();
        //var y = $(event.relatedTarget).text();  // previous tab
        
    });
    
})();
var autorefresh = false;
var Shiftmode = "Day Shift";
function Initializedpage() {
    var sec = $("#Section").val();
    var secchosen = (sec == "") ? "Printer" : sec;
    $("#loading_modal").modal("show")
    $.ajax({
        url: '/LineView/GetLineperSection',
        type: 'GET',
        data: { Section: secchosen, Shift: Shiftmode },
        datatype: "json",
        success: function (returnData) {
            var theLineView = "";

            var SectionData = returnData.theLineList;
            console.log(SectionData);
            var groupedSection = _.mapValues(_.groupBy(SectionData, 'Section'),
                          clist => clist.map(Section => _.omit(Section, 'Section')));

            console.log(groupedSection);
            $.each(groupedSection, function (i, arrSection) {
                theLineView += "<div class='row'><div class='col-md-12'>"
                var groupedLine = _.mapValues(_.groupBy(arrSection, 'Line'),
                          clist => clist.map(Line => _.omit(Line, 'Line')));
                i = (i == "null") ? "" : i;
                //console.log(groupedLine);
                theLineView += "<div class='box box-solid'>" +
                                "        <div class='box-header with-border'>" +
                                "            <h3 class='box-title'>" + i + "</h3>" +

                                "        </div>" +
                                "        <div class='box-body'>";

                theLineView += "<div class='row'>";
                var idealcount = 0;
                $.each(groupedLine, function (ii, arrLine) {
                    var idmain = ii.replace(/[^A-Z0-9]/ig, "_");
                    var thecolor = (arrLine[0].CM == 0) ? "#DCDCDC" : "#AEDEFF";
                    theLineView += "<div class='col-md-3'>" +
                                                "    <div class='box-header with-border collapsed' style='background-color:" + thecolor + "'>" +
                                                "        <div class='box-header with-border collapsed' data-toggle='collapse' data-parent='#accordion' href='#" + idmain + "' aria-expanded='false'>" +
                                                "            <h3 class='box-title'>" + ii + "</h3>" +
                                                "            <h3 class='box-title' style='padding-left:1em'><i class='fa fa-users'></i> " + arrLine[0].CM + //": " + arrLine[0].SM + "</h3>" +
                                                "        </div>" +
                                                "        <div class='box-body collapse' id='" + idmain + "'>";
                    //console.log(ii, arrLine);
                    var ideal = arrLine[0];

                    var EmployeeperLine = ideal.Employeeperline;
                    var IdealMPperLine = ideal.IdealMPperLine;
                    var AccordionID = "";
                    //theLineView += "<div>" + IdealMPperLine[0].Skill + "</div>"

                    for (var x = 0; x < IdealMPperLine.length; x++) {
                        // console.log(IdealMPperLine[x].Skill);
                        IdealMPperLine[x].Skill = (IdealMPperLine[x].Skill == null) ? "NoName" + x + y : IdealMPperLine[x].Skill
                        //AccordionID = (x + y + IdealMPperLine[x].Skill).replace(/[^A-Z0-9]/ig, "_");
                        AccordionID = (IdealMPperLine[x].Skill).replace(/[^A-Z0-9]/ig, "_");
                        var coLure = (IdealMPperLine[x].CurrentCount == 0) ? "#DCDCDC" : "";
                        theLineView += "                <div class='panel box box-success' style='background-color:" + coLure + "'>" +
                                                "                    <div class='box-header with-border collapse'>" +
                                                "                        <h4 class='box-title'>" +
                                                "                            <a data-toggle='collapse' data-parent='#accordion' href='#collapse" + IdealMPperLine[x].ID + AccordionID + "' class='collapsed' aria-expanded='false'>" +
                                                  "                                " + IdealMPperLine[x].Skill + "" +
                                                "                                   <h3 class='box-title' style='padding-left:1em'><i class='fa fa-users'></i> " + IdealMPperLine[x].CurrentCount + ": " + IdealMPperLine[x].Count + "</h3>" +

                                                "                            </a>" +
                                                "                        </h4>" +
                                                "                    <div id='collapse" + IdealMPperLine[x].ID + AccordionID + "' class='panel-collapse collapse' class='collapsed' aria-expanded='false'>" +
                                                "                        <div class='box-body'>";
                        for (var y = 0; y < EmployeeperLine[x].length; y++) {
                            theLineView += "<table class='table table-responsive Blackislife'>" +
                                           "<tbody>";
                            var photo = "";
                            if (EmployeeperLine[x][y].EmployeePhoto != "" && EmployeeperLine[x][y].EmployeePhoto != null) {
                                photo = "/PictureResources/EmployeePhoto/" + EmployeeperLine[x][y].EmployeePhoto;
                            }
                            else {
                                photo = '/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg';
                            }
                            var idred = (EmployeeperLine[x][y].Skill == null) ? "style='color:red'" : "";
                            var EmpName = (EmployeeperLine[x][y].EmployeeName != null) ? EmployeeperLine[x][y].EmployeeName.replace(/[^A-Z0-9]/ig, "") : "";
                            theLineView += "<tr id=" + EmpName + "rmv>" +
                                            "<td class='photohere'>" + "<img class='direct-chat-img' src=" + photo + " alt='Message User Image'></td>" +
                                            "<td align='left'" + idred + ">" +
                                            "<label style='font-weight:bold !important;font-size:16px !important;'>" + EmployeeperLine[x][y].Position + "</label>" +
                                            "<br>" +
                                            "<label style='font-size:16px !important;' id=" + EmployeeperLine[x][y].EmployeeName + ">" + EmployeeperLine[x][y].EmployeeName + "" +

                                            "</td>" +
                                             "<td class='btnremovehere'>";

                            theLineView += "<button class='btn btn-google' onclick=RemoveThisEmployee('" + EmpName + "')><i class='fa fa-close'></i></button></label>" +
                             "</td>" +
                       "</tr>";
                            theLineView += "</tbody>" +
                                           "</table>";
                        }

                        theLineView += "</div></div></div></div>";
                    }
                    theLineView += "</div></div></div>";


                });

                theLineView += "</div></div>";
                theLineView += "</div></div></div>";
            })

            $("#theLineView").html("");
            $("#theLineView_Night").html("");
            
            
            if (Shiftmode.trim() == "Day Shift") {
                $("#theLineView").html(theLineView);
            }
            else {
                $("#theLineView_Night").html(theLineView);

            }

            $("#loading_modal").modal("hide")

        }
    });
}

function RemoveThisEmployee(name) {

    $.ajax({
        url: '/LineView/RemoveEmployee',
        type: 'GET',
        datatype: "json",
        data: {
            Name: name
        },
        success: function (returnData) {

            notify("Saved!", "Employee Removed", "success");
            $("#" + name + "rmv").remove();
        }

    });


    //alert(id);
}

function formatDate(date) {
    var monthNames = [
      "January", "February", "March",
      "April", "May", "June", "July",
      "August", "September", "October",
      "November", "December"
    ];

    var day = date.getDate();
    var monthIndex = date.getMonth();
    var year = date.getFullYear();

    return monthNames[monthIndex] + ' ' + day + ', ' + year;
}

function SectionSelectuser() {
    $.ajax({
        url: '/LineView/GetCurrentUser',
        type: 'GET',
        datatype: "json",
        success: function (returnData) {
            $("#Section").val(returnData.SectionGroup);
            Initializedpage();
        }
    });
}

function getEmployeeName() {
    var options = '';
    var datas = document.getElementsByName("EmployeeNo")[0].value;
    if (datas == "" || datas == null || datas == undefined) {
        partnoval = ""
    }
    var data = {
        partnofilter: datas
    }
    $.ajax({
        url: '/LineView/GetEmployeeName',
        type: 'GET',
        datatype: "json",
        loadonce: true,
        data: {
            Name: $("#EmployeeNo").val()
        },
        success: function (returnData) {
            // console.log(returnData);
            options = "";
            if (returnData.list.length > 5) {
                l = 5;
            }
            else {
                l = returnData.list.length;
            }
            for (var i = 0; i < l; i++) {
                options += '<option value="' + returnData.list[i].EmployeeName + '" />';
            }
            $("#EmployeeNoList").empty().append(options);
            document.getElementById('EmployeeNoList').innerHTML = options;


        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function SearchEmployee() {
    $.ajax({
        url: '/LineView/GetTimeInlocation',
        type: 'GET',
        datatype: "json",
        data: {
            Name: $("#EmployeeNo").val()
        },
        success: function (returnData) {
            var s = $("#EmployeeNo").val().replace(/[^A-Z0-9]/ig, "");
            $("#" + s + "rmv").css('backgroundColor', '#F9FF9A');

            $('#linehere').text("Line: " + returnData.Employee.Line);
            $('#processhere').text("Process: " + returnData.Employee.Skill);
            $('#Shifthere').text("Shift: " + returnData.Employee.Schedule);


            var Certified = (returnData.Employee.Certified != null) ? "Certified" : "Uncertified";
            $('#Cerhere').text("Certified: " + Certified);
            if (Certified == "Uncertified") {
                $("#Cerhere").css('backgroundColor', '#FFA4A4');
            }
            else {
                $("#Cerhere").css('backgroundColor', '#83FB90');
            }

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function SearchEmployeeGo() {
    $.ajax({
        url: '/LineView/GetTimeInlocation',
        type: 'GET',
        datatype: "json",
        data: {
            Name: $("#EmployeeNo").val()
        },
        success: function (returnData) {
            var s = $("#EmployeeNo").val().replace(/[^A-Z0-9]/ig, "");
            $("#" + s + "rmv").css('backgroundColor', '#F9FF9A');
            $("#" + returnData.Employee.Line.replace(/[^A-Z0-9]/ig, "_")).removeClass(" box-body collapse");
            $("#" + returnData.Employee.Line.replace(/[^A-Z0-9]/ig, "_")).addClass("box-body collapse show");


            $("#collapse" + returnData.Employee.ProcessID + returnData.Employee.Skill.replace(/[^A-Z0-9]/ig, "_")).removeClass(" box-body collapse");
            $("#collapse" + returnData.Employee.ProcessID + returnData.Employee.Skill.replace(/[^A-Z0-9]/ig, "_")).addClass("box-body collapse show");
            var elmnt = document.getElementById(returnData.Employee.Line.replace(/[^A-Z0-9]/ig, "_"));
            elmnt.scrollIntoView();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}