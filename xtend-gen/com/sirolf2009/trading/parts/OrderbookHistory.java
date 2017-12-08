package com.sirolf2009.trading.parts;

import com.google.common.collect.Iterables;
import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder;
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook;
import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.ChartPart;
import io.reactivex.functions.Consumer;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;
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
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseWheelListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
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
  
  private final int bufferSize = 5000;
  
  private final CircularFifoQueue<Double> bidBuffer = new CircularFifoQueue<Double>(this.bufferSize);
  
  private final CircularFifoQueue<Double> askBuffer = new CircularFifoQueue<Double>(this.bufferSize);
  
  private final CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>> volumeBuffer = new CircularFifoQueue<Pair<Date, List<Pair<Double, Double>>>>(this.bufferSize);
  
  private final HashMap<Long, Color> savedColors = new HashMap<Long, Color>();
  
  private final List<Color> colors = Collections.<Color>unmodifiableList(CollectionLiterals.<Color>newArrayList(new Color(null, 0, 0, 255), new Color(null, 0, 255, 255), new Color(null, 0, 255, 0), new Color(null, 255, 255, 0), new Color(null, 255, 0, 0)));
  
  private final int largeVolume = 20;
  
  private final int stepSize = ((this.largeVolume / this.colors.size()) - 1);
  
  private LineSeries bid;
  
  private LineSeries ask;
  
  private LineSeries volume;
  
  private int zoomY = 100;
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    Chart _createChart = this.createChart(parent);
    final Procedure1<Chart> _function = (Chart it) -> {
      ITitle _title = this.yAxis(it).getTitle();
      _title.setText("Price");
      final MouseWheelListener _function_1 = (MouseEvent it_1) -> {
        int _zoomY = this.zoomY;
        this.zoomY = (_zoomY + (it_1.count / 3));
      };
      it.addMouseWheelListener(_function_1);
    };
    Chart _doubleArrow = ObjectExtensions.<Chart>operator_doubleArrow(_createChart, _function);
    this.chart = _doubleArrow;
    this.bid = this.createLineSeries(this.chart, "Bid");
    this.bid.setSymbolType(ILineSeries.PlotSymbolType.NONE);
    this.bid.setLineColor(ChartPart.green);
    this.bid.enableStep(true);
    this.ask = this.createLineSeries(this.chart, "Ask");
    this.ask.setLineColor(ChartPart.red);
    this.ask.enableStep(true);
    this.volume = this.createLineSeries(this.chart, "Volume");
    this.volume.setVisibleInLegend(false);
    this.volume.setLineStyle(LineStyle.NONE);
    this.volume.setSymbolType(ILineSeries.PlotSymbolType.SQUARE);
    this.volume.setSymbolSize(1);
    final Consumer<IOrderbook> _function_1 = (IOrderbook it) -> {
      boolean _isDisposed = this.chart.isDisposed();
      if (_isDisposed) {
        return;
      }
      if ((it != null)) {
        this.receiveOrderbook(it);
      }
    };
    this.getOrderbook().sample(1, TimeUnit.SECONDS).subscribe(_function_1);
  }
  
  public void receiveOrderbook(final IOrderbook it) {
    if ((it != null)) {
      final Date now = new Date();
      this.bidBuffer.add(Double.valueOf(((ILimitOrder[])Conversions.unwrapArray(it.getBids(), ILimitOrder.class))[0].getPrice().doubleValue()));
      this.askBuffer.add(Double.valueOf(((ILimitOrder[])Conversions.unwrapArray(it.getAsks(), ILimitOrder.class))[0].getPrice().doubleValue()));
      final Function1<ILimitOrder, Boolean> _function = (ILimitOrder it_1) -> {
        double _doubleValue = it_1.getAmount().doubleValue();
        return Boolean.valueOf((_doubleValue >= 1));
      };
      final Function1<ILimitOrder, Pair<Double, Double>> _function_1 = (ILimitOrder it_1) -> {
        double _doubleValue = it_1.getPrice().doubleValue();
        double _doubleValue_1 = it_1.getAmount().doubleValue();
        return Pair.<Double, Double>of(Double.valueOf(_doubleValue), Double.valueOf(_doubleValue_1));
      };
      Iterable<Pair<Double, Double>> _map = IterableExtensions.<ILimitOrder, Pair<Double, Double>>map(IterableExtensions.<ILimitOrder>filter(it.getBids(), _function), _function_1);
      final Function1<ILimitOrder, Boolean> _function_2 = (ILimitOrder it_1) -> {
        double _doubleValue = it_1.getAmount().doubleValue();
        return Boolean.valueOf((_doubleValue <= (-1)));
      };
      final Function1<ILimitOrder, Pair<Double, Double>> _function_3 = (ILimitOrder it_1) -> {
        double _doubleValue = it_1.getPrice().doubleValue();
        double _doubleValue_1 = it_1.getAmount().doubleValue();
        return Pair.<Double, Double>of(Double.valueOf(_doubleValue), Double.valueOf(_doubleValue_1));
      };
      Iterable<Pair<Double, Double>> _map_1 = IterableExtensions.<ILimitOrder, Pair<Double, Double>>map(IterableExtensions.<ILimitOrder>filter(it.getAsks(), _function_2), _function_3);
      this.volumeBuffer.add(Pair.<Date, List<Pair<Double, Double>>>of(now, IterableExtensions.<Pair<Double, Double>>toList(Iterables.<Pair<Double, Double>>concat(_map, _map_1))));
      final List<Pair<Date, List<Pair<Double, Double>>>> volumes = IterableExtensions.<Pair<Date, List<Pair<Double, Double>>>>toList(this.volumeBuffer);
      final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Double>> _function_4 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
        final IntFunction<Double> _function_5 = (int it_1) -> {
          return Double.valueOf(Integer.valueOf(IterableExtensions.<Pair<Date, List<Pair<Double, Double>>>>toList(volumes).indexOf(tick)).doubleValue());
        };
        return IntStream.range(0, tick.getValue().size()).parallel().<Double>mapToObj(_function_5);
      };
      final List<Double> volumesX = this.volumeBuffer.parallelStream().<Double>flatMap(_function_4).collect(Collectors.<Double>toList());
      final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Double>> _function_5 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
        final Function<Pair<Double, Double>, Double> _function_6 = (Pair<Double, Double> it_1) -> {
          return it_1.getKey();
        };
        return tick.getValue().parallelStream().<Double>map(_function_6);
      };
      final List<Double> volumesY = this.volumeBuffer.parallelStream().<Double>flatMap(_function_5).collect(Collectors.<Double>toList());
      final Function<Pair<Date, List<Pair<Double, Double>>>, Stream<Color>> _function_6 = (Pair<Date, List<Pair<Double, Double>>> tick) -> {
        final Function<Pair<Double, Double>, Double> _function_7 = (Pair<Double, Double> it_1) -> {
          return Double.valueOf(Math.abs((it_1.getValue()).doubleValue()));
        };
        final Function<Double, Color> _function_8 = (Double it_1) -> {
          return this.getGradient(Long.valueOf(it_1.longValue()));
        };
        return tick.getValue().parallelStream().<Double>map(_function_7).<Color>map(_function_8);
      };
      final List<Color> volumesColor = this.volumeBuffer.parallelStream().<Color>flatMap(_function_6).collect(Collectors.<Color>toList());
      boolean _isDisposed = this.chart.isDisposed();
      if (_isDisposed) {
        return;
      }
      final Runnable _function_7 = () -> {
        boolean _isDisposed_1 = this.chart.isDisposed();
        if (_isDisposed_1) {
          return;
        }
        this.bid.setYSeries(((double[])Conversions.unwrapArray(this.bidBuffer, double.class)));
        this.ask.setYSeries(((double[])Conversions.unwrapArray(this.askBuffer, double.class)));
        this.volume.setXSeries(((double[])Conversions.unwrapArray(volumesX, double.class)));
        this.volume.setYSeries(((double[])Conversions.unwrapArray(volumesY, double.class)));
        this.volume.setSymbolColors(((Color[])Conversions.unwrapArray(volumesColor, Color.class)));
        IAxis _xAxis = this.xAxis(this.chart);
        int _size = this.bidBuffer.size();
        Range _range = new Range(0, _size);
        _xAxis.setRange(_range);
        double _doubleValue = ((ILimitOrder[])Conversions.unwrapArray(it.getBids(), ILimitOrder.class))[0].getPrice().doubleValue();
        double _doubleValue_1 = ((ILimitOrder[])Conversions.unwrapArray(it.getAsks(), ILimitOrder.class))[0].getPrice().doubleValue();
        double _plus = (_doubleValue + _doubleValue_1);
        final double mid = (_plus / 2);
        IAxis _yAxis = this.yAxis(this.chart);
        Range _range_1 = new Range((mid - (mid / this.zoomY)), (mid + (mid / this.zoomY)));
        _yAxis.setRange(_range_1);
        this.chart.redraw();
      };
      this.chart.getDisplay().syncExec(_function_7);
    } else {
      System.err.println("Orderbook is null");
    }
  }
  
  public Color getGradient(final Long it) {
    boolean _containsKey = this.savedColors.containsKey(it);
    boolean _not = (!_containsKey);
    if (_not) {
      int _intValue = Long.valueOf(((it).longValue() / this.stepSize)).intValue();
      int _size = this.colors.size();
      int _minus = (_size - 1);
      final Color c1 = this.colors.get(Math.max(Math.min(_intValue, _minus), 0));
      int _intValue_1 = Long.valueOf((((it).longValue() / this.stepSize) + 1)).intValue();
      int _size_1 = this.colors.size();
      int _minus_1 = (_size_1 - 1);
      final Color c2 = this.colors.get(Math.max(Math.min(_intValue_1, _minus_1), 0));
      final long amt = (((it).longValue() % this.stepSize) / this.stepSize);
      final int r1 = c1.getRed();
      final int g1 = c1.getGreen();
      final int b1 = c1.getBlue();
      final int r2 = c2.getRed();
      final int g2 = c2.getGreen();
      final int b2 = c2.getBlue();
      Display _display = this.chart.getDisplay();
      int _intValue_2 = Integer.valueOf(Math.round((r1 + ((r2 - r1) * amt)))).intValue();
      int _intValue_3 = Integer.valueOf(Math.round((g1 + ((g2 - g1) * amt)))).intValue();
      int _intValue_4 = Integer.valueOf(Math.round((b1 + ((b2 - b1) * amt)))).intValue();
      Color _color = new Color(_display, _intValue_2, _intValue_3, _intValue_4);
      this.savedColors.put(it, _color);
    }
    return this.savedColors.get(it);
  }
  
  public static List<Double> fit(final CircularFifoQueue<Double> buffer) {
    return OrderbookHistory.fit(buffer, 2);
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
