package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.util.Date
import java.util.HashMap
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import java.util.function.Function
import java.util.stream.Collectors
import java.util.stream.IntStream
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.knowm.xchange.dto.marketdata.OrderBook
import org.swtchart.Chart
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.LineStyle
import org.swtchart.Range

class OrderbookHistory extends ChartPart implements IExchangePart {

	var Chart chart

	@PostConstruct
	def void createPartControl(Composite parent) {
		chart = parent.createChart() => [
			yAxis.title.text = "Price"
		]
		val bufferSize = 500
		val bidBuffer = new CircularFifoQueue<Double>(bufferSize)
		val bid = chart.createLineSeries("Bid")
		bid.symbolType = PlotSymbolType.NONE
		bid.lineColor = green
		bid.enableStep(true)
		val askBuffer = new CircularFifoQueue<Double>(bufferSize)
		val ask = chart.createLineSeries("Ask")
		ask.lineColor = red
		ask.enableStep(true)
		val volumeBuffer = new CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>>(bufferSize)
		val volume = chart.createLineSeries( "Volume")
		volume.visibleInLegend = false
		volume.lineStyle = LineStyle.NONE
		volume.symbolType = PlotSymbolType.SQUARE
		volume.symbolSize = 1

		val savedColors = new HashMap<Long, Color>()
		val colors = #[
			new Color(parent.display, 0, 0, 255),
			new Color(parent.display, 0, 255, 255),
			new Color(parent.display, 0, 255, 0),
			new Color(parent.display, 255, 255, 0),
			new Color(parent.display, 255, 0, 0)
		]
		val largeVolume = 20
		val stepSize = largeVolume / colors.size() - 1
		val Function<Long, Color> getGradient = [
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

				savedColors.put(it, new Color(parent.display, Math.round(r1 + (r2 - r1) * amt).intValue, Math.round(g1 + (g2 - g1) * amt).intValue, Math.round(b1 + (b2 - b1) * amt).intValue))
			}
			return savedColors.get(it)
		]

		val latestOrderbook = new AtomicReference<OrderBook>()
		orderbook.subscribe [
			if(chart.disposed) {
				return
			}
			latestOrderbook.set(it)
		]
		new Thread [
			while(true) {
				Thread.sleep(1000)
				if(chart.disposed) {
					return
				}
				val it = latestOrderbook.get()
				if(it !== null) {
					val now = new Date()
					bidBuffer.add(bids.get(0).limitPrice.doubleValue())
					askBuffer.add(asks.get(0).limitPrice.doubleValue())
					volumeBuffer.add(Pair.of(now, (bids.filter[remainingAmount.doubleValue >= 1].map[limitPrice.doubleValue() -> remainingAmount.doubleValue()] + asks.filter[remainingAmount.doubleValue <= -1].map[limitPrice.doubleValue() -> remainingAmount.doubleValue()]).toList()))
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
							getGradient.apply(longValue)
						]
					].collect(Collectors.toList())
					parent.display.syncExec [
						if(chart.disposed) {
							return
						}
						bid.YSeries = bidBuffer
						ask.YSeries = askBuffer
						volume.XSeries = volumesX
						volume.YSeries = volumesY
						volume.symbolColors = volumesColor
						chart.xAxis.adjustRange()
//						chart.yAxis.adjustRange()
						val mid = (bids.get(0).limitPrice.doubleValue()+asks.get(0).limitPrice.doubleValue())/2
						chart.yAxis.range = new Range(mid-(mid/100), mid+(mid/100))
						chart.redraw()
					]
				} else {
					System.err.println("Orderbook is null")
				}
			}
		].start()
	}

	@Focus
	def void setFocus() {
		chart.setFocus()
	}
	
}
