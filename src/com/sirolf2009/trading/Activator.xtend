package com.sirolf2009.trading

import com.google.common.eventbus.Subscribe
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
import java.nio.file.Files
import java.nio.file.Paths
import java.util.concurrent.atomic.AtomicLong
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Status
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext
import java.util.concurrent.atomic.AtomicBoolean

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

	override start(BundleContext bundleContext) throws Exception {
		instance = this
		Activator.context = bundleContext
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

		tradesSubject = PublishSubject.create()
		trades = tradesSubject.replay()
		trades.connect()
		orderbookSubject = PublishSubject.create()
		orderbook = orderbookSubject.replay()
		orderbook.connect()
	}

	def void connect() {
		exchange = new BitfinexWebsocketClient() => [
			eventBus.register(this)
			new Thread [
				connectBlocking()
				send(new SubscribeTrades("BTCUSD"))
				send(new SubscribeOrderbook("BTCUSD", SubscribeOrderbook.PREC_PRECISE, SubscribeOrderbook.FREQ_REALTIME))
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

	def static BundleContext getContext() {
		return context
	}

	def static getTrades() {
		return trades.subscribeOn(Schedulers.computation)
	}

	def static getOrderbook() {
		return orderbook.subscribeOn(Schedulers.computation)
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
