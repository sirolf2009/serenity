package com.sirolf2009.trading

import com.google.common.util.concurrent.AtomicDouble
import java.util.ArrayList
import java.util.List
import java.util.Optional
import java.util.concurrent.atomic.AtomicInteger
import java.util.function.Function
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class PeakTroughFinder implements Function<List<Double>, List<Extreme>> {

	val double threshold

	override apply(List<Double> values) {
		val firstPeak = detectPeak(values, 0)
		val firstTrough = detectTrough(values, 0)
		val extremes = new ArrayList()
		if(!firstPeak.isPresent() && !firstTrough.isPresent()) {
			return extremes
		} else if(firstPeak.isPresent() && !firstTrough.isPresent()) {
			return #[new Extreme(firstPeak.get(), ExtremeType.PEAK)]
		} else if(firstTrough.isPresent() && !firstPeak.isPresent()) {
			return #[new Extreme(firstTrough.get(), ExtremeType.TROUGH)]
		} else if(firstPeak.get() == firstTrough.get()) {
			return extremes
		} else if(firstTrough.get() < firstPeak.get()) {
			extremes.add(new Extreme(firstTrough.get(), ExtremeType.TROUGH))
			extremes.add(new Extreme(firstPeak.get(), ExtremeType.PEAK))
			var lastPeak = firstPeak
			while(true) {
				val trough = detectTrough(values, lastPeak.get()+1)
				if(!trough.isPresent()) {
					return extremes
				}
				extremes.add(new Extreme(trough.get(), ExtremeType.TROUGH))
				if(trough.get() == values.size()-1) {
					return extremes
				}
				val peak = detectPeak(values, trough.get()+1)
				if(!peak.isPresent()) {
					return extremes
				}
				extremes.add(new Extreme(peak.get(), ExtremeType.PEAK))
				if(peak.get() == values.size()-1) {
					return extremes
				}
				lastPeak = peak
			}
		} else {
			extremes.add(new Extreme(firstPeak.get(), ExtremeType.PEAK))
			extremes.add(new Extreme(firstTrough.get(), ExtremeType.TROUGH))
			var lastTrough = firstTrough
			while(true) {
				val peak = detectPeak(values, lastTrough.get()+1)
				if(!peak.isPresent()) {
					return extremes
				}
				extremes.add(new Extreme(peak.get(), ExtremeType.PEAK))
				if(peak.get() == values.size()-1) {
					return extremes
				}
				val trough = detectTrough(values, peak.get()+1)
				if(!trough.isPresent()) {
					return extremes
				}
				extremes.add(new Extreme(trough.get(), ExtremeType.TROUGH))
				if(trough.get() == values.size()-1) {
					return extremes
				}
				lastTrough = trough
			}
		}
	}

	def detectPeak(List<Double> values, int since) {
		val max = new AtomicDouble(values.get(since))
		val indexOfMax = new AtomicInteger()
		val peakIndex = (since ..< values.size()).findFirst [
			if(values.get(it) > max.get()) {
				max.set(values.get(it))
				indexOfMax.set(it)
				return false
			} else {
				val drop = 1 - values.get(it) / max.get()
				return drop >= threshold
			}
		]
		if(peakIndex !== null) {
			return Optional.of(indexOfMax.get())
		} else {
			return Optional.empty()
		}
	}

	def detectTrough(List<Double> values, int since) {
		val min = new AtomicDouble(values.get(since))
		val indexOfMin = new AtomicInteger()
		val troughIndex = (since ..< values.size()).findFirst [
			if(values.get(it) < min.get()) {
				min.set(values.get(it))
				indexOfMin.set(it)
				return false
			} else {
				val rise = 1 - min.get() / values.get(it)
				return rise >= threshold
			}
		]
		if(troughIndex !== null) {
			return Optional.of(indexOfMin.get())
		} else {
			return Optional.empty()
		}
	}

}

@Data class Extreme {
	int index
	ExtremeType type
}

enum ExtremeType {
	PEAK,
	TROUGH
}
