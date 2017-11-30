package com.sirolf2009.trading.parts

import java.time.Duration
import java.util.Calendar
import java.util.Timer
import java.util.TimerTask
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.swtchart.Chart

abstract class UpdatingChartPart<T> extends ChartPart {
	
	def void init(Chart chart, String name) {
		val buffer = createBuffer()
		val timer = new Timer(name)
		timer.scheduleAtFixedRate(new TimerTask() {
			override run() {
				if(chart.disposed) {
					return
				}
				update(chart, buffer)
			}
		}, getFirstRunTime(), getPeriod())
	}
	
	def update(Chart chart, CircularFifoQueue<T> buffer) {
		val newValue = get()
		if(newValue.valid) {
			buffer.add(newValue)
			chart.display.syncExec [
				if(chart.disposed) {
					return
				}
				setData(chart, buffer)
				chart.redraw()
			]
		}
	}
	
	def T get()
	def CircularFifoQueue<T> createBuffer()
	def void setData(Chart chart, CircularFifoQueue<T> buffer)
	
	def isValid(T t) {
		return true
	}
	
	def getFirstRunTime() {
        val cal = Calendar.getInstance()
        cal.set(Calendar.MILLISECOND, 0)
        cal.set(Calendar.SECOND, cal.get(Calendar.SECOND)+1)
        return cal.time
    }
    
    def getPeriod() {
    	return Duration.ofSeconds(1).toMillis()
    }
    
}