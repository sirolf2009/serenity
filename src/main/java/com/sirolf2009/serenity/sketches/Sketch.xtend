package com.sirolf2009.serenity.sketches

import grafica.GPlot
import processing.core.PApplet
import org.apache.commons.math3.analysis.interpolation.SplineInterpolator
import grafica.GLayer
import grafica.GPointsArray
import org.apache.commons.math3.fitting.PolynomialCurveFitter
import org.apache.commons.math3.fitting.WeightedObservedPoint
import org.apache.commons.math3.analysis.polynomials.PolynomialFunction

class Sketch extends PApplet {

	def darkPlot() {
		new GPlot(this) => [
			setPos(0, 0)
			setOuterDim(width, height)
			fontColor = 255
			boxBgColor = 0
			bgColor = 0
			lineColor = 200
			lineWidth = 0.5f
			title.fontColor = 255
			XAxis.fontColor = 255
			XAxis.lineColor = 255
			XAxis.axisLabel.fontColor = 255
			YAxis.fontColor = 255
			YAxis.lineColor = 255
			YAxis.axisLabel.fontColor = 255
			rightAxis.fontColor = 255
			rightAxis.lineColor = 255
			rightAxis.axisLabel.fontColor = 255
			topAxis.fontColor = 255
			topAxis.lineColor = 255
			topAxis.axisLabel.fontColor = 255
		]
	}

	def interpolate(GPlot plot) {
		plot.removeLayer("Interpolated")
		plot.addLayer("Interpolated", plot.mainLayer.interpolate())
	}

	def interpolate(GLayer layer) {
		if(layer.points.NPoints > 2) {
			val interpolator = new SplineInterpolator()
			val xValues = (0 ..< layer.points.NPoints).map[layer.points.getX(it).doubleValue()]
			val yValues = (0 ..< layer.points.NPoints).map[layer.points.getY(it).doubleValue()]
			val interpolated = interpolator.interpolate(xValues, yValues)
			val series = new GPointsArray()
			xValues.toSet().forEach [
				series.add(floatValue, interpolated.value(it).floatValue)
			]
			return series
		} else {
			return new GPointsArray()
		}
	}

	def curveFit(GPlot plot) {
		plot.removeLayer("Fitted")
		plot.addLayer("Fitted", plot.mainLayer.curveFit())
	}

	def curveFit(GLayer layer) {
		if(layer.points.NPoints > 0) {
			val fitter = PolynomialCurveFitter.create(32)
			val points = (0 ..< layer.points.NPoints).map [
				new WeightedObservedPoint(1, layer.points.getX(it).doubleValue(), layer.points.getY(it).doubleValue())
			].toList()
			val fitted = new PolynomialFunction(fitter.fit(points))
			val xValues = (0 ..< layer.points.NPoints).map[layer.points.getX(it).doubleValue()]
			val series = new GPointsArray()
			xValues.toSet().forEach [
				series.add(floatValue, fitted.value(it).floatValue)
			]
			return series
		}
	}

}
