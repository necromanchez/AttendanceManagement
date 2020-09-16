$(function () {

	var d1, d2, d3, d4,d5, data, chartOptions;

	d1 = [
		[1325376000000, 1200], [1328054400000, 700], [1330560000000, 1000], [1333238400000, 600],
		[1335830400000, 350]
	];

	d2 = [
		[1325376000000, 800], [1328054400000, 600], [1330560000000, 300], [1333238400000, 350],
		[1335830400000, 300]
	];

	d3 = [
		[1325376000000, 650], [1328054400000, 450], [1330560000000, 150], [1333238400000, 200],
		[1335830400000, 150]
	];
	d4 = [
		[1325376000000, 150], [1328054400000, 350], [1330560000000, 350], [1333238400000, 100],
		[1335830400000, 450]
	];
	d5 = [
		[1325376000000, 350], [1328054400000, 450], [1330560000000, 550], [1333238400000, 600],
		[1335830400000, 250]
	];

	data = [{
		label: 'Line A',
		data: d1
	}, {
	    label: 'Line B',
		data: d2
	}, {
	    label: 'Line C',
		data: d3
	},{
	    label: 'Line D',
		data: d4
	},{
	    label: 'Line E',
		data: d5
	}];

	chartOptions = {
		//xaxis: {
		//	min: (new Date(2011, 11, 15)).getTime(),
		//	max: (new Date(2012, 04, 18)).getTime(),
		//	mode: "time",
		//	tickSize: [1, "month"],
		//	monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
		//	tickLength: 0
		//},
		grid:{
      hoverable: true,
      clickable: false,
      borderWidth: 1,
      tickColor: '#eaeaea',
			borderColor: '#eaeaea',
    },
		series: {
			stack: true
		},
		bars: {
		show: true,
		barWidth: 36*24*60*60*300,
			fill: true,
			align: 'center',
			lineWidth: 1,
			lineWidth: 0,
			fillColor: { colors: [ { opacity: 1 }, { opacity: 1 } ] }
		},
		shadowSize: 0,
		tooltip: true,
		tooltipOpts: {
			content: '%s: %y'
		},
		colors: ['#3a86c8', '#64bd63', '#6dc6cd', '#52bf8a', '#638ca5'],
	}

	var holder = $('#stacked-vertical-chart2');

	if (holder.length) {
		$.plot(holder, data, chartOptions );
	}
});