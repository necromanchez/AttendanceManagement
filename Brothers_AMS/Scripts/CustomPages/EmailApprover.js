(function () {
    $("#INN").click();
    $(".sidebar-mini").addClass("sidebar-collapse");
    $(".main-sidebar").hide();
    $(".sidebar-toggle").removeClass("sidebar-toggle");
    $(".navbar-custom-menu").hide();


    $(".logo-mini").on("click", function () {
        location.href = "/Home/Index";
    })





})();