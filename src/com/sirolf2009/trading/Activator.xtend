package com.sirolf2009.trading

import com.sirolf2009.commonwealth.timeseries.Point
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.Trade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.Orderbook
import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import io.reactivex.Observable
import java.nio.file.Files
import java.nio.file.Paths
import java.util.concurrent.atomic.AtomicLong
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.service.account.AccountService
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext

class Activator extends AbstractUIPlugin implements BundleActivator {

	private static final CurrencyPair currency = CurrencyPair.BTC_USD
	private static Activator instance
	private static var BundleContext context
	private static var StreamingExchange exchange
	private static var Observable<ITrade> trades
	private static var Observable<IOrderbook> orderbook
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
			accountService = exchange.accountService
			
			trades = exchange.streamingMarketDataService.getTrades(currency).map[
				new Trade(new Point(timestamp.time, price.doubleValue()), originalAmount.doubleValue()) as ITrade
			].replay().autoConnect()
			orderbook = exchange.streamingMarketDataService.getOrderBook(currency).map[
				val asks = asks.map[new LimitOrder(limitPrice.doubleValue(), remainingAmount.doubleValue()) as ILimitOrder].toList()
				val bids = bids.map[new LimitOrder(limitPrice.doubleValue(), remainingAmount.doubleValue()) as ILimitOrder].toList()
				new Orderbook(asks, bids) as IOrderbook
			]
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
	
	def static getOrderbookData() {
		val linecounter = new AtomicLong(-1)
		Files.readAllLines(Paths.get("/home/floris/git/serenity/orderbook.csv")).map[split(",")].map [
			try {
				linecounter.incrementAndGet()
				val orders = (1 ..< size()).map [ i |
					try {
						val data = get(i).split(":")
						val price = Double.parseDouble(data.get(1))
						val amount = Double.parseDouble(data.get(2))
						get(0) -> new LimitOrder(price, amount) as ILimitOrder
					} catch(Exception e) {
						throw new RuntimeException("Failed to parse column " + i + ": " + get(i), e)
					}
				].groupBy[key]
				new Orderbook(orders.get("ask").map[value].sortBy[price.doubleValue()].toList(), orders.get("bid").map[value].sortBy[price.doubleValue()].toList())
			} catch(Exception e) {
				throw new RuntimeException("Failed to parse line " + linecounter.get() + " " + it.toList(), e)
			}
		]
	}

}
