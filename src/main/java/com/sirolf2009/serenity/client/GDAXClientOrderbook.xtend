package com.sirolf2009.serenity.client

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IL2Update
import com.sirolf2009.serenity.parser.L2UpdateParser
import java.util.concurrent.Executors
import java.util.function.Consumer
import org.apache.logging.log4j.LogManager

class GDAXClientOrderbook extends GDAXClient {
	
	static val log = LogManager.logger
	static val gson = new Gson()
	static val parser = new L2UpdateParser()
	static val executor = Executors.newCachedThreadPool
	static val subscribe = '''{
		    "type": "subscribe",
		    "product_ids": [
		        "BTC-EUR"
		    ],
		    "channels": [
		        "level2"
		    ]
		}'''
		
	val Consumer<IL2Update> onUpdate
	
	new(Consumer<IL2Update> onUpdate) {
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