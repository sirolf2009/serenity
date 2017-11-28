package com.sirolf2009.trading.parts

import com.sirolf2009.trading.Activator
import com.sirolf2009.trading.IExchangePart
import java.text.DecimalFormat
import java.util.ArrayList
import java.util.List
import java.util.Optional
import javax.annotation.PostConstruct
import org.eclipse.e4.ui.di.Focus
import org.eclipse.swt.SWT
import org.eclipse.swt.events.ControlEvent
import org.eclipse.swt.events.ControlListener
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Table
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.swt.widgets.TableItem
import org.eclipse.xtend.lib.annotations.Data
import org.knowm.xchange.dto.trade.LimitOrder

class Orderbook implements IExchangePart {

	val List<Entry> entries = new ArrayList()
	var Table table
	var TableColumn bidPrice
	var TableColumn bidAmount
	var TableColumn bidCumAmount
	var TableColumn askPrice
	var TableColumn askAmount
	var TableColumn askCumAmount

	@PostConstruct
	def void createPartControl(Composite parent) {
		val green = parent.display.getSystemColor(SWT.COLOR_DARK_GREEN)
		val red = parent.display.getSystemColor(SWT.COLOR_DARK_RED)
		val brightGreen = new Color(null, 0, green.green + 40, 0)
		val brightRed = new Color(null, red.red + 40, 0, 0)
		val gray = parent.display.getSystemColor(SWT.COLOR_GRAY)
		val comp = new Composite(parent, SWT.NONE)
		val numberformat = new DecimalFormat("#########0.##")

		table = new Table(comp, SWT.VIRTUAL) => [ table |
			table.headerVisible = true
			table.background = gray
			table.addListener(SWT.SetData) [
				val item = item as TableItem
				val index = table.indexOf(item)
				item.text = #[
					entries.get(index).bid.map[limitPrice.toString()].orElse(""),
					entries.get(index).bid.map[remainingAmount.toString()].orElse(""),
					numberformat.format(entries.get(index).cumulativeBid),
					numberformat.format(entries.get(index).cumulativeAsk),
					entries.get(index).ask.map[remainingAmount.negate.toString()].orElse(""),
					entries.get(index).ask.map[limitPrice.toString()].orElse("")
				]
				item.setBackground(0, green)
				item.setBackground(1, green)
				item.setBackground(2, green)
				item.setBackground(3, red)
				item.setBackground(4, red)
				item.setBackground(5, red)
			]
			bidPrice = new TableColumn(table, SWT.NONE)
			bidPrice.text = "Price"
			bidAmount = new TableColumn(table, SWT.NONE)
			bidAmount.text = "Amount"
			bidCumAmount = new TableColumn(table, SWT.NONE)
			bidCumAmount.text = "Cumulative"
			askCumAmount = new TableColumn(table, SWT.NONE)
			askCumAmount.text = "Cumulative"
			askAmount = new TableColumn(table, SWT.NONE)
			askAmount.text = "Amount"
			askPrice = new TableColumn(table, SWT.NONE)
			askPrice.text = "Price"

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
						bidPrice.setWidth(width / 6)
						bidAmount.setWidth(width / 6)
						bidCumAmount.setWidth(width / 6)
						askPrice.setWidth(width / 6)
						askAmount.setWidth(width / 6)
						askCumAmount.setWidth(width / 6)
						table.setSize(area.width, area.height)
					} else {
						table.setSize(area.width, area.height)
						bidPrice.setWidth(width / 6)
						bidAmount.setWidth(width / 6)
						bidCumAmount.setWidth(width / 6)
						askPrice.setWidth(width / 6)
						askAmount.setWidth(width / 6)
						askCumAmount.setWidth(width / 6)
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
					val size = entries.get(index).bid.map[originalAmount.intValue * 2].orElse(0)
					gc.fillRectangle(x, y, width - 1, height - 1)
					gc.background = brightGreen
					gc.fillRectangle(x, y, size, height - 1)
					gc.background = background
					gc.drawText(item.getText(0), x + 4, y + 2, true)
				} else if(it.index == 2) {
					val size = entries.get(index).cumulativeBid.intValue
					gc.fillRectangle(x, y, width - 1, height - 1)
					gc.background = brightGreen
					gc.fillRectangle(x + bidAmount.width - size - 1, y, size, height - 1)
					gc.background = background
					gc.drawText(item.getText(2), x + 4, y + 2, true)
				} else if(it.index == 3) {
					val size = entries.get(index).cumulativeAsk.intValue
					gc.fillRectangle(x, y, width - 1, height - 1)
					gc.background = brightRed
					gc.fillRectangle(x, y, size, height - 1)
					gc.background = background
					gc.drawText(item.getText(3), x + 4, y + 2, true)
				} else if(it.index == 5) {
					val size = entries.get(index).ask.map[originalAmount.intValue * -2].orElse(0)
					gc.fillRectangle(x, y, width - 1, height - 1)
					gc.background = brightRed
					gc.fillRectangle(x + askAmount.width - size, y, size, height - 1)
					gc.background = background
					gc.drawText(item.getText(5), x + 4, y + 2, true)
				}
				gc.background = background
			]
		]
		
		orderbook.subscribe [
			if(table.isDisposed) {
				Activator.exchange.disconnect()
				return
			}
			val orders = (0 ..< Math.max(bids.size(), asks.size())).map [ index |
				val bid = if(index < bids.size()) Optional.of(bids.get(index)) else Optional.empty()
				val ask = if(index < asks.size()) Optional.of(asks.get(index)) else Optional.empty()
				return bid -> ask
			].toList()
			val newEntries = orders.map [
				val cumulativeBid = (0 .. orders.indexOf(it)).map[orders.get(it).key.map[originalAmount.doubleValue].orElse(0d)].reduce[a, b|a + b]
				val cumulativeAsk = (0 .. orders.indexOf(it)).map[orders.get(it).value.map[originalAmount.doubleValue * -1].orElse(0d)].reduce[a, b|a + b]
				return new Entry(key, cumulativeBid, value, cumulativeAsk)
			]
			parent.display.syncExec [
				if(table.isDisposed) {
					Activator.exchange.disconnect()
					return
				}
				entries.clear()
				entries.addAll(newEntries)
				table.clearAll()
				table.itemCount = newEntries.size()
			]
		]
	}

	@Focus
	def void setFocus() {
		table.setFocus()
	}
	
	@Data static class Entry {
		val Optional<LimitOrder> bid
		val Double cumulativeBid
		val Optional<LimitOrder> ask
		val Double cumulativeAsk
	}

}
