package com.sirolf2009.serenity.sketches

import com.sirolf2009.serenity.GDAXClient
import com.sirolf2009.serenity.dto.Side
import com.sirolf2009.serenity.dto.UpdateMatch
import com.sirolf2009.serenity.dto.UpdateOpen
import grafica.GPlot
import com.google.common.util.concurrent.AtomicDouble
import java.util.HashMap
import grafica.GPointsArray

class OrderbookVolume extends Sketch {

	val colors = #[
		color(0, 0, 255, 100),
		color(0, 255, 0, 100),
		color(255, 255, 0, 100),
		color(255, 0, 0, 100)
	]
	val stepSize = 10 / colors.size()-1
	
	var GPlot plot

	override settings() {
		size(1024, 900)
	}

	override setup() {
		frameRate(1)

		plot = darkPlot()
		plot.lineWidth = 2
		plot.titleText = "Orderbook Volume"
		plot.XAxis.axisLabelText = "Time"
		plot.YAxis.axisLabelText = "Price"

		plot.addLayer("volumes", new GPointsArray())
		val volumesLayer = plot.getLayer("volumes")

		val start = System.currentTimeMillis()
		val highestBid = new AtomicDouble()
		val lowestAsk = new AtomicDouble(Double.MAX_VALUE)
		val volumes = new HashMap()

		new GDAXClient [
			if(it instanceof UpdateOpen) {
				if(side === Side.BUY) {
					highestBid.set(Math.max(highestBid.get(), price))
				} else {
					lowestAsk.set(Math.min(lowestAsk.get(), price))
				}
				if(lowestAsk.get() != 0 && highestBid.get() != Double.MAX_VALUE) {
					val midPrice = (lowestAsk.get() + highestBid.get()) / 2
					synchronized(plot) {
						plot.addPoint(System.currentTimeMillis - start, midPrice.floatValue)
					}
					synchronized(volumes) {
						if(!volumes.containsKey(price)) {
							volumes.put(price, remainingSize)
						} else {
							volumes.put(price, volumes.get(price) + remainingSize)
						}
						volumes.entrySet.forEach [
							synchronized(plot) {
								volumesLayer.addPoint(System.currentTimeMillis - start, it.key.floatValue)
								volumesLayer.pointColors = volumesLayer.pointColors.append(value.gradientColor)
							}
						]
					}
				}
			} else if(it instanceof UpdateMatch) {
				if(side === Side.BUY) {
					highestBid.set(Math.max(highestBid.get(), price))
				} else {
					lowestAsk.set(Math.min(lowestAsk.get(), price))
				}
				if(lowestAsk.get() != 0 && highestBid.get() != Double.MAX_VALUE) {
					val midPrice = (lowestAsk.get() + highestBid.get()) / 2
					synchronized(plot) {
						plot.addPoint(System.currentTimeMillis - start, midPrice.floatValue)
					}
					synchronized(volumes) {
						if(volumes.containsKey(price)) {
							volumes.put(price, volumes.get(price) - size)
						}
						volumes.entrySet.forEach [
							synchronized(plot) {
								volumesLayer.addPoint(System.currentTimeMillis - start, it.key.floatValue)
								volumesLayer.pointColors = volumesLayer.pointColors.append(value.gradientColor)
							}
						]
					}
				}
			}
		]
	}

	override draw() {
		background(0)

		synchronized(plot) {
			plot => [
				beginDraw()
				drawBackground()
				drawTitle()
				drawXAxis()
				drawYAxis()
				plot.mainLayer.drawLines()
				plot.getLayer("volumes").drawPoints()
				endDraw()
			]
		}
	}
	
	def getGradientColor(double volume) {
		val cs = colors.get(min((volume/stepSize).intValue, colors.size()-1))
		val ce = colors.get(min((volume/stepSize+1).intValue, colors.size()-1))
		val amt = volume % stepSize / stepSize
		return lerpColor(cs, ce, amt.floatValue)
	}

	def static void main(String[] args) {
		runSketch(#[OrderbookVolume.name], new OrderbookVolume())
	}

}
