package com.sirolf2009.serenity.dto

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class L2Update implements IL2Update {
	
	val type = UpdateType.L2UPDATE
	val String productID
	val List<L2UpdateEntry> changes
	
	@Data static class L2UpdateEntry {
		
		val Side side
		val double price
		val double size
		
	}
	
}