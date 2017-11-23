package com.sirolf2009.serenity

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.serenity.model.Order
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import org.knowm.xchange.currency.CurrencyPair
import com.sirolf2009.serenity.model.Orderbook

class OrderbookProviderXChange implements IOrderbookProvider {
	
	val bids = new AtomicReference<List<Order>>()
	val asks = new AtomicReference<List<Order>>()
	val highestBid = new AtomicDouble()
	val lowestAsk = new AtomicDouble(Double.MAX_VALUE)
	
	new(Class<?> clazz, CurrencyPair pair) {
		val exchange = StreamingExchangeFactory.INSTANCE.createExchange(clazz.name)
		exchange.connect.blockingAwait()
		exchange.streamingMarketDataService.getOrderBook(pair).subscribe [
			bids.set(it.bids.map[new Order(it.limitPrice.doubleValue(), it.remainingAmount.doubleValue())].toList())
			asks.set(it.asks.map[new Order(it.limitPrice.doubleValue(), it.remainingAmount.doubleValue()*-1)].toList())
			highestBid.set(bids.get().map[price].max)
			lowestAsk.set(asks.get().map[price].min)
		]
	}
	
	override get() {
		return new Orderbook(bids.get(), asks.get())
	}
	
	override getLowestAsk() {
		return lowestAsk.get()
	}
	
	override getHighestBid() {
		return highestBid.get()
	}
	
}