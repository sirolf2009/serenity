package com.sirolf2009.serenity.dto

import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

/**
 * The order is now open on the order book. 
 * This message will only be sent for orders which are not fully filled immediately. 
 * remaining_size will indicate how much of the order is unfilled and going on the book.
 */
@Data class UpdateOpen extends AbstractUpdate {
	
	val type = UpdateType.OPEN
	val UUID orderID
	val double price
	val double remainingSize
	val Side side
	
}