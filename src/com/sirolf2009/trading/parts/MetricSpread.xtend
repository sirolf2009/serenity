package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricSpread extends AsyncMetric implements IExchangePart {

	@PostConstruct
	override createPartControl(Composite parent) {
		init(parent, "Spread")
		orderbook.subscribe [
			set(asks.get(0).price.doubleValue()-bids.get(0).price.doubleValue())
		]
	}

	@Focus
	override setFocus() {
		chart.setFocus()
	}
	
}
