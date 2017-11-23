package com.sirolf2009.serenity.parser

import org.junit.Test
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.L2Snapshot
import junit.framework.Assert
import com.sirolf2009.serenity.dto.L2Update
import com.sirolf2009.serenity.dto.Side

class TestL2UpdateParser {
	
	@Test
	def void testSnapshot() {
		val gson = new Gson()
		val parser = new L2UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
		    "type": "snapshot",
		    "product_id": "BTC-EUR",
		    "bids": [["1", "2"]],
		    "asks": [["2", "3"]]
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof L2Snapshot)
		Assert.assertEquals(1, (parsed as L2Snapshot).bids.get(0).price, 0.0001d)
		Assert.assertEquals(2, (parsed as L2Snapshot).bids.get(0).size, 0.0001d)
	}
	
	@Test
	def void testL2Update() {
		val gson = new Gson()
		val parser = new L2UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
		    "type": "l2update",
		    "product_id": "BTC-EUR",
		    "changes": [
		        ["buy", "1", "3"],
		        ["sell", "3", "1"],
		        ["sell", "2", "2"],
		        ["sell", "4", "0"]
		    ]
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof L2Update)
		Assert.assertEquals(Side.BUY, (parsed as L2Update).changes.get(0).side)
		Assert.assertEquals(1, (parsed as L2Update).changes.get(0).price, 0.0001d)
		Assert.assertEquals(3, (parsed as L2Update).changes.get(0).size, 0.0001d)
		Assert.assertEquals(Side.SELL, (parsed as L2Update).changes.get(1).side)
		Assert.assertEquals(3, (parsed as L2Update).changes.get(1).price, 0.0001d)
		Assert.assertEquals(1, (parsed as L2Update).changes.get(1).size, 0.0001d)
	}
	
}