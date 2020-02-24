
(function () {
    $("#INN").click();
    $(".sidebar-mini").addClass("sidebar-collapse");
    $(".main-sidebar").hide();
    $(".sidebar-toggle").removeClass("sidebar-toggle");
    $(".navbar-custom-menu").hide();

    Dropdown_select('Line', "/Helper/GetDropdown_LineProcessTeam");
   
    $(".logo-mini").on("click", function () {
        location.href = "/Home/Index";
    })
    
    window.setInterval(function () {
        Initializedpage();
    }, 2000);
   
})();

function Initializedpage() {
    $.ajax({
        url: '/LineView/GetLineperSection',
        type: 'GET',
        datatype: "json",
        success: function (returnData) {
            var theLineView = "";
            $("#theLineView").html('');
            var stater = true;
            for (var x = 0; x < returnData.theLineList.length; x++) {
               
                theLineView += "<div class='col-md-3'>" +
                                    "<div class='box box-success box-solid'>" +
                                        "<div class='box-header with-border'>" +
                                            "<h3 class='box-title'>" + returnData.theLineList[x].Line + "</h3>" +
                                            "<h3 class='box-title' style='padding-left:1em'><i class='fa fa-users'></i> " + returnData.theLineList[x].CM + ": " + returnData.theLineList[x].SM + "</h3>" +
                                            
                                            "<div class='box-tools pull-right'>" +
                                            "</div>" +
                                        "</div>" +
                                        "<div class='box-body' style='display: block;'>";
                                                    for (var y = 0; y < returnData.theLineList[x].IdealMPperLine.length; y++) {
                                                        stater = true;
                                                        theLineView += "<table class='table table-responsive Blackislife'>" +
                                                                                "<tbody>";
                                                                                //"<tr>" +
                                                                                //    "<th></th>" +
                                                                                //    "<th></th>" +
                                                                                //    "<th></th>" +
                                                                                //"</tr>";
                                                        for (var z = 0; z < returnData.theLineList[x].Employeeperline[y].length; z++) {
                                                            var photo = (returnData.theLineList[x].Employeeperline[y][z].EmployeePhoto != "") ? "/PictureResources/EmployeePhoto/" + returnData.theLineList[x].Employeeperline[y][z].EmployeePhoto + "" : '/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg';
                                                            var idred = (returnData.theLineList[x].Employeeperline[y][z].Skill == null) ? "style='color:red'" : "";

                                                        if (stater == true) {
                                                                    theLineView += "<tr>" +
                                                                                        "<td width='20%' style='text-align:center' rowspan='" + returnData.theLineList[x].Employeeperline[y].length + "' align='center'> " + returnData.theLineList[x].IdealMPperLine[y].Skill + " <br> " + returnData.theLineList[x].Employeeperline[y].length + " - " + returnData.theLineList[x].Employeeperline[y][z].IdealMP + "</td>" +
                                                                                        //"<td><img class='direct-chat-img' src='/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg' alt='Message User Image'></td>" +
                                                                                        "<td>"+ "<img class='direct-chat-img' src=" + photo + " alt='Message User Image'></td>" +

                                                                                        "<td align='left' " + idred + ">" +
                                                                                            returnData.theLineList[x].Employeeperline[y][z].Position + "-" +
                                                                                            returnData.theLineList[x].Employeeperline[y][z].EmployeeName +
                                                                                        "</td>" +
                                                                                    "</tr>";
                                                                    stater = false;
                                                        }
                                                        else {
                                                                    theLineView += "<tr>" +
                                                                                    //"<td><img class='direct-chat-img' src='/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg' alt='Message User Image'></td>" +
                                                                                    "<td>" + "<img class='direct-chat-img' src=" + photo + " alt='Message User Image'></td>" +
                                                                                    "<td align='left' " + idred + ">" +
                                                                                     returnData.theLineList[x].Employeeperline[y][z].Position + "-" + 
                                                                                         returnData.theLineList[x].Employeeperline[y][z].EmployeeName +
                                                                                    "</td>" +
                                                                                "</tr>";
                                                        }
                                                    }
                                               theLineView +=   "</tbody>" +
                                                                "</table>";
                                            }
                                            //for (var y = 0; y < returnData.theLineList[x].EmployeeList.length; y++) {
                                            //    var photo = (returnData.theLineList[x].EmployeeList[y].EmployeePhoto != "") ? "/PictureResources/EmployeePhoto/" + returnData.theLineList[x].EmployeeList[y].EmployeePhoto + "" : '/Content/images/2014-09-16-Anoynmous-The-Rise-of-Personal-Networks.jpg';
                                            //    var idred = (returnData.theLineList[x].EmployeeList[y].Skill == null) ? "<div class='direct-chat-text' style='color:red'>" : "<div class='direct-chat-text'>";

                                            //    theLineView += "<div class='direct-chat-msg right'>" +
                                            //                        "<img class='direct-chat-img' src=" + photo + " alt='Message User Image'>" +
                                            //                            idred +
                                                                            
                                                                       
                                            //                         "" + returnData.theLineList[x].EmployeeList[y].EmployeeName + " - " + returnData.theLineList[x].EmployeeList[y].Process +
                                            //                        "</div>" +
                                            //                    "</div>";
                                            //}
                                           
                theLineView+=          "</div>" +
                                    "</div>" +
                                "</div>";
            }

            $("#theLineView").append(theLineView);
        }
    });
}








