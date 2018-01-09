package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.util.List
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.swt.SWT
import org.eclipse.swt.events.ControlEvent
import org.eclipse.swt.events.ControlListener
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Table
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.swt.widgets.TableItem
import org.eclipse.ui.part.ViewPart

class GannSquare extends ViewPart implements IExchangePart {

	val GannMatrix matrix = new Gann7()
	val ltp = new AtomicInteger()
	val data = new AtomicReference<List<Double>>()

	var Table table

	override createPartControl(Composite comp) {
		val blue = new Color(comp.display, 0, 0, 255)
		val grayer = new Color(comp.display, 100, 100, 100)
		val center = Math.floor(matrix.size/2).intValue
		table = new Table(comp, SWT.VIRTUAL) => [ table |
			table.headerVisible = false
			table.linesVisible = true
			table.addListener(SWT.SetData) [
				val item = item as TableItem
				val y = table.indexOf(item)
				item.text = (0 ..< matrix.getSize()).map[matrix.getIndex(it, y) - 1].map[data.get().get(it) + ""]
				(0 ..< matrix.getSize()).forEach[x|
					if(matrix.getIndex(x, y) == ltp.get()) {
						item.setBackground(x, blue)						
					} else if(x == center || y == center) {
						item.setBackground(x, grayer)
					}
				]
			]
		]
		val columns = (0 ..< matrix.getSize()).map [
			new TableColumn(table, SWT.NONE)
		].toList()
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
				val availableWidth = width
				val oldSize = table.getSize()
				if(oldSize.x > area.width) {
					columns.forEach[it.width = availableWidth / columns.size()]
					table.setSize(area.width, area.height)
				} else {
					table.setSize(area.width, area.height)
					columns.forEach[it.width = availableWidth / columns.size()]
				}
			}

			override controlMoved(ControlEvent e) {
			}

		})
		trades.subscribe [
			if(table.disposed) {
				return
			}
			point.y.doubleValue.gann()
			comp.display.syncExec [
				if(table.disposed) {
					return
				}
				table.clearAll()
				table.itemCount = matrix.getSize()
			]
		]
	}

	def gann(double ltp) {
		val sqrt = Math.sqrt(ltp)
		val twoDown = Math.floor(sqrt) - 1
		data.set((0 ..< matrix.getSize() * matrix.getSize()).map[gann(twoDown, it)].toList())
		val closest = data.get().min [ a, b |
			Math.abs(ltp - a).compareTo(Math.abs(ltp - b))
		]
		this.ltp.set(data.get().indexOf(closest))
	}

	def gann(double twoDown, int index) {
		Math.pow(twoDown + 0.125 * index, 2)
	}

	override setFocus() {
		table.setFocus
	}

	static interface GannMatrix {
		def int getSize()

		def int getIndex(int x, int y)
	}

	static class Gann7 implements GannMatrix {

		static val matrix = #[
			// 0  1  2  3  4  5  6
			#[31, 32, 33, 34, 35, 36, 37], // 0
			#[30, 13, 14, 15, 16, 17, 38], // 1
			#[29, 12, 03, 04, 05, 18, 39], // 2
			#[28, 11, 02, 01, 06, 19, 40], // 3
			#[27, 10, 09, 08, 07, 20, 41], // 4
			#[26, 25, 24, 23, 22, 21, 42], // 5
			#[49, 48, 47, 46, 45, 44, 43] // 6
		]

		override getSize() {
			return 7
		}

		override getIndex(int x, int y) {
			return matrix.get(x).get(y)
		}

	}

}
