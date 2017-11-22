package com.sirolf2009.serenity.dto

import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

/**
 * The order is no longer on the order book. Sent for all orders for which there was a received message. 
 * This message can result from an order being canceled or filled. There will be no more messages for this order_id after a done message. 
 * remaining_size indicates how much of the order went unfilled; this will be 0 for filled orders.
 * market orders will not have a remaining_size or price field as they are never on the open order book at a given price.
 */
@Data class UpdateDone extends AbstractUpdate {
	
	val type = UpdateType.DONE
	val UUID orderID
	val double price
	val Reason reason
	val Side side
	val double remaining_size
	
}