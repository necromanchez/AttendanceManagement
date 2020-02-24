$(document).ready(function () {
    
});
var bg = { "success": "#000000" };
function notify(heading, text, icon) {
    $.toast({
        heading: heading,
        text: text,
        position: 'top-right',
        loaderBg: bg.icon,
        icon: icon,
        //icon:"soso",
        hideAfter: 3500,
        stack: 6
    });
}