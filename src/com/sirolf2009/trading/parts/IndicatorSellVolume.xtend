package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.SMA
import com.sirolf2009.commonwealth.indicator.line.SellVolume
import com.sirolf2009.trading.SerenityChart
import java.time.Duration

class IndicatorSellVolume extends IndicatorChart {
	
	new() {
		super(new SMA((Duration.ofMinutes(10).toMillis()/1000) as int, new SellVolume()), SerenityChart.red, "sell-vol")
	}
	
}