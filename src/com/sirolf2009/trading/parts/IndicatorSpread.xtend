package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.Spread
import com.sirolf2009.trading.SerenityChart

class IndicatorSpread extends IndicatorChart {
	
	new() {
		super(new Spread(), SerenityChart.blue, "spread")
	}

}