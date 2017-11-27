package com.sirolf2009.serenity

import com.sirolf2009.serenity.model.Trade
import java.util.List
import java.util.function.Supplier

interface ITradeProvider extends Supplier<List<Trade>> {
	
}