package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.math.BigDecimal
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricOrderbookVolume extends AsyncMetric implements IExchangePart {

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Orderbook buy volume per second")
		orderbook.subscribe [
			try {
				val mid = bids.get(0).limitPrice.add(asks.get(0).limitPrice).divide(BigDecimal.valueOf(2)).doubleValue()
				val bids = bids.filter [
					mid - limitPrice.doubleValue() <= 25d
				].map[limitPrice.doubleValue()].reduce[a, b|a + b]
				val asks = asks.filter [
					limitPrice.doubleValue() - mid <= 25d
				].map[originalAmount.negate.doubleValue()].reduce[a, b|a + b]
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