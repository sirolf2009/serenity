package com.sirolf2009.trading.parts

import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.swtchart.Chart
import org.swtchart.ISeries.SeriesType
import org.swtchart.internal.series.LineSeries
import org.swtchart.ILineSeries.PlotSymbolType

class ChartPart {
	
	public static val red = new Color(null, 255, 0, 0)
	public static val green = new Color(null, 0, 255, 0)
	public static val blue = new Color(null, 0, 0, 255) 
	
	def createChart(Composite parent) {
		new Chart(parent, SWT.NONE) => [
			title.text = ""
			backgroundInPlotArea = new Color(parent.display, 0, 0, 0)
			title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getXAxis(0).title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getXAxis(0).tick.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).title.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).tick.foreground = new Color(parent.display, 255, 255, 255)
			axisSet.getYAxis(0).title.text = ""
			axisSet.getXAxis(0).title.text = ""
		]
	}
	
	def createLineSeries(Chart chart, String name) {
		return chart.seriesSet.createSeries(SeriesType.LINE, name) as LineSeries => [
			symbolType = PlotSymbolType.NONE
		]
	}
	
	def xAxis(Chart chart) {
		return chart.axisSet.XAxes.get(0)
	}
	
	def yAxis(Chart chart) {
		return chart.axisSet.YAxes.get(0)
	}
	
}