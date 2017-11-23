package com.sirolf2009.serenity.parser

import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IUpdate
import com.sirolf2009.serenity.dto.UpdateChange
import com.sirolf2009.serenity.dto.UpdateDone
import com.sirolf2009.serenity.dto.UpdateMatch
import com.sirolf2009.serenity.dto.UpdateOpen
import com.sirolf2009.serenity.dto.UpdateType
import java.util.Optional
import java.util.function.Function
import org.apache.logging.log4j.LogManager

class UpdateParser extends Parser implements Function<JsonObject, Optional<IUpdate>> {
	
	static val log = LogManager.logger

	override apply(JsonObject object) {
		try {
			val type = UpdateType.valueOf(object.string("type").toUpperCase())
			if(type === UpdateType.OPEN) {
				val side = object.side("side")
				val price = object.getDouble("price")
				val orderID = object.uuid("order_id")
				val remainingSize = object.getDouble("remaining_size")
				val productID = object.string("product_id")
				val sequence = object.getLong("sequence")
				val time = object.date("time")
				return Optional.of(new UpdateOpen(time, productID, sequence, orderID, price, remainingSize, side))
			} else if(type === UpdateType.DONE) {
				val side = object.side("side")
				val orderID = object.uuid("order_id")
				val reason = object.reason("reason")
				val productID = object.string("product_id")
				val price = if(object.has("price")) object.getDouble("price") else Double.NaN
				val remainingSize = object.getDouble("remaining_size")
				val sequence = object.getLong("sequence")
				val time = object.date("time")
				return Optional.of(new UpdateDone(time, productID, sequence, orderID, price, reason, side, remainingSize))
			} else if(type === UpdateType.MATCH) {
				val tradeID = object.getLong("trade_id")
				val makerOrderID = object.uuid("maker_order_id")
				val takerOrderID = object.uuid("taker_order_id")
				val side = object.side("side")
				val size = object.getDouble("size")
				val price = object.getDouble("price")
				val productID = object.string("product_id")
				val sequence = object.getLong("sequence")
				val time = object.date("time")
				return Optional.of(new UpdateMatch(time, productID, sequence, tradeID, makerOrderID, takerOrderID, size, price, side))
			} else if(type === UpdateType.CHANGE) {
				val time = object.date("time")
				val sequence = object.getLong("sequence")
				val orderID = object.uuid("order_id")
				val productID = object.string("product_id")
				val newSize = object.getDouble("new_size")
				val oldSize = object.getDouble("old_size")
				val price = object.getDouble("price")
				val side = object.side("side")
				return Optional.of(new UpdateChange(time, productID, sequence, orderID, newSize, oldSize, price, side))
			}
		} catch(Exception e) {
			log.warn("Unknown object: "+object, e)
		}
		return Optional.empty()
	}

}
