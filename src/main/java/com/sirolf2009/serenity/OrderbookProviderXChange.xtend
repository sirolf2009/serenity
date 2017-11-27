package com.sirolf2009.serenity

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.serenity.model.Order
import com.sirolf2009.serenity.model.Orderbook
import info.bitrich.xchangestream.core.StreamingExchange
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import org.apache.logging.log4j.LogManager
import org.knowm.xchange.currency.CurrencyPair

class OrderbookProviderXChange implements IOrderbookProvider {

	static val log = LogManager.logger
	val bids = new AtomicReference<List<Order>>()
	val asks = new AtomicReference<List<Order>>()
	val highestBid = new AtomicDouble()
	val lowestAsk = new AtomicDouble(Double.MAX_VALUE)

	new(StreamingExchange exchange, CurrencyPair pair) {
		exchange.streamingMarketDataService.getOrderBook(pair).subscribe [
			try {
				bids.set(it.bids.map[new Order(it.limitPrice.doubleValue(), it.remainingAmount.doubleValue())].toList())
				asks.set(it.asks.map[new Order(it.limitPrice.doubleValue(), it.remainingAmount.doubleValue() * -1)].toList())
				highestBid.set(bids.get().map[price].max)
				lowestAsk.set(asks.get().map[price].min)
			} catch(Exception e) {
				log.info("Failed to process orderbook "+it)
			}
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
