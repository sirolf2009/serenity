package com.sirolf2009.serenity.parser

import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.IL2Update
import com.sirolf2009.serenity.dto.L2Snapshot
import com.sirolf2009.serenity.dto.L2Snapshot.L2SnapshotEntry
import com.sirolf2009.serenity.dto.L2Update
import com.sirolf2009.serenity.dto.L2Update.L2UpdateEntry
import com.sirolf2009.serenity.dto.Side
import com.sirolf2009.serenity.dto.UpdateType
import java.util.Optional
import java.util.function.Function
import org.apache.logging.log4j.LogManager

class L2UpdateParser extends Parser implements Function<JsonObject, Optional<IL2Update>> {
	
	static val log = LogManager.logger

	override apply(JsonObject object) {
		try {
			val type = UpdateType.valueOf(object.string("type").toUpperCase())
			if(type === UpdateType.SNAPSHOT) {
				val productID = object.string("product_id")
				val bids = object.getAsJsonArray("bids").map[asJsonArray].map[new L2SnapshotEntry(get(0).getAsDouble(), get(1).getAsDouble())].toList()
				val asks = object.getAsJsonArray("asks").map[asJsonArray].map[new L2SnapshotEntry(get(0).getAsDouble(), get(1).getAsDouble())].toList()
				return Optional.of(new L2Snapshot(productID, bids, asks))
			} else if(type === UpdateType.L2UPDATE) {
				val productID = object.string("product_id")
				val changes = object.getAsJsonArray("changes").map[asJsonArray].map[new L2UpdateEntry(Side.valueOf(get(0).getAsString().toUpperCase()), get(1).getAsDouble(), get(2).getAsDouble())].toList()
				return Optional.of(new L2Update(productID, changes))
			}
		} catch(Exception e) {
			log.warn("Unknown object: "+object, e)
		}
		return Optional.empty()
	}
}