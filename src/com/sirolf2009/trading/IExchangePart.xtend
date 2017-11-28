package com.sirolf2009.trading

interface IExchangePart {
		
	def getOrderbook() {
		while(Activator.orderbook === null) {
			Thread.sleep(100)
		}
		return Activator.orderbook
	}
	
	def getTrades() {
		while(Activator.trades === null) {
			Thread.sleep(100)
		}
		return Activator.trades
	}
	
}