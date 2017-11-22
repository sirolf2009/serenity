package com.sirolf2009.serenity.sketches;

import grafica.GAxis;
import grafica.GAxisLabel;
import grafica.GLayer;
import grafica.GPlot;
import grafica.GPointsArray;
import grafica.GTitle;
import java.util.List;
import java.util.function.Consumer;
import org.apache.commons.math3.analysis.interpolation.SplineInterpolator;
import org.apache.commons.math3.analysis.polynomials.PolynomialFunction;
import org.apache.commons.math3.analysis.polynomials.PolynomialSplineFunction;
import org.apache.commons.math3.fitting.PolynomialCurveFitter;
import org.apache.commons.math3.fitting.WeightedObservedPoint;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import processing.core.PApplet;

@SuppressWarnings("all")
public class Sketch extends PApplet {
  public GPlot darkPlot() {
    GPlot _gPlot = new GPlot(this);
    final Procedure1<GPlot> _function = new Procedure1<GPlot>() {
      @Override
      public void apply(final GPlot it) {
        it.setPos(0, 0);
        it.setOuterDim(Sketch.this.width, Sketch.this.height);
        it.setFontColor(255);
        it.setBoxBgColor(0);
        it.setBgColor(0);
        it.setLineColor(200);
        it.setLineWidth(0.5f);
        GTitle _title = it.getTitle();
        _title.setFontColor(255);
        GAxis _xAxis = it.getXAxis();
        _xAxis.setFontColor(255);
        GAxis _xAxis_1 = it.getXAxis();
        _xAxis_1.setLineColor(255);
        GAxisLabel _axisLabel = it.getXAxis().getAxisLabel();
        _axisLabel.setFontColor(255);
        GAxis _yAxis = it.getYAxis();
        _yAxis.setFontColor(255);
        GAxis _yAxis_1 = it.getYAxis();
        _yAxis_1.setLineColor(255);
        GAxisLabel _axisLabel_1 = it.getYAxis().getAxisLabel();
        _axisLabel_1.setFontColor(255);
      }
    };
    return ObjectExtensions.<GPlot>operator_doubleArrow(_gPlot, _function);
  }
  
  public void interpolate(final GPlot plot) {
    plot.removeLayer("Interpolated");
    plot.addLayer("Interpolated", this.interpolate(plot.getMainLayer()));
  }
  
  public GPointsArray interpolate(final GLayer layer) {
    final SplineInterpolator interpolator = new SplineInterpolator();
    int _nPoints = layer.getPoints().getNPoints();
    final Function1<Integer, Double> _function = new Function1<Integer, Double>() {
      @Override
      public Double apply(final Integer it) {
        return Double.valueOf(Float.valueOf(layer.getPoints().getX((it).intValue())).doubleValue());
      }
    };
    final Iterable<Double> xValues = IterableExtensions.<Integer, Double>map(new ExclusiveRange(0, _nPoints, true), _function);
    int _nPoints_1 = layer.getPoints().getNPoints();
    final Function1<Integer, Double> _function_1 = new Function1<Integer, Double>() {
      @Override
      public Double apply(final Integer it) {
        return Double.valueOf(Float.valueOf(layer.getPoints().getY((it).intValue())).doubleValue());
      }
    };
    final Iterable<Double> yValues = IterableExtensions.<Integer, Double>map(new ExclusiveRange(0, _nPoints_1, true), _function_1);
    final PolynomialSplineFunction interpolated = interpolator.interpolate(((double[])Conversions.unwrapArray(xValues, double.class)), ((double[])Conversions.unwrapArray(yValues, double.class)));
    final GPointsArray series = new GPointsArray();
    final Consumer<Double> _function_2 = new Consumer<Double>() {
      @Override
      public void accept(final Double it) {
        series.add(it.floatValue(), Double.valueOf(interpolated.value((it).doubleValue())).floatValue());
      }
    };
    IterableExtensions.<Double>toSet(xValues).forEach(_function_2);
    return series;
  }
  
  public void curveFit(final GPlot plot) {
    plot.removeLayer("Fitted");
    plot.addLayer("Fitted", this.curveFit(plot.getMainLayer()));
  }
  
  public GPointsArray curveFit(final GLayer layer) {
    final PolynomialCurveFitter fitter = PolynomialCurveFitter.create(32);
    int _nPoints = layer.getPoints().getNPoints();
    final Function1<Integer, WeightedObservedPoint> _function = new Function1<Integer, WeightedObservedPoint>() {
      @Override
      public WeightedObservedPoint apply(final Integer it) {
        double _doubleValue = Float.valueOf(layer.getPoints().getX((it).intValue())).doubleValue();
        double _doubleValue_1 = Float.valueOf(layer.getPoints().getY((it).intValue())).doubleValue();
        return new WeightedObservedPoint(1, _doubleValue, _doubleValue_1);
      }
    };
    final List<WeightedObservedPoint> points = IterableExtensions.<WeightedObservedPoint>toList(IterableExtensions.<Integer, WeightedObservedPoint>map(new ExclusiveRange(0, _nPoints, true), _function));
    double[] _fit = fitter.fit(points);
    final PolynomialFunction fitted = new PolynomialFunction(_fit);
    int _nPoints_1 = layer.getPoints().getNPoints();
    final Function1<Integer, Double> _function_1 = new Function1<Integer, Double>() {
      @Override
      public Double apply(final Integer it) {
        return Double.valueOf(Float.valueOf(layer.getPoints().getX((it).intValue())).doubleValue());
      }
    };
    final Iterable<Double> xValues = IterableExtensions.<Integer, Double>map(new ExclusiveRange(0, _nPoints_1, true), _function_1);
    final GPointsArray series = new GPointsArray();
    final Consumer<Double> _function_2 = new Consumer<Double>() {
      @Override
      public void accept(final Double it) {
        series.add(it.floatValue(), Double.valueOf(fitted.value((it).doubleValue())).floatValue());
      }
    };
    IterableExtensions.<Double>toSet(xValues).forEach(_function_2);
    return series;
  }
}
