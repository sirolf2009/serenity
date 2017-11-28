package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.trading.IExchangePart
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.widgets.Composite

class MetricVolumePerSecond extends Metric implements IExchangePart {

	val count = new AtomicDouble(0)

	@PostConstruct
	def void createPartControl(Composite parent) {
		init(parent, "Volume per second")
		trades.subscribe [
			count.addAndGet(originalAmount.abs.doubleValue())
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
