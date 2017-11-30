package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble

abstract class AsyncMetric extends Metric {

	val AtomicDouble atom = new AtomicDouble(Double.NaN)

	override measure() {
		return atom.get()
	}

	def set(Double value) {
		if(value === null) {
			throw new IllegalArgumentException("Cannot set to null")
		}
		atom.set(value)
	}

}
