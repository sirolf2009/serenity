package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.SellVolume
import com.sirolf2009.trading.SerenityChart
import java.time.Duration

class IndicatorSellVolume extends IndicatorChart {
	
	new() {
		super(new SellVolume(Duration.ofMinutes(1).toMillis()), SerenityChart.red, "sell-vol")
	}
	
}