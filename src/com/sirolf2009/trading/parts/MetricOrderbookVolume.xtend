package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricOrderbookVolume extends AsyncMetric implements IExchangePart {

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Orderbook buy volume per second")
		orderbook.subscribe [
			try {
				val mid = it.getMid()
				val bids = bids.filter [
					mid - price.doubleValue() <= 25d
				].map[price.doubleValue()].reduce[a, b|a + b]
				val asks = asks.filter [
					price.doubleValue() - mid <= 25d
				].map[-amount.doubleValue()].reduce[a, b|a + b]
				if(asks !== null && asks !== null) {
					set(bids + asks)
				}
			} catch(Exception e) {
				System.err.println("Failed to handle " + it)
				e.printStackTrace()
			}
		]
	}

	@Focus
	def void setFocus() {
		chart.setFocus()
	}

}
