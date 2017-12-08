package com.sirolf2009.trading.parts

import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.swtchart.Chart
import org.swtchart.ILineSeries.PlotSymbolType
import org.swtchart.ISeries.SeriesType
import org.swtchart.internal.series.LineSeries
import org.swtchart.internal.series.BarSeries

class ChartPart {
	
	public static val red = new Color(null, 255, 0, 0)
	public static val green = new Color(null, 0, 255, 0)
	public static val blue = new Color(null, 0, 0, 255) 
	public static val white = new Color(null, 255, 255, 255)
	public static val black = new Color(null, 0, 0, 0)
	
	def createChart(Composite parent) {
		new Chart(parent, SWT.NONE) => [
			backgroundInPlotArea = black
			title.foreground = white
			title.text = ""
			xAxis.tick.foreground = white
			xAxis.title.foreground = white
			xAxis.title.text = ""
			yAxis.tick.foreground = white
			yAxis.title.foreground = white
			yAxis.title.text = ""
		]
	}
	
	def createLineSeries(Chart chart, String name) {
		return chart.seriesSet.createSeries(SeriesType.LINE, name) as LineSeries => [
			symbolType = PlotSymbolType.NONE
		]
	}
	
	def createBarSeries(Chart chart, String name) {
		return chart.seriesSet.createSeries(SeriesType.BAR, name) as BarSeries => [
		]
	}
	
	def xAxis(Chart chart) {
		return chart.axisSet.XAxes.get(0)
	}
	
	def yAxis(Chart chart) {
		return chart.axisSet.YAxes.get(0)
	}
	
}