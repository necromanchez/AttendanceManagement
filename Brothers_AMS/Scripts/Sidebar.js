$(function () {
    var str = location.href.toLowerCase();
    $("#themenu li a").each(function () {
        if (str.indexOf(this.href.toLowerCase()) > -1) {
            $(this).parent("li").addClass("active");
            $("#timin").removeClass("active menu-open");
            $("#liner").removeClass("active menu-open");
        }
    });

    var link = str.toLowerCase();
    var res = link.split("/");

    var page = "";
    switch (res[3]) {
        case "masters": page = "masters"
            break;
        case "correction": page = "correction"
            break;
        case "summary": page = "summary"
            break;
        case "forecast": page = "forecast"
            break;
    }

    //if (str.includes("masters")) {
    if (page == "masters") {
        $("li").removeClass("menu-open");
        $('#Mastermodule').addClass("menu-open");
        $("#Mastermodule").children().show();

        //if (str.includes("/employee/employee")) {
        if(res[4] == "employee" && res[5] == "employee"){
            $("#dashi").removeClass("active menu-open");
        }
    }
    //else if (str.includes("correction")) {
    if (page == "correction") {
        $("li").removeClass("menu-open");
        $('#Correctionmodule').addClass("menu-open");
        $("#Correctionmodule").children().show();
    }
    //else if (str.includes("summary")) {
    if (page == "summary") {
        $("li").removeClass("menu-open");
        $('#Summarymodule').addClass("menu-open");
        $("#Summarymodule").children().show();
    }
    if (page == "forecast") {
        $("li").removeClass("menu-open");
        $('#Forecastmodule').addClass("menu-open");
        $("#Forecastmodule").children().show();
    }
    $("#forecastSetting").removeClass("active menu-open");
    $("#timin").removeClass("active menu-open");
    $("#Logouthere").removeClass("active menu-open");

})