package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricOrderbookBidVolume extends AsyncMetric implements IExchangePart {

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Bid volume per second")
		orderbook.subscribe [
			try {
				val mid = (bids.get(0).price.doubleValue()+asks.get(0).price.doubleValue())/2
				val bids = bids.filter [
					mid - price.doubleValue() <= 25d
				].map[amount.doubleValue()].reduce[a, b|a + b]
				if(bids !== null) {
					set(bids)
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
