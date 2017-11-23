package com.sirolf2009.serenity.sketches

import com.sirolf2009.serenity.client.GDAXClientOrders
import com.sirolf2009.serenity.dto.Side
import com.sirolf2009.serenity.dto.UpdateMatch
import com.sirolf2009.serenity.dto.UpdateOpen
import grafica.GPlot
import grafica.GPointsArray

class OrderbookEvents extends Sketch {

	var GPlot plot

	override settings() {
		size(1024, 900)
	}

	override setup() {
		frameRate(1)
		
		plot = darkPlot()
		plot.titleText = "Orderbook events"
		plot.XAxis.axisLabelText = "Time"
		plot.YAxis.axisLabelText = "Price"

		plot.pointColor = color(150, 40, 40)
		plot.addLayer("asks-removed", new GPointsArray())
		val asksRemoved = plot.getLayer("asks-removed")
		asksRemoved.pointColor = color(150, 150, 40)
		plot.addLayer("bids", new GPointsArray())
		val bids = plot.getLayer("bids")
		bids.pointColor = color(40, 40, 150)
		plot.addLayer("bids-removed", new GPointsArray())
		val bidsRemoved = plot.getLayer("bids-removed")
		bidsRemoved.pointColor = color(40, 150, 150)

		val start = System.currentTimeMillis()

		new GDAXClientOrders [
			if(it instanceof UpdateOpen) {
				if(price > 6000) {
					synchronized(plot) {
						if(side === Side.BUY) {
							bids.addPoint(System.currentTimeMillis - start, price.floatValue())
							bids.pointSizes = bids.pointSizes.append(Math.log(remainingSize*2000).floatValue())
						} else {
							plot.addPoint(System.currentTimeMillis - start, price.floatValue())
							plot.pointSizes = bids.pointSizes.append(Math.log(remainingSize*2000).floatValue())
						}
					}
				}
			} else if(it instanceof UpdateMatch) {
				if(price > 6000) {
					synchronized(plot) {
						if(side === Side.BUY) {
							bidsRemoved.addPoint(System.currentTimeMillis - start, price.floatValue())
							bidsRemoved.pointSizes = bids.pointSizes.append(Math.log(size*2000).floatValue())
						} else {
							asksRemoved.addPoint(System.currentTimeMillis - start, price.floatValue())
							asksRemoved.pointSizes = bids.pointSizes.append(Math.log(size*2000).floatValue())
						}
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
				drawPoints()
				endDraw()
			]
		}
	}
	
	def static void main(String[] args) {
		runSketch(#[OrderbookEvents.name], new OrderbookEvents())
	}

}
