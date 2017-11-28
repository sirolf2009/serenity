package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble

abstract class AsyncMetric extends Metric {
	
	val AtomicDouble atom = new AtomicDouble(Double.NaN)
	
	override get() {
		return atom.get()
	}
	
	def set(Double value) {
		atom.set(value)
	}
	
}