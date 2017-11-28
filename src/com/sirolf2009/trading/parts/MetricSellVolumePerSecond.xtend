package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite
import java.math.BigDecimal

class MetricSellVolumePerSecond extends Metric implements IExchangePart {

	val count = new AtomicDouble(0)

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Sell volume per second")
		trades.subscribe [
			if(originalAmount.compareTo(BigDecimal.ZERO) < 0) {
				count.addAndGet(originalAmount.negate.doubleValue())
			}
		]
	}

	@Focus
	def void setFocus() {
		chart.setFocus()
	}
	
	override get() {
		val value = count.get()
		count.set(0)
		return value
	}

}
