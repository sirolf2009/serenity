package com.sirolf2009.trading

import com.google.common.eventbus.Subscribe
import com.google.gson.GsonBuilder
import com.google.gson.JsonArray
import com.sirolf2009.bitfinex.wss.BitfinexWebsocketClient
import com.sirolf2009.bitfinex.wss.event.OnDisconnected
import com.sirolf2009.bitfinex.wss.event.OnSubscribed
import com.sirolf2009.bitfinex.wss.model.SubscribeOrderbook
import com.sirolf2009.bitfinex.wss.model.SubscribeTrades
import com.sirolf2009.commonwealth.trading.ITrade
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook
import com.sirolf2009.commonwealth.trading.orderbook.LimitOrder
import com.sirolf2009.commonwealth.trading.orderbook.Orderbook
import io.reactivex.disposables.Disposable
import io.reactivex.observables.ConnectableObservable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.PublishSubject
import java.net.URL
import java.nio.charset.Charset
import java.util.ArrayList
import java.util.Date
import java.util.List
import java.util.concurrent.atomic.AtomicBoolean
import org.apache.commons.io.IOUtils
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Status
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext

class Activator extends AbstractUIPlugin implements BundleActivator {

	private static val shouldReconnect = new AtomicBoolean(true)
	private static var Activator instance
	private static var BundleContext context
	private static var BitfinexWebsocketClient exchange
	private static var PublishSubject<ITrade> tradesSubject
	private static var ConnectableObservable<ITrade> trades
	private static var Disposable tradesConnection
	private static var PublishSubject<IOrderbook> orderbookSubject
	private static var ConnectableObservable<IOrderbook> orderbook
	private static var Disposable orderbookConnection
	private static var List<IOrderbook> orderbookPrimer

	override start(BundleContext bundleContext) throws Exception {
		instance = this
		Activator.context = bundleContext
		tradesSubject = PublishSubject.create()
		trades = tradesSubject.replay()
		trades.connect()
		orderbookSubject = PublishSubject.create()
		orderbook = orderbookSubject.replay()
		orderbook.connect()
		
		try {
			orderbookPrimer = getOrderbooksFromApi("serenity").toList()
		} catch(Exception e) {
			log.log(new Status(IStatus.WARNING, "serenity", "Could not prime the orderbook", e))
			orderbookPrimer = new ArrayList()
		}
		
		if(preferenceStore.getBoolean("authenticate")) {
			if(!preferenceStore.getString("username").empty) {
//				val userName = preferenceStore.getString("username")
			}
			if(!preferenceStore.getString("apiKey").empty) {
//				val apiKey = preferenceStore.getString("apiKey")
			}
			if(!preferenceStore.getString("secretKey").empty) {
//				val secretKey = preferenceStore.getString("secretKey")
			}
			// TODO auth
			connect()
		} else {
			connect()
		}
	}

	def void connect() {
		exchange = new BitfinexWebsocketClient() => [
			eventBus.register(this)
			new Thread [
				connectBlocking()
				send(new SubscribeTrades(preferenceStore.getConfiguration("symbol", "BTCUSD")))
				send(new SubscribeOrderbook(preferenceStore.getConfiguration("symbol", "BTCUSD"), preferenceStore.getConfiguration("precision", SubscribeOrderbook.PREC_PRECISE), preferenceStore.getConfiguration("frequency", SubscribeOrderbook.FREQ_REALTIME)))
			].start()
		]
	}

	@Subscribe
	def void onSubscribed(OnSubscribed onSubscribed) {
		onSubscribed.eventBus.register(this)
	}

	@Subscribe
	def void onDisconnected(OnDisconnected onDisconnected) {
		if(shouldReconnect.get()) {
			log.log(new Status(IStatus.WARNING, "serenity", "Disconnected from bitfinex. Reconnecting..."))
			connect()
		} else {
			log.log(new Status(IStatus.INFO, "serenity", "Disconnected from bitfinex."))
		}
	}

	@Subscribe
	def void onTrade(ITrade trade) {
		try {
			tradesSubject.onNext(trade)
		} catch(Exception e) {
			e.printStackTrace()
		}
	}

	@Subscribe
	def void onOrderbook(IOrderbook orderbook) {
		try {
			orderbookSubject.onNext(orderbook)
		} catch(Exception e) {
			e.printStackTrace()
		}
	}

	override stop(BundleContext bundleContext) throws Exception {
		Activator.context = null
		shouldReconnect.set(false)
		exchange?.close()
		exchange = null
		tradesConnection?.dispose()
		tradesConnection = null
		orderbookConnection?.dispose()
		orderbookConnection = null
	}
	
	def static getConfiguration(IPreferenceStore preferences, String name, String defaultValue) {
		val conf = preferences.getString(name)
		if(conf.empty) {
			return defaultValue
		} else {
			return conf
		}
	}

	def static BundleContext getContext() {
		return context
	}

	def static getTrades() {
		return trades.subscribeOn(Schedulers.computation)
	}

	def static getOrderbook() {
		return orderbook.subscribeOn(Schedulers.computation)
	}
	
	def static getOrderbookPrimer() {
		return orderbookPrimer
	}

	def static getDefault() {
		return instance
	}
	
	def static getOrderbooksFromApi(String host) {
		val url = new URL("http", host, "/orderbook")
		val gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ssX").create()
		val array = gson.fromJson(IOUtils.toString(url, Charset.defaultCharset), JsonArray)
		array.map[
			val orderbook = asJsonObject
			val date = gson.fromJson(orderbook.get("timestamp"), Date)
			val asks = orderbook.getAsJsonArray("asks").map[
				val price = asJsonObject.getAsJsonPrimitive("price").asDouble
				val amount = asJsonObject.getAsJsonPrimitive("amount").asDouble
				return new LimitOrder(price, amount) as ILimitOrder
			].sortBy[price.doubleValue].toList()
			val bids = orderbook.getAsJsonArray("bids").map[
				val price = asJsonObject.getAsJsonPrimitive("price").asDouble
				val amount = asJsonObject.getAsJsonPrimitive("amount").asDouble
				return new LimitOrder(price, amount) as ILimitOrder
			].sortBy[price.doubleValue].reverse().toList()
			return new Orderbook(date, asks, bids) as IOrderbook
		].sortBy[timestamp]
	}

}
