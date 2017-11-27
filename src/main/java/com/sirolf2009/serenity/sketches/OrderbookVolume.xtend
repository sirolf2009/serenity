package com.sirolf2009.serenity.sketches

import com.sirolf2009.serenity.IOrderbookProvider
import com.sirolf2009.serenity.ITradeProvider
import com.sirolf2009.serenity.OrderbookProviderXChange
import com.sirolf2009.serenity.TradeProviderXChange
import com.sirolf2009.serenity.model.Order
import grafica.GLayer
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import java.time.Duration
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.knowm.xchange.currency.CurrencyPair
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
	val fps = 60f
	val history = Duration.ofMinutes(2).toMillis / 1000

	val start = System.currentTimeMillis()

	val IOrderbookProvider orderbookProvider
	val ITradeProvider tradeProvider

	var GPlot plot
	var GLayer volumesLayer
	var GLayer bidLayer
	var GLayer tradesLayer
	var double meanPrice
	var double meanStep

	var zoom = 25f

	override settings() {
		size(1024, 900)
	}

	override setup() {
		frameRate(fps)

		plot = darkPlot()
		plot.setOuterDim(width - 20, height)
		plot.lineWidth = 4
		plot.lineColor = color(200, 40, 40)
		plot.titleText = "Orderbook Volume"
		plot.XAxis.axisLabelText = "Time"
		plot.YAxis.axisLabelText = "Price"
		plot.YAxis.rotateTickLabels = false
		plot.activatePointLabels()
		plot.rightAxis.drawTickLabels = true
		plot.rightAxis.rotateTickLabels = false
		plot.rightAxis.ticksSeparation = 5
		plot.rightAxis.drawAxisLabel = false

		plot.addLayer("volumes", new GPointsArray())
		volumesLayer = plot.getLayer("volumes")
		volumesLayer.pointSize = 1
		plot.addLayer("best-bid", new GPointsArray())
		bidLayer = plot.getLayer("best-bid")
		bidLayer.lineWidth = 4
		bidLayer.lineColor = color(40, 200, 40)
		plot.addLayer("trades", new GPointsArray())
		tradesLayer = plot.getLayer("trades")
	}

	override draw() {
		try {
			background(0)
			val x = System.currentTimeMillis - start

			val oldMeanStep = meanStep
			meanPrice = (orderbookProvider.highestBid + orderbookProvider.lowestAsk).floatValue / 2f
			meanStep = if(oldMeanStep != 0) (oldMeanStep * 9 + meanPrice) / 10 else meanPrice

			orderbookProvider.get() => [
				val (List<Order>)=>void addToPlot = [
					forEach[
						if(size >= 1) {
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
			tradeProvider.get() => [
				forEach[
					tradesLayer.addPoint(x, abs(price.floatValue), amount + "")
					tradesLayer.pointSizes = tradesLayer.pointSizes.append(abs(amount.floatValue) * 3)
					tradesLayer.pointColors = tradesLayer.pointColors.append(if(amount > 0) color(40, 200, 40, 200) else color(200, 40, 40, 200))
				]
			]

			synchronized(plot) {
				plot.YLim = #[meanStep.floatValue - zoom, meanStep.floatValue + zoom]
				plot.XLim = #[max(0, x - (fps * history) * 1000), x + (fps * history)]
				plot => [
					if(meanPrice > 0 && !meanPrice.infinite) {
						addPoint(x, orderbookProvider.lowestAsk.floatValue)
						bidLayer.addPoint(x, orderbookProvider.highestBid.floatValue)
					}
					beginDraw()
					drawBackground()
					drawTitle()
					drawXAxis()
					drawRightAxis()
//					plot.drawGridLines(GPlot.BOTH)
					plot.mainLayer.drawLines()
					bidLayer.drawLines()
					plot.getLayer("volumes").drawPoints()
					tradesLayer.drawPoints()
					plot.drawLine(new GPoint(x, orderbookProvider.lowestAsk.floatValue), new GPoint(x + 100000, orderbookProvider.lowestAsk.floatValue), color(200, 40, 40), 1)
					plot.drawLine(new GPoint(x, orderbookProvider.highestBid.floatValue), new GPoint(x + 100000, orderbookProvider.highestBid.floatValue), color(40, 200, 40), 1)
					plot.drawLabels()
					endDraw()
				]
			}

			image(legend, 20, height / 2 - 50)
			textSize(10f)
			text("0", 40, height / 2 + 50)
			text(largeVolume, 40, height / 2 - 40)

			plot.mainLayer.cleanLayer()
			volumesLayer.cleanLayer()
		} catch(Exception e) {
			e.printStackTrace()
		}
	}

	def cleanLayer(GLayer layer) {
		val offScreen = plot.XLim.get(0)
		for (var i = 0; i < layer.pointsRef.NPoints; i++) {
			if(layer.pointsRef.getX(i) >= offScreen) {
				if(i != 0) {
					layer.pointsRef.removeRange(0, i - 1)
					return
				}
			}
		}
	}

	override mouseWheel(MouseEvent event) {
		zoom += event.count.floatValue / 2f
		zoom = max(0.5f, zoom)
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
		val exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.name)
		exchange.connect.blockingAwait()
		runSketch(#[OrderbookVolume.name], new OrderbookVolume(new OrderbookProviderXChange(exchange, CurrencyPair.BTC_USD), new TradeProviderXChange(exchange, CurrencyPair.BTC_USD)))
	}

}
