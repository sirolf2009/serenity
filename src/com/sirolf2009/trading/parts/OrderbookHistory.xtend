package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.math.BigDecimal
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Date
import java.util.HashMap
import java.util.List
import java.util.concurrent.atomic.AtomicReference
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
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.Order.OrderType
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.trade.LimitOrder
import org.swtchart.Chart
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.LineStyle
import org.swtchart.Range
import org.swtchart.internal.series.LineSeries
import java.util.concurrent.atomic.AtomicLong
import com.sirolf2009.trading.PeakTroughFinder

class OrderbookHistory extends ChartPart implements IExchangePart {

	var Chart chart

	val bufferSize = 500
	val bidBuffer = new CircularFifoQueue<Double>(bufferSize)
	val askBuffer = new CircularFifoQueue<Double>(bufferSize)
	val volumeBuffer = new CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>>(bufferSize)
	val finder = new PeakTroughFinder(0.002)

	val savedColors = new HashMap<Long, Color>()
	val colors = #[
		new Color(null, 0, 0, 255),
		new Color(null, 0, 255, 255),
		new Color(null, 0, 255, 0),
		new Color(null, 255, 255, 0),
		new Color(null, 255, 0, 0)
	]
	val largeVolume = 20
	val stepSize = largeVolume / colors.size() - 1

	var LineSeries bid
	var LineSeries ask
	var LineSeries askFit
	var LineSeries volume
	
	var zoom = 100

	@PostConstruct
	def void createPartControl(Composite parent) {
		chart = parent.createChart() => [
			yAxis.title.text = "Price"
			addMouseWheelListener[
				zoom += count/3
			]
		]
		bid = chart.createLineSeries("Bid")
		bid.symbolType = PlotSymbolType.NONE
		bid.lineColor = green
		bid.enableStep(true)
		ask = chart.createLineSeries("Ask")
		ask.lineColor = red
		ask.enableStep(true)
		volume = chart.createLineSeries("Volume")
		volume.visibleInLegend = false
		volume.lineStyle = LineStyle.NONE
		volume.symbolType = PlotSymbolType.SQUARE
		volume.symbolSize = 1
		askFit = chart.createLineSeries("AskFit")
		askFit.lineColor = red

		val latestOrderbook = new AtomicReference<OrderBook>()
//		orderbook.subscribe [
//			if(chart.disposed) {
//				return
//			}
//			if(it !== null) {
//				latestOrderbook.set(it)
//			}
//		]
		new Thread [
			while(true) {
				Thread.sleep(1000)
				if(chart.disposed) {
					return
				}
				receiveOrderbook(latestOrderbook.get())
			}
		].start()
		
		new Thread [
			orderbookData.forEach [
				Thread.sleep(100)
				receiveOrderbook
			]
		].start()
	}

	def receiveOrderbook(OrderBook it) {
		if(it !== null) {
			val now = new Date()
			bidBuffer.add(bids.get(0).limitPrice.doubleValue())
			askBuffer.add(asks.get(0).limitPrice.doubleValue())
			val extremes = finder.apply(askBuffer.toList()).size()
			volumeBuffer.add(Pair.of(now, (bids.filter[originalAmount.doubleValue >= 1].map[limitPrice.doubleValue() -> originalAmount.doubleValue()] + asks.filter[originalAmount.doubleValue <= -1].map[limitPrice.doubleValue() -> originalAmount.doubleValue()]).toList()))
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
			val askFitted = if(extremes != 0) askBuffer.fit(extremes+1) else #[]
			if(chart.disposed) {
				return
			}
			chart.display.syncExec [
				if(chart.disposed) {
					return
				}
				bid.YSeries = bidBuffer
				ask.YSeries = askBuffer
				askFit.YSeries = askFitted
				askFit.description = "askFit("+extremes+")"
				volume.XSeries = volumesX
				volume.YSeries = volumesY
				volume.symbolColors = volumesColor
				chart.xAxis.adjustRange()
				val mid = (bids.get(0).limitPrice.doubleValue() + asks.get(0).limitPrice.doubleValue()) / 2
				chart.yAxis.range = new Range(mid - (mid / zoom), mid + (mid / zoom))
				chart.redraw()
			]
		} else {
			System.err.println("Orderbook is null")
		}
	}

	def static getOrderbookData() {
		val linecounter = new AtomicLong(-1)
		Files.readAllLines(Paths.get("/home/floris/git/serenity/orderbook.csv")).map[split(",")].map [
			try {
				linecounter.incrementAndGet()
				val time = new Date(Long.parseLong(get(0)))
				val orders = (1 ..< size()).map [ i |
					try {
						val data = get(i).split(":")
						val side = if(data.get(0) == "bid") OrderType.BID else OrderType.ASK
						val price = Double.parseDouble(data.get(1))
						val amount = Double.parseDouble(data.get(2))
						new LimitOrder(side, BigDecimal.valueOf(amount), BigDecimal.valueOf(amount), CurrencyPair.BTC_USD, "", time, BigDecimal.valueOf(price))
					} catch(Exception e) {
						throw new RuntimeException("Failed to parse column " + i + ": " + get(i), e)
					}
				].groupBy[type]
				new OrderBook(time, orders.get(OrderType.ASK).sortBy[limitPrice], orders.get(OrderType.BID).sortBy[limitPrice].reverseView())
			} catch(Exception e) {
				throw new RuntimeException("Failed to parse line "+linecounter.get()+" "+it.toList(), e)
			}
		]
	}

	def static getBidAsk() {
		Files.readAllLines(Paths.get("/home/floris/git/serenity/bidask.csv")).map[split(",")].map [
			val time = new Date(Long.parseLong(get(0)))
			val bid = Double.parseDouble(get(1))
			val ask = Double.parseDouble(get(2))
			val bidOrder = new LimitOrder(OrderType.BID, BigDecimal.ONE, BigDecimal.ONE, CurrencyPair.BTC_USD, "", time, BigDecimal.valueOf(bid))
			val askOrder = new LimitOrder(OrderType.ASK, BigDecimal.ONE, BigDecimal.ONE, CurrencyPair.BTC_USD, "", time, BigDecimal.valueOf(ask))
			new OrderBook(time, #[bidOrder], #[askOrder])
		]
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

			savedColors.put(it, new Color(null, Math.round(r1 + (r2 - r1) * amt).intValue, Math.round(g1 + (g2 - g1) * amt).intValue, Math.round(b1 + (b2 - b1) * amt).intValue))
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
	def void setFocus() {
		chart.setFocus()
	}

}
