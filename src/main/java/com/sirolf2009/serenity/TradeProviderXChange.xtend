package com.sirolf2009.serenity

import com.sirolf2009.serenity.model.Trade
import info.bitrich.xchangestream.core.StreamingExchange
import java.util.ArrayList
import java.util.List
import org.apache.logging.log4j.LogManager
import org.knowm.xchange.currency.CurrencyPair

class TradeProviderXChange implements ITradeProvider {

	static val log = LogManager.logger
	val trades = new ArrayList()

	new(StreamingExchange exchange, CurrencyPair pair) {
		exchange.streamingMarketDataService.getTrades(pair).subscribe [
			try {
				synchronized(trades) {
					trades.add(new Trade(it.price.doubleValue(), it.originalAmount.doubleValue()))
				}
			} catch(Exception e) {
				log.info("Failed to process trade " + it)
			}
		]
	}

	override get() {
		synchronized(trades) {
			val clone = trades.clone() as List<Trade>
			trades.clear()
			return clone
		}
	}

}
