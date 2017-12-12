package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.BidSum
import com.sirolf2009.trading.SerenityChart

class IndicatorBidSum extends IndicatorChart {
	
	new() {
		super(new BidSum(), SerenityChart.green, "bid-sum")
	}

}