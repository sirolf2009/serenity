package com.sirolf2009.serenity.dto

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class L2Snapshot implements IL2Update {
	
	val type = UpdateType.SNAPSHOT
	val String productID
	val List<L2SnapshotEntry> bids
	val List<L2SnapshotEntry> asks
	
	@Data static class L2SnapshotEntry {
		
		val double price
		val double size
		
	}
	
}