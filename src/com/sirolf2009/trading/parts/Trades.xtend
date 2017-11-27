package com.sirolf2009.trading.parts

import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange
import info.bitrich.xchangestream.core.StreamingExchangeFactory
import javax.annotation.PostConstruct
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Table
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.Trade
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.swt.widgets.TableItem
import org.eclipse.swt.events.ControlListener
import org.eclipse.swt.events.ControlEvent
import java.text.SimpleDateFormat
import org.eclipse.swt.graphics.Color

class Trades {

	val buffer = new CircularFifoQueue<Trade>(512)
	var Table table
	var TableColumn time
	var TableColumn price
	var TableColumn amount

	@PostConstruct
	def void createPartControl(Composite parent) {
		val green = parent.display.getSystemColor(SWT.COLOR_DARK_GREEN)
		val red = parent.display.getSystemColor(SWT.COLOR_DARK_RED)
		val brightGreen = new Color(null, 0, green.green + 40, 0)
		val brightRed = new Color(null, red.red + 40, 0, 0)
		val gray = parent.display.getSystemColor(SWT.COLOR_GRAY)
		val comp = new Composite(parent, SWT.NONE)
		val sdf = new SimpleDateFormat("HH:mm:ss")
		table = new Table(comp, SWT.VIRTUAL) => [ table |
			table.headerVisible = true
			table.linesVisible = true
			table.background = gray
			table.addListener(SWT.SetData) [
				val item = item as TableItem
				val index = table.indexOf(item)
				val trade = buffer.get(buffer.size() - 1 - index)
				item.text = #[sdf.format(trade.timestamp), trade.price.toString(), trade.originalAmount.abs.toString()]
				val color = if(trade.originalAmount.doubleValue > 0) green else red
				item.setBackground(0, color)
				item.setBackground(1, color)
				item.setBackground(2, color)
			]
			time = new TableColumn(table, SWT.NONE)
			time.text = "Time"
			price = new TableColumn(table, SWT.NONE)
			price.text = "Price"
			amount = new TableColumn(table, SWT.NONE)
			amount.text = "Amount"

			comp.addControlListener(new ControlListener() {

				override controlResized(ControlEvent e) {
					val area = comp.clientArea
					val size = table.computeSize(SWT.DEFAULT, SWT.DEFAULT)
					val vBar = table.verticalBar
					var width = area.width - table.computeTrim(0, 0, 0, 0).width - vBar.size.x
					if(size.y > area.height + table.getHeaderHeight()) {
						val vBarSize = vBar.getSize()
						width -= vBarSize.x
					}
					val oldSize = table.getSize()
					if(oldSize.x > area.width) {
						time.setWidth(width / 3)
						price.setWidth(width / 3)
						amount.setWidth(width / 3)
						table.setSize(area.width, area.height)
					} else {
						table.setSize(area.width, area.height)
						time.setWidth(width / 3)
						price.setWidth(width / 3)
						amount.setWidth(width / 3)
					}
				}

				override controlMoved(ControlEvent e) {
				}

			})

			table.addListener(SWT.PaintItem) [
				val background = gc.background

				val item = item as TableItem
				val index = table.indexOf(item)
				if(it.index == 0) {
					val size = buffer.get(buffer.size() - 1 - index).originalAmount.intValue * 2
					gc.fillRectangle(x, y, width - 1, height - 1)
					if(size > 0) {
						gc.background = brightGreen
						gc.fillRectangle(x, y, size, height - 1)
					} else {
						gc.background = brightRed
						gc.fillRectangle(x, y, size*-1, height - 1)
					}
					gc.background = background
					gc.drawText(item.getText(0), x + 4, y + 2, true)
				}
				gc.background = background
			]
		]
		val exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.name)
		exchange.connect().blockingAwait()
		exchange.streamingMarketDataService.getTrades(CurrencyPair.BTC_USD).subscribe [
			if(table.disposed) {
				exchange.disconnect()
				return
			}
			buffer.add(it)
			parent.display.syncExec [
				if(table.disposed) {
					exchange.disconnect()
					return
				}
				table.clearAll()
				table.itemCount = buffer.size()
			]
		]
	}
}
