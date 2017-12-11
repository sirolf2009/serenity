package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import com.sirolf2009.trading.IExchangePart
import java.util.Date
import java.util.HashMap
import java.util.List
import java.util.concurrent.TimeUnit
import java.util.stream.Collectors
import java.util.stream.IntStream
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.apache.commons.math3.analysis.polynomials.PolynomialFunction
import org.apache.commons.math3.fitting.PolynomialCurveFitter
import org.apache.commons.math3.fitting.WeightedObservedPoint
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.swtchart.Chart
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.LineStyle
import org.swtchart.Range
import org.swtchart.internal.series.LineSeries

class OrderbookHistory extends ChartPart implements IExchangePart {

	var Chart chart

	val bufferSize = 5000
	val bidBuffer = new CircularFifoQueue<Double>(bufferSize)
	val askBuffer = new CircularFifoQueue<Double>(bufferSize)
	val volumeBuffer = new CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>>(bufferSize)

	val savedColors = new HashMap<Long, Color>()
	val colors = #[
		new Color(null, 0, 0, 255),
		new Color(null, 0, 255, 255),
		new Color(null, 0, 255, 0),
		new Color(null, 255, 255, 0),
		new Color(null, 255, 0, 0)
	]
	val largeVolume = 50
	val stepSize = largeVolume / colors.size() - 1

	var LineSeries bid
	var LineSeries ask
	var LineSeries volume

	var zoomY = 100

	@PostConstruct
	override createPartControl(Composite parent) {
		chart = parent.createChart() => [
			yAxis.title.text = "Price"
			addMouseWheelListener[
				zoomY += count / 3
				val mid = (bidBuffer.last() + askBuffer.last()) / 2
				chart.yAxis.range = new Range(mid - (mid / zoomY), mid + (mid / zoomY))
				chart.redraw()
			]
		]
		bid = chart.createLineSeries("Bid")
		bid.symbolType = PlotSymbolType.NONE
		bid.lineWidth = 2
		bid.lineColor = green
		bid.enableStep(true)
		ask = chart.createLineSeries("Ask")
		ask.lineWidth = 2
		ask.lineColor = red
		ask.enableStep(true)
		volume = chart.createLineSeries("Volume")
		volume.visibleInLegend = false
		volume.lineStyle = LineStyle.NONE
		volume.symbolType = PlotSymbolType.SQUARE
		volume.symbolSize = 1

		orderbook.sample(1, TimeUnit.SECONDS).subscribe [
			if(chart.disposed) {
				return
			}
			if(it !== null) {
				receiveOrderbook(it)
			}
		]
	}

	def receiveOrderbook(IOrderbook it) {
		if(it !== null) {
			val now = new Date()
			bidBuffer.add(bids.get(0).price.doubleValue())
			askBuffer.add(asks.get(0).price.doubleValue())

			volumeBuffer.add(Pair.of(now, (bids.map[price.doubleValue() -> amount.doubleValue()] + asks.map[price.doubleValue() -> amount.doubleValue()]).toList()))
			val volumes = volumeBuffer.toList()
			val volumesX = volumeBuffer.parallelStream.flatMap [ tick |
				IntStream.range(0, tick.value.size()).parallel().mapToObj[volumes.toList.indexOf(tick).doubleValue]
//						IntStream.range(0, tick.value.size()).parallel().mapToObj[
//							tick.key
//						]
			].collect(Collectors.toList())
			val volumesY = volumeBuffer.parallelStream.flatMap [ tick |
				tick.value.parallelStream.map[key]
			].collect(Collectors.toList())
			val volumesColor = volumeBuffer.parallelStream.flatMap [ tick |
				tick.value.parallelStream.map[Math.abs(value)].map [
					getGradient(longValue)
				]
			].collect(Collectors.toList())
			if(chart.disposed) {
				return
			}
			chart.display.syncExec [
				if(chart.disposed) {
					return
				}
				bid.YSeries = bidBuffer
				ask.YSeries = askBuffer
				volume.XSeries = volumesX
				volume.YSeries = volumesY
				volume.symbolColors = volumesColor
//				chart.xAxis.range = new Range(0, bidBuffer.size())
//				val mid = (bids.get(0).price.doubleValue() + asks.get(0).price.doubleValue()) / 2
//				chart.yAxis.range = new Range(mid - (mid / zoomY), mid + (mid / zoomY))
				chart.axisSet.adjustRange()
				chart.redraw()
			]
		} else {
			System.err.println("Orderbook is null")
		}
	}

	def getGradient(Long it) {
		if(!savedColors.containsKey(it)) {
			val c1 = colors.get(Math.max(Math.min((it / stepSize).intValue, colors.size() - 1), 0))
			val c2 = colors.get(Math.max(Math.min((it / stepSize + 1).intValue, colors.size() - 1), 0))
			val amt = it % stepSize / stepSize

			val r1 = c1.red
			val g1 = c1.green
			val b1 = c1.blue
			val r2 = c2.red
			val g2 = c2.green
			val b2 = c2.blue

			savedColors.put(it, new Color(chart.display, Math.round(r1 + (r2 - r1) * amt).intValue, Math.round(g1 + (g2 - g1) * amt).intValue, Math.round(b1 + (b2 - b1) * amt).intValue))
		}
		return savedColors.get(it)
	}

	def static fit(CircularFifoQueue<Double> buffer) {
		return fit(buffer, 2)
	}

	def static fit(CircularFifoQueue<Double> buffer, int degree) {
		return fit(buffer.toList(), degree)
	}

	def static fit(List<Double> trades, int degree) {
		val fitter = PolynomialCurveFitter.create(degree)
		val points = trades.map[new WeightedObservedPoint(1, trades.indexOf(it), it)].toList()
		val coeffecs = fitter.fit(points)
		val func = new PolynomialFunction(coeffecs)
		(0 ..< trades.size()).map[func.value(it)].toList()
	}

	@Focus
	override setFocus() {
		chart.setFocus()
	}

}
