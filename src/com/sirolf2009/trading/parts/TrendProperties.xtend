package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.AskSum
import com.sirolf2009.commonwealth.indicator.line.BidSum
import com.sirolf2009.commonwealth.timeseries.IPoint
import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.timeseries.Timeseries
import com.sirolf2009.commonwealth.timeseries.trends.IPeakTroughFinder
import com.sirolf2009.commonwealth.timeseries.trends.PeakTroughFinderPercentage
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Data
import org.swtchart.Chart
import org.swtchart.internal.series.BarSeries
import com.sirolf2009.trading.Activator
import com.google.common.eventbus.Subscribe

class TrendProperties extends ChartPart {

	var Chart chart
	var BarSeries averageBidSum
	var BarSeries averageAskSum

	val bufferSize = 5000
	val buffer = new CircularFifoQueue<IOrderbook>(bufferSize)
	val IPeakTroughFinder peakTroughFinder = new PeakTroughFinderPercentage(0.002)

	@PostConstruct
	override createPartControl(Composite parent) {
		Activator.data.register(this)
		chart = parent.createChart() => [
			yAxis.title.text = "Value"
			xAxis.enableCategory(true)
			averageBidSum = createBarSeries("avg bid sum") => [
				enableStack(true)
				barColor = green
			]
			averageAskSum = createBarSeries("avg ask") => [
				enableStack(true)
				barColor = red
			]
		]
	}

	@Subscribe
	def receiveOrderbook(IOrderbook orderbook) {
		if(chart.disposed) {
			return
		}
		buffer.add(orderbook)
		val mids = new Timeseries((0 ..< buffer.size()).map[new Point(it, buffer.get(it).mid) as IPoint].toList())
		val extremes = peakTroughFinder.apply(mids)
		val properties = (0 ..< extremes.size()).map [
			val from = extremes.get(it).point.x.intValue()
			val to = if(it == extremes.size() - 1) mids.size() - 1 else extremes.get(it + 1).point.x.intValue()
			val orderbooks = (from ..< to).map[buffer.get(it)].toList()
			val averageBidSum = orderbooks.stream().mapToDouble[BidSum.bidSum(it)].average.orElse(Double.NaN)
			val averageAskSum = orderbooks.stream().mapToDouble[AskSum.askSum(it)].average.orElse(Double.NaN)
			new Properties(averageBidSum, averageAskSum)
		].filter[!averageBidSum.naN && !averageAskSum.naN].toList()
		val averageBidSumSeries = properties.map[averageBidSum].toList()
		val averageAskSumSeries = properties.map[averageAskSum].toList()
		if(averageBidSumSeries.size() > 0 || averageAskSumSeries.size() > 0) {
			chart.display.syncExec [
				if(chart.disposed) {
					return
				}
				averageBidSum.YSeries = averageBidSumSeries
				averageAskSum.YSeries = averageAskSumSeries
				chart.axisSet.adjustRange()
				chart.redraw()
			]
		}
	}

	override setFocus() {
		chart.setFocus()
	}

	@Data static class Properties {

		val double averageBidSum
		val double averageAskSum

	}

}
