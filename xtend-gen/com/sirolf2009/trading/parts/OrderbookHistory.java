package com.sirolf2009.trading.parts;

import com.google.common.collect.Iterables;
import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.ChartPart;
import io.reactivex.functions.Consumer;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Function;
import java.util.function.IntFunction;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;
import javax.annotation.PostConstruct;
import org.apache.commons.collections4.queue.CircularFifoQueue;
import org.apache.commons.math3.analysis.polynomials.PolynomialFunction;
import org.apache.commons.math3.fitting.PolynomialCurveFitter;
import org.apache.commons.math3.fitting.WeightedObservedPoint;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.knowm.xchange.dto.marketdata.OrderBook;
import org.knowm.xchange.dto.trade.LimitOrder;
import org.swtchart.Chart;
import org.swtchart.IAxis;
import org.swtchart.ILineSeries;
import org.swtchart.ITitle;
import org.swtchart.LineStyle;
import org.swtchart.Range;
import org.swtchart.internal.series.LineSeries;

@SuppressWarnings("all")
public class OrderbookHistory extends ChartPart implements IExchangePart {
  private Chart chart;
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    Chart _createChart = this.createChart(parent);
    final Procedure1<Chart> _function = (Chart it) -> {
      ITitle _title = this.yAxis(it).getTitle();
      _title.setText("Price");
    };
    Chart _doubleArrow = ObjectExtensions.<Chart>operator_doubleArrow(_createChart, _function);
    this.chart = _doubleArrow;
    final int bufferSize = 500;
    final CircularFifoQueue<Double> bidBuffer = new CircularFifoQueue<Double>(bufferSize);
    final LineSeries bid = this.createLineSeries(this.chart, "Bid");
    bid.setSymbolType(ILineSeries.PlotSymbolType.NONE);
    bid.setLineColor(ChartPart.green);
    bid.enableStep(true);
    final CircularFifoQueue<Double> askBuffer = new CircularFifoQueue<Double>(bufferSize);
    final LineSeries ask = this.createLineSeries(this.chart, "Ask");
    ask.setLineColor(ChartPart.red);
    ask.enableStep(true);
    final CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>> volumeBuffer = new CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>>(bufferSize);
    final LineSeries volume = this.createLineSeries(this.chart, "Volume");
    volume.setVisibleInLegend(false);
    volume.setLineStyle(LineStyle.NONE);
    volume.setSymbolType(ILineSeries.PlotSymbolType.SQUARE);
    volume.setSymbolSize(1);
    final LineSeries askFit = this.createLineSeries(this.chart, "AskFit");
    askFit.setLineColor(ChartPart.red);
    final HashMap<Long, Color> savedColors = new HashMap<Long, Color>();
    Display _display = parent.getDisplay();
    Color _color = new Color(_display, 0, 0, 255);
    Display _display_1 = parent.getDisplay();
    Color _color_1 = new Color(_display_1, 0, 255, 255);
    Display _display_2 = parent.getDisplay();
    Color _color_2 = new Color(_display_2, 0, 255, 0);
    Display _display_3 = parent.getDisplay();
    Color _color_3 = new Color(_display_3, 255, 255, 0);
    Display _display_4 = parent.getDisplay();
    Color _color_4 = new Color(_display_4, 255, 0, 0);
    final List<Color> colors = Collections.<Color>unmodifiableList(CollectionLiterals.<Color>newArrayList(_color, _color_1, _color_2, _color_3, _color_4));
    final int largeVolume = 20;
    int _size = colors.size();
    int _divide = (largeVolume / _size);
    final int stepSize = (_divide - 1);
    final Function<Long, Color> _function_1 = (Long it) -> {
      boolean _containsKey = savedColors.containsKey(it);
      boolean _not = (!_containsKey);
      if (_not) {
        int _intValue = Long.valueOf(((it).longValue() / stepSize)).intValue();
        int _size_1 = colors.size();
        int _minus = (_size_1 - 1);
        final Color c1 = colors.get(Math.max(Math.min(_intValue, _minus), 0));
        int _intValue_1 = Long.valueOf((((it).longValue() / stepSize) + 1)).intValue();
        int _size_2 = colors.size();
        int _minus_1 = (_size_2 - 1);
        final Color c2 = colors.get(Math.max(Math.min(_intValue_1, _minus_1), 0));
        final long amt = (((it).longValue() % stepSize) / stepSize);
        final int r1 = c1.getRed();
        final int g1 = c1.getGreen();
        final int b1 = c1.getBlue();
        final int r2 = c2.getRed();
        final int g2 = c2.getGreen();
        final int b2 = c2.getBlue();
        Display _display_5 = parent.getDisplay();
        int _intValue_2 = Integer.valueOf(Math.round((r1 + ((r2 - r1) * amt)))).intValue();
        int _intValue_3 = Integer.valueOf(Math.round((g1 + ((g2 - g1) * amt)))).intValue();
        int _intValue_4 = Integer.valueOf(Math.round((b1 + ((b2 - b1) * amt)))).intValue();
        Color _color_5 = new Color(_display_5, _intValue_2, _intValue_3, _intValue_4);
        savedColors.put(it, _color_5);
      }
      return savedColors.get(it);
    };
    final Function<Long, Color> getGradient = _function_1;
    final AtomicReference<OrderBook> latestOrderbook = new AtomicReference<OrderBook>();
    final Consumer<OrderBook> _function_2 = (OrderBook it) -> {
      boolean _isDisposed = this.chart.isDisposed();
      if (_isDisposed) {
        return;
      }
      if ((it != null)) {
        latestOrderbook.set(it);
      }
    };
    this.getOrderbook().subscribe(_function_2);
    final Runnable _function_3 = () -> {
      try {
        while (true) {
          {
            Thread.sleep(1000);
            boolean _isDisposed = this.chart.isDisposed();
            if (_isDisposed) {
              return;
            }
            final OrderBook it = latestOrderbook.get();
            if ((it != null)) {
              final Date now = new Date();
              bidBuffer.add(Double.valueOf(it.getBids().get(0).getLimitPrice().doubleValue()));
              askBuffer.add(Double.valueOf(it.getAsks().get(0).getLimitPrice().doubleValue()));
              final Function1<LimitOrder, Boolean> _function_4 = (LimitOrder it_1) -> {
                double _doubleValue = it_1.getRemainingAmount().doubleValue();
                return Boolean.valueOf((_doubleValue >= 1));
              };
              final Function1<LimitOrder, Pair<Double, Double>> _function_5 = (LimitOrder it_1) -> {
                double _doubleValue = it_1.getLimitPrice().doubleValue();
                double _doubleValue_1 = it_1.getRemainingAmount().doubleValue();
                return Pair.<Double, Double>of(Double.valueOf(_doubleValue), Double.valueOf(_doubleValue_1));
              };
              Iterable<Pair<Double, Double>> _map = IterableExtensions.<LimitOrder, Pair<Double, Double>>map(IterableExtensions.<LimitOrder>filter(it.getBids(), _function_4), _function_5);
              final Function1<LimitOrder, Boolean> _function_6 = (LimitOrder it_1) -> {
                double _doubleValue = it_1.getRemainingAmount().doubleValue();
                return Boolean.valueOf((_doubleValue <= (-1)));
              };
              final Function1<LimitOrder, Pair<Double, Double>> _function_7 = (LimitOrder it_1) -> {
                double _doubleValue = it_1.getLimitPrice().doubleValue();
                double _doubleValue_1 = it_1.getRemainingAmount().doubleValue();
                return Pair.<Double, Double>of(Double.valueOf(_doubleValue), Double.valueOf(_doubleValue_1));
              };
              Iterable<Pair<Double, Double>> _map_1 = IterableExtensions.<LimitOrder, Pair<Double, Double>>map(IterableExtensions.<LimitOrder>filter(it.getAsks(), _function_6), _function_7);
              volumeBuffer.add(Pair.<Date, List<Pair<Double, Double>>>of(now, IterableExtensions.<Pair<Double, Double>>toList(Iterables.<Pair<Double, Double>>concat(_map, _map_1))));
              final List<Pair<Date, List<Pair<Double, Double>>>> volumes = IterableExtensions.<Pair<Date, List<Pair<Double, Double>>>>toList(volumeBuffer);
              final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Double>> _function_8 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
                final IntFunction<Double> _function_9 = (int it_1) -> {
                  return Double.valueOf(Integer.valueOf(IterableExtensions.<Pair<Date, List<Pair<Double, Double>>>>toList(volumes).indexOf(tick)).doubleValue());
                };
                return IntStream.range(0, tick.getValue().size()).parallel().<Double>mapToObj(_function_9);
              };
              final List<Double> volumesX = volumeBuffer.parallelStream().<Double>flatMap(_function_8).collect(Collectors.<Double>toList());
              final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Double>> _function_9 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
                final Function<Pair<Double, Double>, Double> _function_10 = (Pair<Double, Double> it_1) -> {
                  return it_1.getKey();
                };
                return tick.getValue().parallelStream().<Double>map(_function_10);
              };
              final List<Double> volumesY = volumeBuffer.parallelStream().<Double>flatMap(_function_9).collect(Collectors.<Double>toList());
              final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Color>> _function_10 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
                final Function<Pair<Double, Double>, Double> _function_11 = (Pair<Double, Double> it_1) -> {
                  return Double.valueOf(Math.abs((it_1.getValue()).doubleValue()));
                };
                final Function<Double, Color> _function_12 = (Double it_1) -> {
                  return getGradient.apply(Long.valueOf(it_1.longValue()));
                };
                return tick.getValue().parallelStream().<Double>map(_function_11).<Color>map(_function_12);
              };
              final List<Color> volumesColor = volumeBuffer.parallelStream().<Color>flatMap(_function_10).collect(Collectors.<Color>toList());
              final List<Double> askFitted = OrderbookHistory.fit(askBuffer);
              final Runnable _function_11 = () -> {
                boolean _isDisposed_1 = this.chart.isDisposed();
                if (_isDisposed_1) {
                  return;
                }
                bid.setYSeries(((double[])Conversions.unwrapArray(bidBuffer, double.class)));
                ask.setYSeries(((double[])Conversions.unwrapArray(askBuffer, double.class)));
                askFit.setYSeries(((double[])Conversions.unwrapArray(askFitted, double.class)));
                volume.setXSeries(((double[])Conversions.unwrapArray(volumesX, double.class)));
                volume.setYSeries(((double[])Conversions.unwrapArray(volumesY, double.class)));
                volume.setSymbolColors(((Color[])Conversions.unwrapArray(volumesColor, Color.class)));
                this.xAxis(this.chart).adjustRange();
                double _doubleValue = it.getBids().get(0).getLimitPrice().doubleValue();
                double _doubleValue_1 = it.getAsks().get(0).getLimitPrice().doubleValue();
                double _plus = (_doubleValue + _doubleValue_1);
                final double mid = (_plus / 2);
                IAxis _yAxis = this.yAxis(this.chart);
                Range _range = new Range((mid - (mid / 100)), (mid + (mid / 100)));
                _yAxis.setRange(_range);
                this.chart.redraw();
              };
              parent.getDisplay().syncExec(_function_11);
            } else {
              System.err.println("Orderbook is null");
            }
          }
        }
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    };
    new Thread(_function_3).start();
  }
  
  public static List<Double> fit(final CircularFifoQueue<Double> buffer) {
    return OrderbookHistory.fit(buffer, 6);
  }
  
  public static List<Double> fit(final CircularFifoQueue<Double> buffer, final int degree) {
    return OrderbookHistory.fit(IterableExtensions.<Double>toList(buffer), degree);
  }
  
  public static List<Double> fit(final List<Double> trades, final int degree) {
    List<Double> _xblockexpression = null;
    {
      final PolynomialCurveFitter fitter = PolynomialCurveFitter.create(degree);
      final Function1<Double, WeightedObservedPoint> _function = (Double it) -> {
        int _indexOf = trades.indexOf(it);
        return new WeightedObservedPoint(1, _indexOf, (it).doubleValue());
      };
      final List<WeightedObservedPoint> points = IterableExtensions.<WeightedObservedPoint>toList(ListExtensions.<Double, WeightedObservedPoint>map(trades, _function));
      final double[] coeffecs = fitter.fit(points);
      final PolynomialFunction func = new PolynomialFunction(coeffecs);
      int _size = trades.size();
      final Function1<Integer, Double> _function_1 = (Integer it) -> {
        return Double.valueOf(func.value((it).intValue()));
      };
      _xblockexpression = IterableExtensions.<Double>toList(IterableExtensions.<Integer, Double>map(new ExclusiveRange(0, _size, true), _function_1));
    }
    return _xblockexpression;
  }
  
  @Focus
  public void setFocus() {
    this.chart.setFocus();
  }
}
