package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.BuyVolume
import com.sirolf2009.trading.SerenityChart
import java.time.Duration

class IndicatorBuyVolume extends IndicatorChart {
	
	new() {
		super(new BuyVolume(Duration.ofMinutes(1).toMillis()), SerenityChart.green, "buy-vol")
	}
	
}