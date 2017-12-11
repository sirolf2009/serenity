package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.util.concurrent.atomic.AtomicLong
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricTradesPerSecond extends Metric implements IExchangePart {

	val count = new AtomicLong(0)

	@PostConstruct
	override createPartControl(Composite parent) {
		init(parent, "Trades per second")
		trades.subscribe [
			count.incrementAndGet()
		]
	}

	@Focus
	override setFocus() {
		chart.setFocus()
	}
	
	override measure() {
		val value = count.get().doubleValue()
		count.set(0)
		return value
	}

}
