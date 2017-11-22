package com.sirolf2009.serenity

import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IUpdate
import com.sirolf2009.serenity.dto.Reason
import com.sirolf2009.serenity.dto.Side
import com.sirolf2009.serenity.dto.UpdateOpen
import com.sirolf2009.serenity.dto.UpdateType
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Optional
import java.util.UUID
import java.util.function.Function
import com.sirolf2009.serenity.dto.UpdateDone
import com.sirolf2009.serenity.dto.UpdateMatch
import com.sirolf2009.serenity.dto.UpdateChange
import org.apache.logging.log4j.LogManager

class UpdateParser implements Function<JsonObject, Optional<IUpdate>> {
	
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

	def Side side(JsonObject object, String key) {
		return Side.valueOf(object.string(key).toUpperCase())
	}

	def Reason reason(JsonObject object, String key) {
		return Reason.valueOf(object.string(key).toUpperCase())
	}

	def Date date(JsonObject object, String key) {
		return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSSX").parse(object.string(key))
	}

	def UUID uuid(JsonObject object, String key) {
		return UUID.fromString(object.string(key))
	}

	def String string(JsonObject object, String key) {
		return object.getAsJsonPrimitive(key).getAsString()
	}

	def Double getDouble(JsonObject object, String key) {
		return object.getAsJsonPrimitive(key).getAsDouble()
	}

	def Integer getInt(JsonObject object, String key) {
		return object.getAsJsonPrimitive(key).getAsInt()
	}

	def Long getLong(JsonObject object, String key) {
		return object.getAsJsonPrimitive(key).getAsLong()
	}

}
