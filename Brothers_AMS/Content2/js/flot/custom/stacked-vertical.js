$(function () {

	var d1, d2, d3, data, chartOptions;

	d1 = [
		[1325376000000, 1200], [1328054400000, 700], [1330560000000, 1000], [1333238400000, 600],
		[1335830400000, 350],[1335830400000, 350]
	];

	d2 = [
		[1325376000000, 800], [1328054400000, 600], [1330560000000, 300], [1333238400000, 350],
		[1335830400000, 300],[1335830400000, 350]
	];

	

	data = [{
		label: 'Absent',
		data: d1
	}, {
		label: 'Present',
		data: d2
	}];

	chartOptions = {
		xaxis: {
			min: (new Date(2011, 11, 15)).getTime(),
			max: (new Date(2012, 04, 18)).getTime(),
			mode: "time",
			tickSize: [1, "month"],
			monthNames: ["Line A", "Line B", "Line C", "Line D", "Line E", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
			tickLength: 0
		},
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

	var holder = $('#stacked-vertical-chart');

	if (holder.length) {
		$.plot(holder, data, chartOptions );
	}
});