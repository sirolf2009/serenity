package com.sirolf2009.trading

import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import io.reactivex.Observable
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.Trade
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext
import org.knowm.xchange.dto.marketdata.OrderBook

class Activator implements BundleActivator {

	private static final CurrencyPair currency = CurrencyPair.BTC_USD
	private static var BundleContext context
	private static var StreamingExchange exchange
	private static var Observable<Trade> trades
	private static var Observable<OrderBook> orderbook

	override start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext
		exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.name)
		exchange.connect().subscribe [
			trades = exchange.streamingMarketDataService.getTrades(currency)
			orderbook = exchange.streamingMarketDataService.getOrderBook(currency)
		]
	}

	override stop(BundleContext bundleContext) throws Exception {
		Activator.context = null
		exchange.disconnect()
	}

	def static BundleContext getContext() {
		return context
	}

	def static getTrades() {
		return trades
	}

	def static getOrderbook() {
		return orderbook
	}

	def static StreamingExchange getExchange() {
		return exchange
	}

}
