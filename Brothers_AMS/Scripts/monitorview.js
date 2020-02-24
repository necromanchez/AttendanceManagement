

$(document).ready(function () {

    //setInterval(function () {
    update();
    //}, 500);

});

function update() {

    $.ajax({
        url: '../../MonitorAccess/DashboardData',
        type: "GET",
        contentType: "application/json; charset=utf-8",
        cache: false,
        //processing: true,
        dataType: "json",
        beforeSend: function () {
            $("#loading_modal").modal("show");
        },
        success: function (returndata) {

            for (var x = 0; x < returndata.upperData.length; x++) {

                if (returndata.upperData[x].MaterialCategory.trim() == "MAT0001") {
                    $("#PIM_StockCount").text(returndata.upperData[x].StockCount);
                    $("#PIM_StockCost").text(returndata.upperData[x].StockCost);
                    $("#PIM_BelowMinimum").text(returndata.upperData[x].BelowMinumum);
                    $("#PIM_AboveMaximum").text(returndata.upperData[x].AboveMaximum);
                    $("#PIM_BelowSafety").text(returndata.upperData[x].BelowSafety);
                }
                else if (returndata.upperData[x].MaterialCategory.trim() == "MAT0002") {
                    $("#MIM_StockCount").text(returndata.upperData[x].StockCount);
                    $("#MIM_StockCost").text(returndata.upperData[x].StockCost);
                    $("#MIM_BelowMinimum").text(returndata.upperData[x].BelowMinumum);
                    $("#MIM_AboveMaximum").text(returndata.upperData[x].AboveMaximum);
                    $("#MIM_BelowSafety").text(returndata.upperData[x].BelowSafety);
                }
                else if (returndata.upperData[x].MaterialCategory.trim() == "MAT0003") {
                    $("#PNJ_StockCount").text(returndata.upperData[x].StockCount);
                    $("#PNJ_StockCost").text(returndata.upperData[x].StockCost);
                    $("#PNJ_BelowMinimum").text(returndata.upperData[x].BelowMinumum);
                    $("#PNJ_AboveMaximum").text(returndata.upperData[x].AboveMaximum);
                    $("#PNJ_BelowSafety").text(returndata.upperData[x].BelowSafety);
                }
            }




            for (var x = 0; x < returndata.tableData.length; x++) {
                $("#pim_prevlast6").text(returndata.tableData[x].PrevLast6Name)
                $("#pim_prevlast5").text(returndata.tableData[x].PrevLast5Name)
                $("#pim_prevlast4").text(returndata.tableData[x].PrevLast4Name)
                $("#pim_prevlast3").text(returndata.tableData[x].PrevLast3Name)
                $("#pim_prevlast2").text(returndata.tableData[x].PrevLast2Name)
                $("#pim_prevlast1").text(returndata.tableData[x].PrevLast1Name)

                $("#mim_prevlast6").text(returndata.tableData[x].PrevLast6Name)
                $("#mim_prevlast5").text(returndata.tableData[x].PrevLast5Name)
                $("#mim_prevlast4").text(returndata.tableData[x].PrevLast4Name)
                $("#mim_prevlast3").text(returndata.tableData[x].PrevLast3Name)
                $("#mim_prevlast2").text(returndata.tableData[x].PrevLast2Name)
                $("#mim_prevlast1").text(returndata.tableData[x].PrevLast1Name)

                $("#pnj_prevlast6").text(returndata.tableData[x].PrevLast6Name)
                $("#pnj_prevlast5").text(returndata.tableData[x].PrevLast5Name)
                $("#pnj_prevlast4").text(returndata.tableData[x].PrevLast4Name)
                $("#pnj_prevlast3").text(returndata.tableData[x].PrevLast3Name)
                $("#pnj_prevlast2").text(returndata.tableData[x].PrevLast2Name)
                $("#pnj_prevlast1").text(returndata.tableData[x].PrevLast1Name)
            }
            var colorPallete = ["#e53935", "#d81b60", "#8e24aa", "#5e35b1", "#3949ab", "#1e88e5", "#039be5", "#00acc1", "#00897b", "#43a047", "#7cb342", "#c0ca33", "#fdd835", "#ffb300", "#fb8c00", "#f4511e", "#8d6e63", "#bdbdbd", "#78909c", "#263238"]
            var PIM_table = '';
            var MIM_table = '';
            var PNJ_table = '';
            var PIM_count = 1;
            var MIM_count = 1;
            var PNJ_count = 1;
            $('#PIM_table_body').html('');
            $('#MIM_table_body').html('');
            $('#PNJ_table_body').html('');
            var PIMdonutData = [];
            var MIMdonutData = [];
            var PNJdonutData = [];

            for (var x = 0; x < returndata.tableData.length; x++) {

                if (returndata.tableData[x].MaterialCategory.trim() == "MAT0001" && PIM_count <= 20) {
                    if (PIM_count <= 20) {
                        PIM_table += "<tr>";
                        //PIM_table += " <td bgcolor=" + colorPallete[x] + ">TOP " + PIM_count + "</td>";
                        PIM_table += " <td>TOP " + PIM_count + "</td>";
                        PIM_table += " <td>" + returndata.tableData[x].ItemCode + "</td>";
                        PIM_table += " <td>" + returndata.tableData[x].ItemName + " / " + returndata.tableData[x].Specification + "</td>";
                        PIM_table += " <td class='text-center'>" + returndata.tableData[x].UOM + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast6Month + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast5Month + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast4Month + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast3Month + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast2Month + "</td>";
                        PIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast1Month + "</td>";
                        PIM_table += " <td class='text-center'>" + returndata.tableData[x].UnitPrice + "</td>";
                        PIM_table += "</tr>";


                        var PIMCHART = {
                            label: returndata.tableData[x].ItemCode,
                            data: returndata.tableData[x].MonthlyAverage * 1.0000,
                            color: colorPallete[x]
                        }

                        PIMdonutData.push(PIMCHART);
                        //PIMdontDataEval.push(PIMdonutData);
                    }
                    PIM_count++;
                }
                else if (returndata.tableData[x].MaterialCategory.trim() == "MAT0002" && MIM_count <= 20) {
                    if (MIM_count <= 20) {
                        MIM_table += "<tr>";
                        MIM_table += " <td>TOP " + MIM_count + "</td>";
                        MIM_table += " <td>" + returndata.tableData[x].ItemCode + "</td>";
                        MIM_table += " <td>" + returndata.tableData[x].ItemName + "'/'" + returndata.tableData[x].Specification + "</td>";
                        MIM_table += " <td class='text-center'>" + returndata.tableData[x].UOM + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast6Month + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast5Month + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast4Month + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast3Month + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast2Month + "</td>";
                        MIM_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast1Month + "</td>";
                        MIM_table += " <td class='text-center'>" + returndata.tableData[x].UnitPrice + "</td>";
                        MIM_table += "</tr>";

                        var MIMCHART = {
                            label: returndata.tableData[x].ItemCode,
                            data: returndata.tableData[x].MonthlyAverage * 1.0000,
                            color: colorPallete[x]
                        }

                        MIMdonutData.push(MIMCHART);
                    }
                    MIM_count++;
                }
                else if (returndata.tableData[x].MaterialCategory.trim() == "MAT0003" && PNJ_count <= 20) {
                    if (PNJ_count <= 20) {
                        PNJ_table += "<tr>";
                        PNJ_table += " <td>TOP " + PNJ_count + "</td>";
                        PNJ_table += " <td>" + returndata.tableData[x].ItemCode + "</td>";
                        PNJ_table += " <td>" + returndata.tableData[x].ItemName + "'/'" + returndata.tableData[x].Specification + "</td>";
                        PNJ_table += " <td class='text-center'>" + returndata.tableData[x].UOM + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast6Month + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast5Month + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast4Month + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast3Month + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast2Month + "</td>";
                        PNJ_table += " <td class='text-right'>" + returndata.tableData[x].PrevLast1Month + "</td>";
                        PNJ_table += " <td class='text-center'>" + returndata.tableData[x].UnitPrice + "</td>";
                        PNJ_table += "</tr>";

                        var PNJCHART = {
                            label: returndata.tableData[x].ItemCode,
                            data: returndata.tableData[x].MonthlyAverage * 1.0000,
                            color: colorPallete[x]
                        }

                        PNJdonutData.push(PNJCHART);
                    }
                    PNJ_count++;
                }


            }
            $('#PIM_table_body').append(PIM_table);
            $('#MIM_table_body').append(MIM_table);
            $('#PNJ_table_body').append(PNJ_table);

            //Chart PIM


            $.plot('#donut-chart', PIMdonutData, {
                series: {
                    pie: {
                        show: true
                    }
                }
                ,
                legend: {
                    show: false
                }
            });
            $.plot('#donut-chart2', MIMdonutData, {
                series: {
                    pie: {
                        show: true
                    }
                }
                ,
                legend: {
                    show: false
                }
            });
            $.plot('#donut-chart3', PNJdonutData, {
                series: {
                    pie: {
                        show: true
                    }
                }
                ,
                legend: {
                    show: false
                }
            });


            //



            $("#loading_modal").modal("hide");
        }


    });

}

function labelFormatter(label, series) {
    console.log(label);
    return '<div style="font-size:13px; text-align:center; padding:2px; color: #fff; font-weight: 600;">'
      + label
      + '<br>'
      + Math.round(series.percent) + '%</div>'
}