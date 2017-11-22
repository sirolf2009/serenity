package com.sirolf2009.serenity

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IUpdate
import java.net.URI
import java.util.concurrent.Executors
import java.util.function.Consumer
import org.apache.logging.log4j.LogManager
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake

class GDAXClient extends WebSocketClient {

	static val log = LogManager.logger
	static val gson = new Gson()
	static val parser = new UpdateParser()
	static val executor = Executors.newCachedThreadPool

	val Consumer<IUpdate> onUpdate

	new(Consumer<IUpdate> onUpdate) {
		super(uri())
		this.onUpdate = onUpdate
		connectBlocking()
		send('''{
		    "type": "subscribe",
		    "product_ids": [
		        "BTC-EUR"
		    ],
		    "channels": [
		        "full"
		    ]
		}''')
	}

	override onClose(int code, String reason, boolean remote) {
		log.warn('''Closed. code=«code» reason=«reason» remote=«remote»''')
	}

	override onError(Exception exception) {
		log.error("GDAX sent error", exception)
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

	override onOpen(ServerHandshake handshake) {
		log.info("Handshaking with " + URI)
	}

	def static uri() {
		new URI("wss://ws-feed.gdax.com")
	}

}
