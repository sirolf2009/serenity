package com.sirolf2009.serenity.dto

import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

/**
 * An order has changed. 
 * This is the result of self-trade prevention adjusting the order size or available funds. 
 * Orders can only decrease in size or funds. 
 * change messages are sent anytime an order changes in size; this includes resting orders (open) as well as received but not yet open. 
 * change messages are also sent when a new market order goes through self trade prevention and the funds for the market order have changed.
 */
@Data class UpdateChange extends AbstractUpdate {
	
	val type = UpdateType.CHANGE
	val UUID orderID
	val double newSize
	val double oldSize
	val double price
	val Side side
	
}