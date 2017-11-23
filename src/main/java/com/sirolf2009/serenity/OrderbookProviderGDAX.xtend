package com.sirolf2009.serenity

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.serenity.client.GDAXClientOrderbook
import com.sirolf2009.serenity.dto.L2Snapshot
import com.sirolf2009.serenity.dto.L2Update
import com.sirolf2009.serenity.dto.Side
import java.util.HashMap
import com.sirolf2009.serenity.model.Order
import com.sirolf2009.serenity.model.Orderbook

class OrderbookProviderGDAX implements IOrderbookProvider {

	val bids = new HashMap<Double, Order>()
	val asks = new HashMap<Double, Order>()
	val highestBid = new AtomicDouble()
	val lowestAsk = new AtomicDouble(Double.MAX_VALUE)

	new() {
		new GDAXClientOrderbook() [
			if(it instanceof L2Snapshot) {
				synchronized(bids) {
					synchronized(asks) {
						bids.clear()
						it.bids.forEach [
							bids.put(price, new Order(price, size))
							highestBid.set(Math.max(highestBid.get(), price))
						]
						asks.clear()
						it.asks.forEach [
							asks.put(price, new Order(price, size))
							lowestAsk.set(Math.min(lowestAsk.get(), price))
						]
					}
				}
			} else if(it instanceof L2Update) {
				changes.forEach [
					if(side === Side.BUY) {
						synchronized(bids) {
							if(size == 0) {
								bids.remove(price)
							} else {
								bids.put(price, new Order(price, size))
							}
							highestBid.set(Math.max(highestBid.get(), price))
						}
					} else {
						synchronized(asks) {
							if(size == 0) {
								asks.remove(price)
							} else {
								asks.put(price, new Order(price, size))
							}
							lowestAsk.set(Math.min(lowestAsk.get(), price))
						}
					}
				]
			} else {
				throw new IllegalArgumentException("What is " + it + "?")
			}
		]
	}

	override get() {
		return new Orderbook(bids.values.toList(), asks.values.toList())
	}

	override getLowestAsk() {
		return lowestAsk.get()
	}

	override getHighestBid() {
		return highestBid.get()
	}

}
