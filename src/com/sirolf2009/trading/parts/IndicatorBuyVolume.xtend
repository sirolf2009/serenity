package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.BuyVolume
import com.sirolf2009.commonwealth.indicator.line.SMA
import com.sirolf2009.trading.SerenityChart
import java.time.Duration

class IndicatorBuyVolume extends IndicatorChart {
	
	new() {
		super(new SMA((Duration.ofMinutes(10).toMillis()/1000) as int, new BuyVolume()), SerenityChart.green, "buy-vol")
	}
	
}