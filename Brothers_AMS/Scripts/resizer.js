//[ORIGINAL]
//var currHeight = 0;
//window.addEventListener("orientationchange", function () {
//    resizeHeight(true);
//});

//window.onresize = function(event) {
//    resizeHeight(true);
//};
//function resizeHeight(resize) {
//    var htmlHeight = $(window).height();
//    if(htmlHeight > 598){
//        var docwidth = $(window).width();
//        var contentHeight = $(".content-wrapper").height();
//        var currHeight = (htmlHeight - 102);
//        var modalHeight = 500;
//        if (docwidth <= 767) {
//            currHeight = (htmlHeight - 150);
//            $(".sidebar-toggle").trigger("click");
//            $(".sidebar-toggle").trigger("click");
//        }
//        if (resize) {
//            $(".content-wrapper").css('min-height', currHeight + "px");
//        }
//        modalHeight = screen.height * .65;
//        console.log(screen.height);
//        $(".fixed-modal-height").css('height', modalHeight + "px");
//        $(".fixed-modal-height").css('overflow-y', "auto");
//    }
//}
//$(".sidebar-toggle").click(function () {
//    resizeHeight(true);
//});
//[ORIGINAL END]

var currHeight = 0;
//window.addEventListener("orientationchange", function () {
//    resizeHeight(true);
//});

//window.onresize = function (event) {
//    resizeHeight(true);
//};
function resizeHeight(resize) {
    var htmlHeight = $(window).height();
    if (htmlHeight > 598) {
        var docwidth = $(window).width();
        var contentHeight = $(".content-wrapper").height();
        var currHeight = (htmlHeight - 102);
        var modalHeight = 500;
        if (docwidth <= 767) {
            currHeight = (htmlHeight - 150);
            $(".sidebar-toggle").trigger("click");
            $(".sidebar-toggle").trigger("click");
        }
        if (resize) {
            $(".content-wrapper").css('min-height', currHeight + "px");
        }
        modalHeight = screen.height * .65;
        console.log(screen.height);
        $(".fixed-modal-height").css('height', modalHeight + "px");
        $(".fixed-modal-height").css('overflow-y', "auto");
    }
}
function resizeTextLabel(divId) {
    var maxWidth = 0;
    var myWidth = "";
    $(divId).ready(function () {
        $(divId + ".input-group-addon:not(.resized)").each(function (index) {
            myWidth = $(this).width();
            console.log("My Width: " + myWidth);
            if (myWidth > maxWidth) {
                maxWidth = myWidth;
            }
        });
        console.log("New Width: " + maxWidth);
        $(divId + ".input-group-addon:not(.resized)").css("width", maxWidth + 20 + "px");
        $(divId + ".input-group-addon:not(.resized)").addClass("resized");
    });
}
//$(".sidebar-toggle").click(function () {
//    resizeHeight(true);
//});
$("document").ready(function () {
    $(".nav-tabs>li>a").click(function () {
        var divId = $(this).attr("href") + " ";
        setTimeout(resizeTextLabel(divId), 1000);
    });
    $(".treeview").click(function () {
        resizeHeight(true);
    });

    var divId = "";
    if ($(".nav-tabs>li>a.active").length) {
        divId = $(".nav-tabs>li>a.active").attr("href") + " ";
        resizeTextLabel(divId);
    } else {
        if ($(".div-text-resize").length) {
            $(".div-text-resize").each(function (index) {
                var divId = "#" + this.id + " ";
                resizeTextLabel(divId);
            });
        } else {
            resizeTextLabel("");
        }
    }

});
