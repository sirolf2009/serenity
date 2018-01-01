package com.sirolf2009.trading.parts

import com.sirolf2009.commonwealth.indicator.line.ILineIndicator
import com.sirolf2009.trading.SerenityChart
import com.sirolf2009.trading.SerenityChart.Indicator
import java.util.Date
import java.util.HashMap
import java.util.UUID
import org.apache.commons.collections4.queue.CircularFifoQueue
import org.eclipse.swt.dnd.DND
import org.eclipse.swt.dnd.DragSource
import org.eclipse.swt.dnd.DragSourceEvent
import org.eclipse.swt.dnd.DragSourceListener
import org.eclipse.swt.dnd.DropTarget
import org.eclipse.swt.dnd.DropTargetEvent
import org.eclipse.swt.dnd.DropTargetListener
import org.eclipse.swt.dnd.TextTransfer
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class IndicatorChart extends ViewPart {

	static val aether = new HashMap<String, Indicator>

	val ILineIndicator formula
	val Color color
	val String name
	var SerenityChart chart

	override createPartControl(Composite parent) {
		chart = new SerenityChart(parent)
		
		val indicator = chart.addIndicator(formula, color, name)

		new DragSource(chart, DND.DROP_MOVE.bitwiseOr(DND.DROP_COPY)) => [
			val types = #[TextTransfer.getInstance()]
			setTransfer(types)
			addDragListener(new DragSourceListener() {

				override dragFinished(DragSourceEvent event) {
				}

				override dragSetData(DragSourceEvent event) {
					val key = UUID.randomUUID().toString()
					aether.put(key, indicator)
					event.data = key.toString()
				}

				override dragStart(DragSourceEvent event) {
				}

			})
		]

		new DropTarget(chart, DND.DROP_MOVE.bitwiseOr(DND.DROP_COPY)) => [
			val transfer = TextTransfer.instance
			val types = #[transfer]
			setTransfer(types)
			addDropListener(new DropTargetListener() {

				override dragEnter(DropTargetEvent event) {
				}

				override dragLeave(DropTargetEvent event) {
				}

				override dragOperationChanged(DropTargetEvent event) {
				}

				override dragOver(DropTargetEvent event) {
				}

				override drop(DropTargetEvent event) {
					if(transfer.isSupportedType(event.currentDataType)) {
						val key = event.data as String
						val indicator = aether.get(key)
						println("Adding "+indicator.line.id)
						val xData = new CircularFifoQueue<Date>(indicator.XData.maxSize)
						val yData = new CircularFifoQueue<Double>(indicator.YData.maxSize)
						chart.addIndicator(indicator.formula, indicator.line.lineColor, indicator.line.id, xData, yData)
					}
				}

				override dropAccept(DropTargetEvent event) {
				}

			})
		]
	}

	override setFocus() {
		chart.setFocus()
	}

}
