 var a = "";
var MYear, MAgency, MLine, MShift;
var Filter = {};

var Graph1 = false;
var Graph2 = false;
var Graph3 = false;
var Graph4 = false;
var Graph5 = false;

$(function () {
    $("#Sectiond").prop("disabled", true);
    $("#Departmentd").on("change", function () {
        
        $("#Sectiond").prop("disabled", false);  
        
    })
    $("#Bigchosen").val("Daily");
    //$("#BigchosenYear").prop("disabled", true);
    $("#BigchosenYear").val(GetYear());
    $("#Bigchosen").on("change", function () {
        if ($("#Bigchosen").val() == "Mon") {
            $("#BigchosenYear").prop("disabled", false);
            $("#ifyearly").hide();
        }
        else if ($("#Bigchosen").val() == "Yer") {
            $("#BigchosenYear").prop("disabled", true);
            $("#ifyearly").hide();
        }
        else {
            $("#ifyearly").show();
        }
        
        
        //else {
        //    GetUser();
        //}

    })
   
    MYear = $("#BigchosenYear").val();
    MAgency = $("#BIPH_Agency").val();
    MLine = $("#Line").val();
    MShift = $("#Shift").val();
    month = ($("#BigchosenMonth").val() != "") ? $("#BigchosenMonth").val() : month;

    Filter = {
        //Month: month,
        //Year: year,
        //Agency: agency,
        //Shift: '',
        //Line: line
        Month: month,
        Year: MYear,
        Agency: MAgency,
        Line: MLine,
        Shift: MShift,
        GroupSection: $("#Sectiond").val()

    }

    GetUser();
    
    Dropdown_selectYear("BigchosenYear");
    Dropdown_selectMonth("BigchosenMonth");
       
    
    Dropdown_selectD_all('BIPH_Agency', "/Helper/GetDropdown_Agency");
   

    Dropdown_selectD('MPA_BIPH_Agency', "/Helper/GetDropdown_Agency");
    //Dropdown_selectL('Sectiond', "/Helper/GetDropdown_SectionAMS?Dgroup=" + $("#Departmentd").val());
    //Dropdown_selectL('Departmentd', "/Helper/GetDropdown_DepartmentAMS");

    Dropdown_selectMPMain22('Sectiond', "/Helper/GetDropdown_SectionAMS?Dgroup=" + $("#Departmentd").val());
    Dropdown_selectMPMain_Dept('Departmentd', "/Helper/GetDropdown_DepartmentAMS");

    //Dropdown_select('Sectiond', "/Helper/GetDropdown_SectionAMS?Dgroup=" + $("#Departmentd").val());


    $("#Departmentd").on("change", function () {
      
        Dropdown_selectMPMain22('Sectiond', "/Helper/GetDropdown_SectionAMS?Dgroup=" + $("#Departmentd").val());

    });


    $("#Sectiond").on("change", function () {
        //$("#select2-Sectiond-container").text($("#Sectiond").val());
        Dropdown_selectD_Line('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=&RFID=" + "&GroupSection=" + $('#Sectiond').val());


    });

    $(".MPA").on("change", function () {
        month = ($("#MPA_Month").val() == "") ? month : $("#MPA_Month").val();
        year = ($("#MPA_Year").val() == "") ? year : $("#MPA_Year").val();
        agency = ($("#MPA_BIPH_Agency").val() == "") ? agency : $("#MPA_BIPH_Agency").val();
        line = ($("#MPA_Line").val() == "") ? agency : $("#MPA_Line").val();
        Filter = {
            Month: month,
            Year: year,
            Agency: agency,
            Line: line,
            Shift: $("#MPA_Shift").val()
        }
        GET_AttendanceRate();
    })



    $("#Generatenow").on("click", function () {
       
         Graph1 = false;
         Graph2 = false;
         Graph3 = false;
         Graph4 = false;
         Graph5 = false;
        $.ajax({
            url: '/Home/ChangeSection',
            type: 'POST',
            data: {
                Section: $("#Sectiond").val(),
                Department: $("#Departmentd").val() 
            },
            datatype: "json",
            success: function (returnData) {


                MYear = $("#BigchosenYear").val();
                MAgency = $("#BIPH_Agency").val();
                MLine = $("#Line").val();
                MShift = $("#Shift").val();
                month = ($("#BigchosenMonth").val() != "") ? $("#BigchosenMonth").val() : month;

                Filter = {
                    Month: month,
                    Year: MYear,
                    Agency: MAgency,
                    Line: MLine,
                    Shift: MShift,
                    GroupSection: $("#Sectiond").val(),
                    Department: $("#Departmentd").val()
                }


                if ($("#Departmentd").val() != "" && $("#Sectiond").val() == "") {
                    if ($("#Bigchosen").val() != "") {

                        MYear = $("#BigchosenYear").val();
                        MAgency = $("#BIPH_Agency").val();
                        MLine = $("#Line").val();
                        MShift = $("#Shift").val();

                        //$("#loading_modalD").modal("show");

                        if ($("#Bigchosen").val() == "Mon") {
                            MonthlyDashboard_Department();
                        }
                        else if ($("#Bigchosen").val() == "Yer") {
                            YearlyDashboard_Department();
                        }
                        else {
                            GET_AttendanceRate_Department();// GET_AttendanceRate();
                            AbsentRate_Department();
                            LeaveBreakDown_Department();
                            GetAWOLResignedRate_Department();
                            GetOvertimeRate_Department();
                        }
                    }
                    else {

                        GET_AttendanceRate_Department();//GET_AttendanceRate();
                        AbsentRate_Department();
                        LeaveBreakDown_Department();
                        GetAWOLResignedRate_Department();
                        GetOvertimeRate_Department();

                    }
                }
                else {
                    if ($("#Bigchosen").val() != "") {

                        MYear = $("#BigchosenYear").val();
                        MAgency = $("#BIPH_Agency").val();
                        MLine = $("#Line").val();
                        MShift = $("#Shift").val();

                        //$("#loading_modalD").modal("show");

                        if ($("#Bigchosen").val() == "Mon") {
                            MonthlyDashboard();
                        }
                        else if ($("#Bigchosen").val() == "Yer") {
                            YearlyDashboard();
                        }
                        else {
                            GET_AttendanceRate();
                            AbsentRate();
                            LeaveBreakDown();
                            GetAWOLResignedRate();
                            GetOvertimeRate();
                          
                        }
                    }
                    else {

                        GET_AttendanceRate();
                        AbsentRate();
                        LeaveBreakDown();
                        GetAWOLResignedRate();
                        GetOvertimeRate();
                      

                    }
                }
               
               



               
            }

        });

    })

});

var d = new Date();
var month = d.getMonth() + 1;
var year = d.getFullYear();
var agency = '';
var line = "";




function formatDate(day, month) {

    var monthNames = [
      "Jan", "Feb", "Mar",
      "Apr", "May", "Jun", "Jul",
      "Aug", "Sep", "Oct",
      "Nov", "Dec"
    ];

    return monthNames[month - 1] + "-" + day;// + ' ' + year;
}

function GetUser() {
    $.ajax({
        url: '/Helper/GetSection',
        type: 'POST',
        datatype: "json",
        success: function (returnData) {
            $('#Section').val(returnData.usersection);
            Dropdown_selectD_Line('Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            //Dropdown_select('MPA_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            //Dropdown_select('AR_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            //Dropdown_select('awol_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            //Dropdown_select('breakd_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());
            //Dropdown_select('overt_Line', "/Helper/GetDropdown_LineProcessTeamwithSection?CostCode=" + returnData.usercost + "&RFID=" + "&GroupSection=" + $('#Section').val());


            MYear = $("#BigchosenYear").val();
            MAgency = $("#BIPH_Agency").val();
            MLine = $("#Line").val();
            MShift = $("#Shift").val();
            month = ($("#BigchosenMonth").val() != "") ? $("#BigchosenMonth").val() : month;

         

            if (returnData.usersection != "" && returnData.usersection != null) {
                Filter = {
                    Month: month,
                    Year: MYear,
                    Agency: MAgency,
                    Line: MLine,
                    Shift: MShift,
                    GroupSection: returnData.usersection
                }
                //$("#Generatenow").trigger("click");
                //GET_AttendanceRate();
                //AbsentRate();
                //LeaveBreakDown();
                //GetAWOLResignedRate();
                //GetOvertimeRate();
            }
        }
    });
}


function GET_AttendanceRate() {
    $("#loading_modalD_AttendanceRate").modal("show");
    $.ajax({
        url: '/Home/GET_ManPowerAttendanceRate',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {
          
            GraphStart(returnData.list);
           
        }
    });
}

function GET_AttendanceRate_Department() {

    $("#loading_modalD_AttendanceRate").modal("show");
    $.ajax({
        url: '/Home/GET_ManPowerAttendanceRate_Department',
        type: 'POST',
        data: Filter,
        datatype: "json",
        success: function (returnData) {

            GraphStart(returnData.list);

        }
    });
}

function GraphStart(datahere) {
    var finalticks = [];
    var Present = [];
    //var PresentInactive = [];
    var MLCount = [];
    var NWCount = [];
    var Absent = [];
    var Percentage = [];
    var MonthDay = [];
    var Iterator = 1;
    var i = "";
    datahere.forEach(function (x) {
        var theday = parseInt(x.MonthDay);
        i = formatDate(theday, parseInt(month));
        var Tickshere = [Iterator, i];
        var Presentdata = [Iterator, x.Present];
        //var PresentInactivedata = [Iterator, x.PresentInactive];
        var MLCountdata = [Iterator, x.MLCount];
        var NWCountdata = [Iterator, x.NWCount];
        var Absentdata = [Iterator, x.Absent];
        var Percentdata = [Iterator, x.Percentage];
        MonthDay.push(x.MonthDay);
        Present.push(Presentdata);
        //PresentInactive.push(PresentInactivedata);
        MLCount.push(MLCountdata);
        NWCount.push(NWCountdata);
        Absent.push(Absentdata);
        Percentage.push(Percentdata);

        finalticks.push(Tickshere);
        Iterator++;
    });


    var data, chartOptions;
    var line_options = {
        show: true,
        lineWidth: 3,
        //fillColor: '#FF0000'
    }
    
    var bar_options = {
        show: true,
        align: 'center',
        lineWidth: 0,
        fill: true,
        barWidth: 0.5,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },
    };
    
    var PresentSet = {
        label: "Present",
        data: Present,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    //var PresentInactiveSet = {
    //    label: "Present Inactive",
    //    data: PresentInactive,
    //    bars: bar_options,
    //    fill: true,
    //    fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    //};
    var MLCountSet = {
        label: "ML Employee",
        data: MLCount,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    var NWCountSet = {
        label: "NW Employee",
        data: NWCount,
        bars: bar_options,
        fill: true,
        fillColor: { colors: [{ opacity: 1 }, { opacity: 1 }] },

    };
    var AbsentSet = {
        label: 'Absent',
        data: Absent,
        bars: bar_options
    }

    var totalSet = {
        label: 'Attendance Rate',
        data: Percentage,
        lines: line_options,
        points: {
            show: true,
            radius: 4,
            fill: true,
            fillColor: "#ffffff",
            lineWidth: 1
        },
        yaxis: 2,
        stack: false
    }

    var columncount = 0;
    var colored;
    var data = [];
    if ($("#Shift").val() == "Day" || $("#Shift").val() == "Night") {
        data.push(PresentSet);
        data.push(AbsentSet);
        data.push(MLCountSet);
        data.push(NWCountSet);
        //data.push(PresentInactiveSet);
        data.push(totalSet);
        columncount = 5;
        colored = ['#4E8EFF', '#FF6666', '#04B404', '#929495', 'red']
    }
    else {
        data.push(PresentSet);
        data.push(AbsentSet);
        data.push(MLCountSet);
        data.push(NWCountSet);
        data.push(totalSet);
        columncount = 5;
        colored = ['#4E8EFF', '#FF6666', '#04B404', '#929495', 'red']
       
    }



    //data = [PresentSet, AbsentSet, MLCountSet, NWCountSet, PresentInactiveSet, totalSet];
    //data = [PresentSet]
    var tickis = finalticks;//MonthDay;//finalticks2[0];
    function degreeFormatter(v, axis) {
        return v.toFixed(axis.tickDecimals) + "%";
    }
    chartOptions = {
        yaxes: [
               {
                   /* First y axis */
               },
               {
                   /* Second y axis */
                   position: "right",  /* left or right */
                   tick: {
                       format: function (d) {
                           return d + "%";
                       }
                   },
                   min: 0,
                   max: 100,
                   tickFormatter: degreeFormatter
               }
        ],
        xaxis: {
            ticks: tickis,
            rotateTicks: 90,

        },
        grid: {
            hoverable: true,
            clickable: false,
            borderWidth: 1,
            tickColor: '#eaeaea',
            borderColor: '#eaeaea',
        },
        series: {
            stack: true
        },
        shadowSize: 0,
        tooltip: true,
        tooltipOpts: {
            content: function (label, xval, yval, flotItem) {
                return '%s: %y'
            },
        },


        colors: colored,
        legend: {
            noColumns: columncount,
            container: $("#chartLegend")
        }
    }

    var holder = $('#ManpowerARtbl');

    if (holder.length) {
        var p = $.plot(holder, data, chartOptions);
        $.each(p.getData()[columncount-1].data, function (i, el) {
            var o = p.pointOffset({ x: i, y: el[1], yaxis: 2 });
           
            if (!isNaN(el[1])) {
                $('<div class="data-point-label">' + el[1].toFixed(0) + '%</div>').css({
                    position: 'absolute',
                    left: o.left+20,
                    top: o.top - 15,
                    display: 'none',
                    color: "red",
                }).appendTo(p.getPlaceholder()).fadeIn('slow');
            }
        });
    }

    Graph1 = true;

    if (Graph1 == true && Graph2 == true && Graph3 == true && Graph4 == true && Graph5 == true) {
        $("#loading_modalD_AttendanceRate").modal("hide");
    }
    



  

}


function Dropdown_selectMonth(id) {
    var option = '<option value="">--SELECT--' + getlongadj2() + '</option>';
    var monthArray = new Array();
    monthArray[1] = "January";
    monthArray[2] = "February";
    monthArray[3] = "March";
    monthArray[4] = "April";
    monthArray[5] = "May";
    monthArray[6] = "June";
    monthArray[7] = "July";
    monthArray[8] = "August";
    monthArray[9] = "September";
    monthArray[10] = "October";
    monthArray[11] = "November";
    monthArray[12] = "December";
    for (m = 1; m <= 12; m++) {
        option = '<option value="' + m + '">' + monthArray[m] + getlongadj2() + '</option>';
        $('#' + id).append(option);
    }
    $("#BigchosenMonth").val(GetMonth()).trigger('change');
}

function GetMonth() {
    var d = new Date();
    var n = d.getMonth() + 1;
    return n;
}

function Dropdown_selectYear(id) {
    var option = '<option value="">--SELECT--' + getlongadj2() + '</option>';
    $('#' + id).html(option);
    for (y = 2010; y <= 2500; y++) {

        option = '<option value="' + y + '">' + y + getlongadj2() + '</option>';
        $('#' + id).append(option);
    }
    $("#" + id).val(GetYear()).trigger('change');
}


function GetYear() {
    var d = new Date();
    var n = d.getFullYear();
    return n;
}