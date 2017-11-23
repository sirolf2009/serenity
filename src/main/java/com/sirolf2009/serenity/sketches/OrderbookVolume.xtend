package com.sirolf2009.serenity.sketches

import com.sirolf2009.serenity.IOrderbookProvider
import com.sirolf2009.serenity.OrderbookProviderXChange
import com.sirolf2009.serenity.model.Order
import grafica.GLayer
import grafica.GPlot
import grafica.GPointsArray
import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.knowm.xchange.currency.CurrencyPair
import java.time.Duration
import processing.event.MouseEvent

@FinalFieldsConstructor class OrderbookVolume extends Sketch {

	val colors = #[
		color(0, 0, 255),
		color(0, 255, 255),
		color(0, 255, 0),
		color(255, 255, 0),
		color(255, 0, 0)
	]
	val largeVolume = 20
	val stepSize = largeVolume / colors.size() - 1
	val legend = getGradientImage(colors, 20, 100)

	val start = System.currentTimeMillis()

	val IOrderbookProvider orderbookProvider

	var GPlot plot
	var GLayer volumesLayer
	var GLayer bidLayer
	var double meanPrice
	var double meanStep

	var zoom = 25f

	override settings() {
		size(1024, 900)
	}

	override setup() {
		frameRate(60f)

		plot = darkPlot()
		plot.setOuterDim(width - 20, height)
		plot.lineWidth = 4
		plot.lineColor = color(200, 40, 40)
		plot.titleText = "Orderbook Volume"
		plot.XAxis.axisLabelText = "Time"
		plot.YAxis.axisLabelText = "Price"

		plot.addLayer("volumes", new GPointsArray())
		volumesLayer = plot.getLayer("volumes")
		volumesLayer.pointSize = 2
		plot.addLayer("best-bid", new GPointsArray())
		bidLayer = plot.getLayer("best-bid")
		bidLayer.lineWidth = 4
		bidLayer.lineColor = color(40, 200, 40)
	}

	override draw() {
		background(0)
		val x = System.currentTimeMillis - start

		val oldMeanStep = meanStep
		meanPrice = (orderbookProvider.highestBid + orderbookProvider.lowestAsk).floatValue / 2f
		meanStep = if(oldMeanStep != 0) (oldMeanStep * 99 + meanPrice) / 100 else meanPrice

		orderbookProvider.get() => [
			val (List<Order>)=>void addToPlot = [
				forEach[
//					if(Math.abs(price - meanPrice) < 10 && size >= 0.0) {
					if(size >= 0.5) {
//					if(price > 8000 && price < 8200) {
						volumesLayer.addPoint(x, price.floatValue)
						volumesLayer.pointColors = volumesLayer.pointColors.append(size.gradientColor)
					}
				]
			]
			if(it !== null && bids !== null) {
				addToPlot.apply(bids)
			}
			if(it !== null && asks !== null) {
				addToPlot.apply(asks)
			}
		]

		synchronized(plot) {
			plot.YLim = #[meanStep.floatValue - zoom, meanStep.floatValue + zoom]
			plot.XLim = #[max(0, x - Duration.ofMinutes(15).toMillis), x + Duration.ofMinutes(1).toMillis]
			plot => [
				if(meanPrice > 0) {
					addPoint(x, orderbookProvider.lowestAsk.floatValue)
					bidLayer.addPoint(x, orderbookProvider.highestBid.floatValue)
				}
				beginDraw()
				drawBackground()
				drawTitle()
				drawXAxis()
				drawYAxis()
				plot.mainLayer.drawLines()
				bidLayer.drawLines()
				plot.getLayer("volumes").drawPoints()
				endDraw()
			]
		}

		image(legend, width - 40, height / 2 - 50)
		textSize(10f)
		text("0", width - 60, height / 2 + 50)
		text(largeVolume, width - 60, height / 2 - 40)
	}

	override mouseWheel(MouseEvent event) {
		zoom += event.count.floatValue/2f
	}

	def getGradientColor(double volume) {
		return getGradientColor(volume, stepSize)
	}

	def getGradientColor(double volume, int stepSize) {
		val cs = colors.get(max(min((volume / stepSize).intValue, colors.size() - 1), 0))
		val ce = colors.get(max(min((volume / stepSize + 1).intValue, colors.size() - 1), 0))
		val amt = volume % stepSize / stepSize
		return lerpColor(cs, ce, amt.floatValue)
	}

	def getGradientImage(List<Integer> colors, int width, int height) {
		createImage(width, height, RGB) => [
			val stepSize = height / colors.size() - 1
			(0 ..< height).forEach [ y |
				val color = getGradientColor(height - y, stepSize)
				(0 ..< width).forEach [ x |
					pixels.set(x + y * width, color)
				]
			]
		]
	}

	def static void main(String[] args) {
		runSketch(#[OrderbookVolume.name], new OrderbookVolume(new OrderbookProviderXChange(BitfinexStreamingExchange, CurrencyPair.BTC_USD)))
	}

}
