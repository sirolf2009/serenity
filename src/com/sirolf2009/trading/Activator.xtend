package com.sirolf2009.trading

import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import io.reactivex.Observable
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.marketdata.Trade
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext
import org.knowm.xchange.service.account.AccountService

class Activator extends AbstractUIPlugin implements BundleActivator {

	private static final CurrencyPair currency = CurrencyPair.BTC_USD
	private static Activator instance
	private static var BundleContext context
	private static var StreamingExchange exchange
	private static var Observable<Trade> trades
	private static var Observable<OrderBook> orderbook
	private static var AccountService accountService

	override start(BundleContext bundleContext) throws Exception {
		instance = this
		Activator.context = bundleContext
		if(preferenceStore.getBoolean("authenticate")) {
			val spec = new BitfinexStreamingExchange().defaultExchangeSpecification
			if(!preferenceStore.getString("username").empty) {
				spec.userName = preferenceStore.getString("username")
			}
			if(!preferenceStore.getString("apiKey").empty) {
				spec.apiKey = preferenceStore.getString("apiKey")
			}
			if(!preferenceStore.getString("secretKey").empty) {
				spec.secretKey = preferenceStore.getString("secretKey")
			}
			exchange = StreamingExchangeFactory.INSTANCE.createExchange(spec)
		} else {
			exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.name)
		}
		exchange.connect().subscribe [
			trades = exchange.streamingMarketDataService.getTrades(currency)
			orderbook = exchange.streamingMarketDataService.getOrderBook(currency)
			accountService = exchange.accountService
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

	def static AccountService getAccountService() {
		return accountService
	}
	
	def static getDefault() {
		return instance
	}

}
