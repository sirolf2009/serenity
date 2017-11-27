package com.sirolf2009.trading.parts

import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import java.util.HashMap
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import java.util.function.Function
import java.util.stream.Collectors
import java.util.stream.IntStream
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.OrderBook
import org.swtchart.Chart
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.ISeries.SeriesType
import org.swtchart.LineStyle
import org.swtchart.Range
import org.swtchart.internal.series.LineSeries

class OrderbookHistory {

	var Chart chart

	@PostConstruct
	def void createPartControl(Composite parent) {
		chart = new Chart(parent, SWT.NONE) => [
			title.text = ""
			backgroundInPlotArea = new Color(parent.display, 0, 0, 0)
			title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getXAxis(0).title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getXAxis(0).tick.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).tick.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).title.text = "Price"
			axisSet.getXAxis(0).title.text = ""
		]
		val bufferSize = 500
		val bidBuffer = new CircularFifoQueue<Double>(bufferSize)
		val bid = chart.seriesSet.createSeries(SeriesType.LINE, "Bid") as LineSeries
		bid.symbolType = PlotSymbolType.NONE
		bid.lineColor = new Color(parent.display, 0, 255, 0)
		bid.enableStep(true)
		val askBuffer = new CircularFifoQueue<Double>(bufferSize)
		val ask = chart.seriesSet.createSeries(SeriesType.LINE, "Ask") as LineSeries
		ask.symbolType = PlotSymbolType.NONE
		ask.lineColor = new Color(parent.display, 255, 0, 0)
		ask.enableStep(true)
		val volumeBuffer = new CircularFifoQueue<List<Pair<Double, Double>>>(bufferSize)
		val volume = chart.seriesSet.createSeries(SeriesType.LINE, "Volume") as LineSeries
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
		val exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.name)
		exchange.connect().blockingAwait()
		exchange.streamingMarketDataService.getOrderBook(CurrencyPair.BTC_USD).subscribe [
			if(chart.disposed) {
				exchange.disconnect()
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
					bidBuffer.add(bids.get(0).limitPrice.doubleValue())
					askBuffer.add(asks.get(0).limitPrice.doubleValue())
					volumeBuffer.add((bids.map[limitPrice.doubleValue() -> remainingAmount.doubleValue()] + asks.map[limitPrice.doubleValue() -> remainingAmount.doubleValue()]).toList())
					val volumes = volumeBuffer.toList()
					val volumesX = volumeBuffer.parallelStream.flatMap [ tick |
						IntStream.range(0, tick.size()).parallel().mapToObj[volumes.toList.indexOf(tick).doubleValue]
					].collect(Collectors.toList())
					val volumesY = volumeBuffer.parallelStream.flatMap [ tick |
						tick.parallelStream.map[key]
					].collect(Collectors.toList())
					val volumesColor = volumeBuffer.parallelStream.flatMap [ tick |
						tick.parallelStream.map[Math.abs(value)].map [
							getGradient.apply(longValue)
						]
					].collect(Collectors.toList())
					parent.display.syncExec [
						if(chart.disposed) {
							exchange.disconnect()
							return
						}
						bid.YSeries = bidBuffer
						ask.YSeries = askBuffer
						volume.XSeries = volumesX
						volume.YSeries = volumesY
						volume.symbolColors = volumesColor
						chart.axisSet.adjustRange
						chart.axisSet.getYAxis(0).range = new Range(bids.get(0).limitPrice.doubleValue() - 25, asks.get(0).limitPrice.doubleValue() + 25)
						chart.redraw()
					]
				}
			}
		].start()
	}

	@Focus
	def void setFocus() {
		chart.setFocus()
	}
}
