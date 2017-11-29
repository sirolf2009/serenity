package com.sirolf2009.trading.parts

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.trading.IExchangePart
import java.util.HashMap
import javax.annotation.PostConstruct
import org.eclipse.swt.SWT
import org.eclipse.swt.events.ControlEvent
import org.eclipse.swt.events.ControlListener
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Table
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.swt.widgets.TableItem
import org.eclipse.xtend.lib.annotations.Data

class VolumeByPrice implements IExchangePart {

	val map = new HashMap<Double, Entry>()
	val max = new AtomicDouble(0)
	var Table table
	var TableColumn price
	var TableColumn amount

	@PostConstruct
	def void createPartControl(Composite parent) {
		val green = parent.display.getSystemColor(SWT.COLOR_DARK_GREEN)
		val red = parent.display.getSystemColor(SWT.COLOR_DARK_RED)
		val brightGreen = new Color(parent.display, 0, green.green + 40, 0)
		val brightRed = new Color(parent.display, red.red + 40, 0, 0)
		val gray = parent.display.getSystemColor(SWT.COLOR_GRAY)
		val comp = new Composite(parent, SWT.NONE)
		table = new Table(comp, SWT.VIRTUAL) => [ table |
			table.headerVisible = true
			table.linesVisible = true
			table.background = gray
			table.addListener(SWT.SetData) [
				val item = item as TableItem
				val index = table.indexOf(item)
				val price = this.map.keySet.sort.reverse.get(index)
				val entry = map.get(price)
				item.text = #[price.toString(), (entry.buyAmount + entry.sellAmount).toString()]
			]
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
						price.setWidth(width / 2)
						amount.setWidth(width / 2)
						table.setSize(area.width, area.height)
					} else {
						table.setSize(area.width, area.height)
						price.setWidth(width / 2)
						amount.setWidth(width / 2)
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
					val price = this.map.keySet.sort.reverse.get(index)
					val entry = this.map.get(price)
					val amount = entry.buyAmount + entry.sellAmount
					val largestAmount = max.get()
					val size = amount / largestAmount * this.price.width
					val buySize = entry.buyAmount / largestAmount * this.price.width
					val sellSize = size-buySize
					gc.fillRectangle(x, y, width - 1, height - 1)
					gc.background = brightGreen
					gc.fillRectangle(x, y, buySize.intValue(), height - 1)
					gc.background = brightRed
					gc.fillRectangle(buySize.intValue(), y, sellSize.intValue(), height - 1)
					gc.background = background
					gc.drawText(item.getText(0), x + 4, y + 2, true)
				}
				gc.background = background
			]
		]
		trades.subscribe [
			if(table.disposed) {
				return
			}
			val price = Math.round(it.price.doubleValue()/10.0) * 10d
			val amount = it.originalAmount.doubleValue()
			val existing = map.get(price)
			val newEntry = if(existing !== null) {
					if(amount > 0) {
						new Entry(existing.buyAmount + amount, existing.sellAmount)
					} else {
						new Entry(existing.buyAmount, existing.sellAmount - amount)
					}
				} else {
					if(amount > 0) {
						new Entry(amount, 0)
					} else {
						new Entry(0, -amount)
					}
				}
			map.put(price, newEntry)
			if(newEntry.buyAmount + newEntry.sellAmount > max.get()) {
				max.set(newEntry.buyAmount + newEntry.sellAmount)
			}
			parent.display.syncExec [
				if(table.disposed) {
					return
				}
				table.clearAll()
				table.itemCount = map.keySet.size()
				table.topIndex = map.keySet.sort.reverse.indexOf(newEntry)
			]
		]
	}

	@Data
	static class Entry {
		double buyAmount
		double sellAmount
	}

}
