package com.sirolf2009.trading.parts

import java.text.SimpleDateFormat
import java.util.Date
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.swtchart.Chart
import org.swtchart.internal.series.LineSeries
import java.util.Timer
import java.util.TimerTask
import java.util.Calendar
import java.time.Duration

abstract class Metric extends ChartPart {

	var Chart chart
	var LineSeries series
	var CircularFifoQueue<Double> buffer
	var CircularFifoQueue<Date> dateBuffer

	def void init(Composite parent, String name) {
		chart = createChart(parent)
		chart.xAxis.tick.format = new SimpleDateFormat("HH:mm:ss")
		series = chart.createMetricSeries(name)
		buffer = createMetricBuffer()
		dateBuffer = createDateBuffer()
		val timer = new Timer(name)
		timer.scheduleAtFixedRate(new TimerTask() {
			override run() {
				if(chart.disposed) {
					return
				}
				update(parent.display)
			}
		}, getFirstRunTime(), getPeriod())
	}

	def update(Display display) {
		val newValue = get()
		if(!newValue.naN) {
			buffer.add(newValue)
			dateBuffer.add(new Date())
			display.syncExec [
				if(chart.disposed) {
					return
				}
				series.YSeries = buffer
				series.XDateSeries = dateBuffer
				chart.axisSet.adjustRange()
				chart.redraw()
			]
		}
	}

	def abstract Double get()
	
	def getFirstRunTime() {
        val cal = Calendar.getInstance()
        cal.set(Calendar.MILLISECOND, 0)
        cal.set(Calendar.SECOND, cal.get(Calendar.SECOND)+1)
        return cal.time
    }
    
    def getPeriod() {
    	return Duration.ofSeconds(1).toMillis()
    }

	def createMetricSeries(Chart chart, String name) {
		chart.createLineSeries(name) => [
			visibleInLegend = false
		]
	}

	def createMetricBuffer() {
		return new CircularFifoQueue<Double>(500)
	}

	def createDateBuffer() {
		return new CircularFifoQueue<Date>(500)
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
