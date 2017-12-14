package com.sirolf2009.trading

import com.sirolf2009.commonwealth.ITick
import com.sirolf2009.commonwealth.Tick
import com.sirolf2009.commonwealth.indicator.line.ILineIndicator
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import java.time.Duration
import java.util.ArrayList
import java.util.Calendar
import java.util.Collections
import java.util.Date
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.atomic.AtomicReference
import java.util.stream.Collectors
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.xtend.lib.annotations.Data
import org.swtchart.Chart
import org.swtchart.ILineSeries
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.ISeries.SeriesType
import org.swtchart.internal.series.BarSeries
import org.swtchart.internal.series.LineSeries

class SerenityChart extends Chart implements IExchangePart {

	public static val red = new Color(Display.^default, 255, 0, 0)
	public static val green = new Color(Display.^default, 0, 255, 0)
	public static val blue = new Color(Display.^default, 0, 0, 255)
	public static val white = new Color(Display.^default, 255, 255, 255)
	public static val black = new Color(Display.^default, 0, 0, 0)

	val orderbook = new AtomicReference<IOrderbook>
	val trades = Collections.synchronizedList(new ArrayList<ITrade>())
	val indicators = new ArrayList<Indicator>()

	new(Composite parent) {
		super(parent, SWT.NONE)
		backgroundInPlotArea = black
		title.foreground = white
		title.text = ""
		xAxis.tick.foreground = white
		xAxis.title.foreground = white
		xAxis.title.text = ""
		yAxis.tick.foreground = white
		yAxis.title.foreground = white
		yAxis.title.text = ""
		getOrderbook.subscribe [
			orderbook.set(it)
		]
		getTrades.subscribe [
			trades += it
		]
		val timer = new Timer()
		timer.scheduleAtFixedRate(new TimerTask() {
			override run() {
				if(disposed) {
					return
				}
				tick(new Date(scheduledExecutionTime))
			}
		}, getFirstRunTime(), getPeriod())
	}

	def addIndicator(ILineIndicator formula, Color color, String name) {
		return addIndicator(formula, color, name, new CircularFifoQueue<Date>(5000), new CircularFifoQueue<Double>(5000))
	}

	def addIndicator(ILineIndicator formula, Color color, String name, CircularFifoQueue<Date> xDates, CircularFifoQueue<Double> yValues) {
		return addIndicator(new Indicator(formula, createLineSeries(color, name), xDates, yValues))
	}

	def addIndicator(Indicator indicator) {
		indicators.add(indicator)
		return indicator
	}

	def xAxis(Chart chart) {
		return chart.axisSet.XAxes.get(0)
	}

	def yAxis(Chart chart) {
		return chart.axisSet.YAxes.get(0)
	}

	def tick(Date timestamp) {
		val currentTrades = trades.stream.collect(Collectors.toList())
		trades.clear()
		tick(new Tick(timestamp, orderbook.get(), currentTrades))
	}

	def tick(ITick tick) {
		indicators.forEach [
			try {
				val point = formula.apply(tick)
				xData.add(point.date)
				yData.add(point.y.doubleValue())
				line.XDateSeries = xData
				line.YSeries = yData
			} catch(Exception e) {
				e.printStackTrace()
			}
		]
		display.syncExec [
			axisSet.adjustRange()
			redraw()
		]
	}
	
	def createLineSeries(Chart chart, Color color, String name) {
		return chart.seriesSet.createSeries(SeriesType.LINE, name) as LineSeries => [
			symbolType = PlotSymbolType.NONE
			lineColor = color
		]
	}
	
	def createBarSeries(Chart chart, String name) {
		return chart.seriesSet.createSeries(SeriesType.BAR, name) as BarSeries
	}

	def getFirstRunTime() {
		val cal = Calendar.getInstance()
		cal.set(Calendar.MILLISECOND, 0)
		cal.set(Calendar.SECOND, cal.get(Calendar.SECOND) + 1)
		return cal.time
	}

	def getPeriod() {
		return Duration.ofSeconds(1).toMillis()
	}
	
	@Data static class Indicator {
		val ILineIndicator formula
		val ILineSeries line
		val CircularFifoQueue<Date> xData
		val CircularFifoQueue<Double> yData
		
	}

}
