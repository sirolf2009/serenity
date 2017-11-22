package com.sirolf2009.serenity

import com.google.gson.Gson
import org.junit.Test
import com.google.gson.JsonObject
import com.sirolf2009.serenity.dto.UpdateOpen
import org.junit.Assert
import com.sirolf2009.serenity.dto.UpdateDone
import com.sirolf2009.serenity.dto.UpdateMatch
import com.sirolf2009.serenity.dto.UpdateChange
import java.nio.file.Files
import java.nio.file.Paths

class TestUpdateParser {
	
	@Test
	def void testExampleUpdates() {
		val gson = new Gson()
		val parser = new UpdateParser()
		Files.readAllLines(Paths.get("src/test/resources/example_response")).forEach[
			println(parser.apply(gson.fromJson(it, JsonObject)))
		]
	}
	
	@Test
	def void testUpdateOpen() {
		val gson = new Gson()
		val parser = new UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
			"type":"open",
			"side":"buy",
			"price":"7156.85000000",
			"order_id":"b8e8ebdd-9480-4c48-a69e-40871c3ef8b6",
			"remaining_size":"0.66000000",
			"product_id":"BTC-EUR",
			"sequence":2934264449,
			"time":"2017-11-22T08:45:10.919000Z"
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof UpdateOpen)
		Assert.assertEquals(7156.85, (parsed as UpdateOpen).price, 0.0001d)
	}
	
	@Test
	def void testUpdateDone() {
		val gson = new Gson()
		val parser = new UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
			"type":"done",
			"side":"buy",
			"order_id":"15d15d4c-1822-44d6-9d38-dac351379781",
			"reason":"canceled",
			"product_id":"BTC-EUR",
			"price":"7155.02000000",
			"remaining_size":"0.08892208",
			"sequence":2934264446,
			"time":"2017-11-22T08:45:10.903000Z"
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof UpdateDone)
		Assert.assertEquals(7155.02, (parsed as UpdateDone).price, 0.0001d)
	}
	
	@Test
	def void testUpdateMatch() {
		val gson = new Gson()
		val parser = new UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
			"type":"match",
			"trade_id":5570161,
			"maker_order_id":"1c2afd6d-8bc6-4257-93b5-6b50655c7c19",
			"taker_order_id":"5c9d7212-5d55-4761-8e31-6b3d400b98d0",
			"side":"sell",
			"size":"0.10000000",
			"price":"7160.00000000",
			"product_id":"BTC-EUR",
			"sequence":2934264460,
			"time":"2017-11-22T08:45:11.575000Z"
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof UpdateMatch)
		Assert.assertEquals(7160.00, (parsed as UpdateMatch).price, 0.0001d)
	}
	
	@Test
	def void testUpdateChange() {
		val gson = new Gson()
		val parser = new UpdateParser()
		val parsed = parser.apply(gson.fromJson('''{
		    "type": "change",
		    "time": "2014-11-07T08:19:27.028459Z",
		    "sequence": 80,
		    "order_id": "ac928c66-ca53-498f-9c13-a110027a60e8",
		    "product_id": "BTC-USD",
		    "new_size": "5.23512",
		    "old_size": "12.234412",
		    "price": "400.23",
		    "side": "sell"
		}''', JsonObject)).get()
		Assert.assertTrue(parsed instanceof UpdateChange)
		Assert.assertEquals(400.23, (parsed as UpdateChange).price, 0.0001d)
	}
	
}