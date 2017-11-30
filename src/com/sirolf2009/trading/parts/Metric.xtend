package com.sirolf2009.trading.parts

import java.text.SimpleDateFormat
import java.util.Date
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Data
import org.swtchart.Chart
import org.swtchart.internal.series.LineSeries

abstract class Metric extends UpdatingChartPart<MetricPoint> {

	var Chart chart
	var LineSeries series

	def void init(Composite parent, String name) {
		chart = createChart(parent)
		chart.xAxis.tick.format = new SimpleDateFormat("HH:mm:ss")
		series = chart.createMetricSeries(name)
		init(chart, name)
	}
	
	override get() {
		return new MetricPoint(measure(), new Date())
	}
	def Double measure()
	
	override setData(Chart chart, CircularFifoQueue<MetricPoint> buffer) {
		series.XDateSeries = buffer.map[time]
		series.YSeries = buffer.map[value]
		chart.axisSet.adjustRange()
	}
	
	override isValid(MetricPoint t) {
		return t !== null && t.value !== null && !t.value.isNaN
	}

	def createMetricSeries(Chart chart, String name) {
		chart.createLineSeries(name) => [
			visibleInLegend = false
		]
	}
	
	override createBuffer() {
		return new CircularFifoQueue<MetricPoint>(500)
	}

	def getChart() {
		return chart
	}

	def getSeries() {
		return series
	}

}

@Data class MetricPoint {
	Double value
	Date time
}
