package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.math.BigDecimal
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricOrderbookBidVolume extends AsyncMetric implements IExchangePart {

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Bid volume per second")
		orderbook.subscribe [
			val mid = bids.get(0).limitPrice.add(asks.get(0).limitPrice).divide(BigDecimal.valueOf(2)).doubleValue()
			val bids = bids.filter[
				mid-limitPrice.doubleValue() <= 25d
			].map[remainingAmount.doubleValue()].reduce[a,b|a+b]
			set(bids)
		]
	}

	@Focus
	def void setFocus() {
		chart.setFocus()
	}

}
