package com.sirolf2009.serenity.dto

import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

/**
 * A trade occurred between two orders. 
 * The aggressor or taker order is the one executing immediately after being received and the maker order is a resting order on the book. 
 * The side field indicates the maker order side. 
 * If the side is sell this indicates the maker was a sell order and the match is considered an up-tick. 
 * A buy side match is a down-tick.
 */
@Data class UpdateMatch extends AbstractUpdate {
	
	val type = UpdateType.MATCH
	val long tradeID
	val UUID makerOrderID
	val UUID takerOrderID
	val double size
	val double price
	val Side side
	
}