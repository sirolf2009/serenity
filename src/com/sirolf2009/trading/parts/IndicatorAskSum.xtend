package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.AskSum
import com.sirolf2009.trading.SerenityChart

class IndicatorAskSum extends IndicatorChart {
	
	new() {
		super(new AskSum(), SerenityChart.red, "ask-sum")
	}
	
}