package com.sirolf2009.serenity

import java.util.function.Supplier
import com.sirolf2009.serenity.model.Orderbook

interface IOrderbookProvider extends Supplier<Orderbook> {
	
	def double getLowestAsk()
	def double getHighestBid()
	
}