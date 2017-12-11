package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricSellVolumePerSecond extends Metric implements IExchangePart {

	val count = new AtomicDouble(0)

	@PostConstruct
	override createPartControl(Composite parent) {
		init(parent, "Sell volume per second")
		trades.subscribe [
			if(amount.doubleValue() < 0) {
				count.addAndGet(amount.doubleValue()*-1)
			}
		]
	}

	@Focus
	override setFocus() {
		chart.setFocus()
	}
	
	override measure() {
		val value = count.get()
		count.set(0)
		return value
	}

}
