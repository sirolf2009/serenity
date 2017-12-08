package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.timeseries.IPoint
import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.timeseries.Timeseries
import com.sirolf2009.commonwealth.timeseries.trends.IPeakTroughFinder
import com.sirolf2009.commonwealth.timeseries.trends.PeakTroughFinderPercentage
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Data
import org.swtchart.Chart
import org.swtchart.internal.series.BarSeries
import java.util.stream.IntStream
import org.eclipse.swt.graphics.Color

class TrendProperties extends ChartPart implements IExchangePart {

	var Chart chart
	var BarSeries averageBidSum
	var BarSeries averageBidDiff
	var BarSeries averageAskSum
	var BarSeries averageAskDiff

	val bufferSize = 5000
	val buffer = new CircularFifoQueue<IOrderbook>(bufferSize)
	val IPeakTroughFinder peakTroughFinder = new PeakTroughFinderPercentage(0.002)

	@PostConstruct
	def void createPartControl(Composite parent) {
		chart = parent.createChart() => [
			yAxis.title.text = "Value"
			xAxis.enableCategory(true)
			averageBidSum = createBarSeries("avg bid sum") => [
				enableStack(true)
				barColor = green
			]
			averageBidDiff = createBarSeries("avg bid diff") => [
				enableStack(true)
				barColor = new Color(parent.display, 100, 255, 100)
			]
			averageAskSum = createBarSeries("avg ask") => [
				enableStack(true)
				barColor = red
			]
			averageAskDiff = createBarSeries("avg ask diff") => [
				enableStack(true)
				barColor = new Color(parent.display, 255, 100, 100)
			]
		]

		orderbook.subscribe [
			if(chart.disposed) {
				return
			}
			if(it !== null) {
				receiveOrderbook(it)
			}
		]
	}

	def receiveOrderbook(IOrderbook orderbook) {
		buffer.add(orderbook)
		val mids = new Timeseries((0 ..< buffer.size()).map[new Point(it, buffer.get(it).mid) as IPoint].toList())
		val extremes = peakTroughFinder.apply(mids)
		val properties = (0 ..< extremes.size()).map [
			val from = extremes.get(it).point.x.intValue()
			val to = if(it == extremes.size() - 1) mids.size() - 1 else extremes.get(it + 1).point.x.intValue()
			val orderbooks = (from ..< to).map[buffer.get(it)].toList()
			val averageBidSum = orderbooks.stream().mapToDouble[sumBid].average.orElse(Double.NaN)
			val averageBidDiff = orderbooks.stream().flatMap[
				IntStream.range(0, bids.size()-1) .mapToObj[i|
					bids.get(i).price.doubleValue() - bids.get(i+1).price.doubleValue()
				]
			].mapToDouble[it].average.orElse(Double.NaN)
			val averageAskSum = orderbooks.stream().mapToDouble[-sumAsk].average.orElse(Double.NaN)
			val averageAskDiff = orderbooks.stream().flatMap[
				IntStream.range(0, asks.size()-1) .mapToObj[i|
					asks.get(i+1).price.doubleValue() - asks.get(i).price.doubleValue()
				]
			].mapToDouble[it].average.orElse(Double.NaN)
			new Properties(averageBidSum, averageBidDiff, averageAskSum, averageAskDiff)
		].filter[!averageBidSum.naN && !averageAskSum.naN].toList()
		val averageBidSumSeries = properties.map[averageBidSum].toList()
		val averageBidDiffSeries = properties.map[averageBidDiff].toList()
		val averageAskSumSeries = properties.map[averageAskSum].toList()
		val averageAskDiffSeries = properties.map[averageAskDiff].toList()
		if(averageBidSumSeries.size() > 0 || averageAskSumSeries.size() > 0) {
			chart.display.syncExec [
				if(chart.disposed) {
					return
				}
				averageBidSum.YSeries = averageBidSumSeries
				averageBidDiff.YSeries = averageBidDiffSeries
				averageAskSum.YSeries = averageAskSumSeries
				averageAskDiff.YSeries = averageAskDiffSeries
				chart.axisSet.adjustRange()
				chart.redraw()
			]
		}
	}

	@Data static class Properties {

		val double averageBidSum
		val double averageBidDiff
		val double averageAskSum
		val double averageAskDiff

	}

}
