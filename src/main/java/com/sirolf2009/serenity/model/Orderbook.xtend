package com.sirolf2009.serenity.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Orderbook {
	
	val List<Order> bids
	val List<Order> asks
	
}