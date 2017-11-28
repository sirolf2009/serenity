package com.sirolf2009.trading.parts

import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.swtchart.Chart
import org.swtchart.internal.series.LineSeries

abstract class Metric extends ChartPart {

	var Chart chart
	var LineSeries series
	var CircularFifoQueue<Double> buffer

	def void init(Composite parent, String name) {
		chart = createChart(parent)
		series = chart.createMetricSeries(name)
		buffer = createMetricBuffer()
		new Thread([
			while(true) {
				Thread.sleep(1000)
				if(chart.disposed) {
					return
				}
				update(parent.display)
			}
		], name + " updater").start()
	}

	def update(Display display) {
		val newValue = get()
		if(!newValue.naN) {
			buffer.add(newValue)
			display.syncExec [
				if(chart.disposed) {
					return
				}
				series.YSeries = buffer
				chart.axisSet.adjustRange()
				chart.redraw()
			]
		}
	}
	
	def abstract Double get()

	def createMetricSeries(Chart chart, String name) {
		chart.createLineSeries(name) => [
			visibleInLegend = false
		]
	}

	def createMetricBuffer() {
		return new CircularFifoQueue<Double>(500)
	}
	
	def getChart() {
		return chart
	}
	
	def getSeries() {
		return series
	}
	
	def getBuffer() {
		return buffer
	}

}
