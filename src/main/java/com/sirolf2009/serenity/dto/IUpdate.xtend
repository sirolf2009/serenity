package com.sirolf2009.serenity.dto

import java.util.Date

interface IUpdate {
	
	def UpdateType getType()
	def Date getTime()
	def String getProductID()
	def long getSequence()
	
}