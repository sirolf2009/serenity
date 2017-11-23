package com.sirolf2009.serenity.client

import java.net.URI
import org.apache.logging.log4j.LogManager
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake

abstract class GDAXClient extends WebSocketClient {

	static val log = LogManager.logger

	new() {
		super(uri())
		connectBlocking()
	}

	override onClose(int code, String reason, boolean remote) {
		log.warn('''Closed. code=«code» reason=«reason» remote=«remote»''')
	}

	override onError(Exception exception) {
		log.error("GDAX sent error", exception)
	}

	override onOpen(ServerHandshake handshake) {
		log.info("Handshaking with " + uri)
	}

	def static uri() {
		new URI("wss://ws-feed.gdax.com")
	}

}
