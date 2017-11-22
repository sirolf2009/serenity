package com.sirolf2009.serenity.dto

import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data abstract class AbstractUpdate implements IUpdate {
	
	val Date time
	val String productID
	val long sequence
	
}