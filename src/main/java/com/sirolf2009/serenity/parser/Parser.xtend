package com.sirolf2009.serenity.parser

import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.Reason
import com.sirolf2009.serenity.dto.Side
import java.text.SimpleDateFormat
import java.util.Date
import java.util.UUID

class Parser {

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