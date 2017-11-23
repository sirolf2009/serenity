package com.sirolf2009.serenity.client

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IUpdate
import com.sirolf2009.serenity.parser.UpdateParser
import java.util.concurrent.Executors
import java.util.function.Consumer
import org.apache.logging.log4j.LogManager

class GDAXClientOrders extends GDAXClient {
	
	static val log = LogManager.logger
	static val gson = new Gson()
	static val parser = new UpdateParser()
	static val executor = Executors.newCachedThreadPool
	static val subscribe = '''{
		    "type": "subscribe",
		    "product_ids": [
		        "BTC-EUR"
		    ],
		    "channels": [
		        "full"
		    ]
		}'''
		
	val Consumer<IUpdate> onUpdate
	
	new(Consumer<IUpdate> onUpdate) {
		this.onUpdate = onUpdate
		send(subscribe)
	}

	override onMessage(String message) {
		executor.submit [
			try {
				val object = gson.fromJson(message, JsonObject)
				if(object.has("type")) {
					parser.apply(object).ifPresent [
						onUpdate.accept(it)
					]
				} else {
					log.warn("Unknown message: " + message)
				}
			} catch(Exception e) {
				log.error("Failed to handle message: " + message, e)
			}
		]
	}
	
}