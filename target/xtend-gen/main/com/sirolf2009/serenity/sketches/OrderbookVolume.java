package com.sirolf2009.serenity.sketches;

import com.sirolf2009.serenity.IOrderbookProvider;
import com.sirolf2009.serenity.ITradeProvider;
import com.sirolf2009.serenity.OrderbookProviderXChange;
import com.sirolf2009.serenity.TradeProviderXChange;
import com.sirolf2009.serenity.model.Order;
import com.sirolf2009.serenity.model.Orderbook;
import com.sirolf2009.serenity.model.Trade;
import com.sirolf2009.serenity.sketches.Sketch;
import grafica.GAxis;
import grafica.GLayer;
import grafica.GPlot;
import grafica.GPoint;
import grafica.GPointsArray;
import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange;
import info.bitrich.xchangestream.core.StreamingExchange;
import info.bitrich.xchangestream.core.StreamingExchangeFactory;
import java.time.Duration;
import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.knowm.xchange.currency.CurrencyPair;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PImage;
import processing.event.MouseEvent;

@FinalFieldsConstructor
@SuppressWarnings("all")
public class OrderbookVolume extends Sketch {
  private final List<Integer> colors = Collections.<Integer>unmodifiableList(CollectionLiterals.<Integer>newArrayList(Integer.valueOf(this.color(0, 0, 255)), Integer.valueOf(this.color(0, 255, 255)), Integer.valueOf(this.color(0, 255, 0)), Integer.valueOf(this.color(255, 255, 0)), Integer.valueOf(this.color(255, 0, 0))));
  
  private final int largeVolume = 20;
  
  private final int stepSize = ((this.largeVolume / this.colors.size()) - 1);
  
  private final PImage legend = this.getGradientImage(this.colors, 20, 100);
  
  private final float fps = 60f;
  
  private final long history = (Duration.ofMinutes(2).toMillis() / 1000);
  
  private final long start = System.currentTimeMillis();
  
  private final IOrderbookProvider orderbookProvider;
  
  private final ITradeProvider tradeProvider;
  
  private GPlot plot;
  
  private GLayer volumesLayer;
  
  private GLayer bidLayer;
  
  private GLayer tradesLayer;
  
  private double meanPrice;
  
  private double meanStep;
  
  private float zoom = 25f;
  
  @Override
  public void settings() {
    this.size(1024, 900);
  }
  
  @Override
  public void setup() {
    this.frameRate(this.fps);
    this.plot = this.darkPlot();
    this.plot.setOuterDim((this.width - 20), this.height);
    this.plot.setLineWidth(4);
    this.plot.setLineColor(this.color(200, 40, 40));
    this.plot.setTitleText("Orderbook Volume");
    GAxis _xAxis = this.plot.getXAxis();
    _xAxis.setAxisLabelText("Time");
    GAxis _yAxis = this.plot.getYAxis();
    _yAxis.setAxisLabelText("Price");
    GAxis _yAxis_1 = this.plot.getYAxis();
    _yAxis_1.setRotateTickLabels(false);
    this.plot.activatePointLabels();
    GAxis _rightAxis = this.plot.getRightAxis();
    _rightAxis.setDrawTickLabels(true);
    GAxis _rightAxis_1 = this.plot.getRightAxis();
    _rightAxis_1.setRotateTickLabels(false);
    GAxis _rightAxis_2 = this.plot.getRightAxis();
    _rightAxis_2.setTicksSeparation(5);
    GAxis _rightAxis_3 = this.plot.getRightAxis();
    _rightAxis_3.setDrawAxisLabel(false);
    GPointsArray _gPointsArray = new GPointsArray();
    this.plot.addLayer("volumes", _gPointsArray);
    this.volumesLayer = this.plot.getLayer("volumes");
    this.volumesLayer.setPointSize(1);
    GPointsArray _gPointsArray_1 = new GPointsArray();
    this.plot.addLayer("best-bid", _gPointsArray_1);
    this.bidLayer = this.plot.getLayer("best-bid");
    this.bidLayer.setLineWidth(4);
    this.bidLayer.setLineColor(this.color(40, 200, 40));
    GPointsArray _gPointsArray_2 = new GPointsArray();
    this.plot.addLayer("trades", _gPointsArray_2);
    this.tradesLayer = this.plot.getLayer("trades");
  }
  
  @Override
  public void draw() {
    try {
      this.background(0);
      long _currentTimeMillis = System.currentTimeMillis();
      final long x = (_currentTimeMillis - this.start);
      final double oldMeanStep = this.meanStep;
      double _highestBid = this.orderbookProvider.getHighestBid();
      double _lowestAsk = this.orderbookProvider.getLowestAsk();
      float _floatValue = Double.valueOf((_highestBid + _lowestAsk)).floatValue();
      float _divide = (_floatValue / 2f);
      this.meanPrice = _divide;
      double _xifexpression = (double) 0;
      if ((oldMeanStep != 0)) {
        _xifexpression = (((oldMeanStep * 9) + this.meanPrice) / 10);
      } else {
        _xifexpression = this.meanPrice;
      }
      this.meanStep = _xifexpression;
      Orderbook _get = this.orderbookProvider.get();
      final Procedure1<Orderbook> _function = (Orderbook it) -> {
        final Procedure1<List<Order>> _function_1 = (List<Order> it_1) -> {
          final Consumer<Order> _function_2 = (Order it_2) -> {
            double _size = it_2.getSize();
            boolean _greaterEqualsThan = (_size >= 1);
            if (_greaterEqualsThan) {
              this.volumesLayer.addPoint(x, Double.valueOf(it_2.getPrice()).floatValue());
              this.volumesLayer.setPointColors(PApplet.append(this.volumesLayer.getPointColors(), this.getGradientColor(it_2.getSize())));
            }
          };
          it_1.forEach(_function_2);
        };
        final Procedure1<? super List<Order>> addToPlot = _function_1;
        if (((it != null) && (it.getBids() != null))) {
          addToPlot.apply(it.getBids());
        }
        if (((it != null) && (it.getAsks() != null))) {
          addToPlot.apply(it.getAsks());
        }
      };
      ObjectExtensions.<Orderbook>operator_doubleArrow(_get, _function);
      List<Trade> _get_1 = this.tradeProvider.get();
      final Procedure1<List<Trade>> _function_1 = (List<Trade> it) -> {
        final Consumer<Trade> _function_2 = (Trade it_1) -> {
          float _abs = PApplet.abs(Double.valueOf(it_1.getPrice()).floatValue());
          double _amount = it_1.getAmount();
          String _plus = (Double.valueOf(_amount) + "");
          this.tradesLayer.addPoint(x, _abs, _plus);
          float[] _pointSizes = this.tradesLayer.getPointSizes();
          float _abs_1 = PApplet.abs(Double.valueOf(it_1.getAmount()).floatValue());
          float _multiply = (_abs_1 * 3);
          this.tradesLayer.setPointSizes(PApplet.append(_pointSizes, _multiply));
          int[] _pointColors = this.tradesLayer.getPointColors();
          int _xifexpression_1 = (int) 0;
          double _amount_1 = it_1.getAmount();
          boolean _greaterThan = (_amount_1 > 0);
          if (_greaterThan) {
            _xifexpression_1 = this.color(40, 200, 40, 200);
          } else {
            _xifexpression_1 = this.color(200, 40, 40, 200);
          }
          this.tradesLayer.setPointColors(PApplet.append(_pointColors, _xifexpression_1));
        };
        it.forEach(_function_2);
      };
      ObjectExtensions.<List<Trade>>operator_doubleArrow(_get_1, _function_1);
      synchronized (this.plot) {
        float _floatValue_1 = Double.valueOf(this.meanStep).floatValue();
        float _minus = (_floatValue_1 - this.zoom);
        float _floatValue_2 = Double.valueOf(this.meanStep).floatValue();
        float _plus = (_floatValue_2 + this.zoom);
        this.plot.setYLim(new float[] { _minus, _plus });
        float _max = PApplet.max(0, (x - ((this.fps * this.history) * 1000)));
        this.plot.setXLim(new float[] { _max, (x + (this.fps * this.history)) });
        final Procedure1<GPlot> _function_2 = (GPlot it) -> {
          if (((this.meanPrice > 0) && (!Double.valueOf(this.meanPrice).isInfinite()))) {
            it.addPoint(x, Double.valueOf(this.orderbookProvider.getLowestAsk()).floatValue());
            this.bidLayer.addPoint(x, Double.valueOf(this.orderbookProvider.getHighestBid()).floatValue());
          }
          it.beginDraw();
          it.drawBackground();
          it.drawTitle();
          it.drawXAxis();
          it.drawRightAxis();
          this.plot.getMainLayer().drawLines();
          this.bidLayer.drawLines();
          this.plot.getLayer("volumes").drawPoints();
          this.tradesLayer.drawPoints();
          float _floatValue_3 = Double.valueOf(this.orderbookProvider.getLowestAsk()).floatValue();
          GPoint _gPoint = new GPoint(x, _floatValue_3);
          float _floatValue_4 = Double.valueOf(this.orderbookProvider.getLowestAsk()).floatValue();
          GPoint _gPoint_1 = new GPoint((x + 100000), _floatValue_4);
          this.plot.drawLine(_gPoint, _gPoint_1, this.color(200, 40, 40), 1);
          float _floatValue_5 = Double.valueOf(this.orderbookProvider.getHighestBid()).floatValue();
          GPoint _gPoint_2 = new GPoint(x, _floatValue_5);
          float _floatValue_6 = Double.valueOf(this.orderbookProvider.getHighestBid()).floatValue();
          GPoint _gPoint_3 = new GPoint((x + 100000), _floatValue_6);
          this.plot.drawLine(_gPoint_2, _gPoint_3, this.color(40, 200, 40), 1);
          this.plot.drawLabels();
          it.endDraw();
        };
        ObjectExtensions.<GPlot>operator_doubleArrow(
          this.plot, _function_2);
      }
      this.image(this.legend, 20, ((this.height / 2) - 50));
      this.textSize(10f);
      this.text("0", 40, ((this.height / 2) + 50));
      this.text(this.largeVolume, 40, ((this.height / 2) - 40));
      this.cleanLayer(this.plot.getMainLayer());
      this.cleanLayer(this.volumesLayer);
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  public void cleanLayer(final GLayer layer) {
    final float offScreen = this.plot.getXLim()[0];
    for (int i = 0; (i < layer.getPointsRef().getNPoints()); i++) {
      float _x = layer.getPointsRef().getX(i);
      boolean _greaterEqualsThan = (_x >= offScreen);
      if (_greaterEqualsThan) {
        if ((i != 0)) {
          layer.getPointsRef().removeRange(0, (i - 1));
          return;
        }
      }
    }
  }
  
  @Override
  public void mouseWheel(final MouseEvent event) {
    float _zoom = this.zoom;
    float _floatValue = Integer.valueOf(event.getCount()).floatValue();
    float _divide = (_floatValue / 2f);
    this.zoom = (_zoom + _divide);
    this.zoom = PApplet.max(0.5f, this.zoom);
  }
  
  public int getGradientColor(final double volume) {
    return this.getGradientColor(volume, this.stepSize);
  }
  
  public int getGradientColor(final double volume, final int stepSize) {
    int _intValue = Double.valueOf((volume / stepSize)).intValue();
    int _size = this.colors.size();
    int _minus = (_size - 1);
    final Integer cs = this.colors.get(PApplet.max(PApplet.min(_intValue, _minus), 0));
    int _intValue_1 = Double.valueOf(((volume / stepSize) + 1)).intValue();
    int _size_1 = this.colors.size();
    int _minus_1 = (_size_1 - 1);
    final Integer ce = this.colors.get(PApplet.max(PApplet.min(_intValue_1, _minus_1), 0));
    final double amt = ((volume % stepSize) / stepSize);
    return this.lerpColor((cs).intValue(), (ce).intValue(), Double.valueOf(amt).floatValue());
  }
  
  public PImage getGradientImage(final List<Integer> colors, final int width, final int height) {
    PImage _createImage = this.createImage(width, height, PConstants.RGB);
    final Procedure1<PImage> _function = (PImage it) -> {
      int _size = colors.size();
      int _divide = (height / _size);
      final int stepSize = (_divide - 1);
      final Consumer<Integer> _function_1 = (Integer y) -> {
        final int color = this.getGradientColor((height - (y).intValue()), stepSize);
        final Consumer<Integer> _function_2 = (Integer x) -> {
          it.pixels[((x).intValue() + ((y).intValue() * width))] = color;
        };
        new ExclusiveRange(0, width, true).forEach(_function_2);
      };
      new ExclusiveRange(0, height, true).forEach(_function_1);
    };
    return ObjectExtensions.<PImage>operator_doubleArrow(_createImage, _function);
  }
  
  public static void main(final String[] args) {
    final StreamingExchange exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.class.getName());
    exchange.connect().blockingAwait();
    String _name = OrderbookVolume.class.getName();
    OrderbookProviderXChange _orderbookProviderXChange = new OrderbookProviderXChange(exchange, CurrencyPair.BTC_USD);
    TradeProviderXChange _tradeProviderXChange = new TradeProviderXChange(exchange, CurrencyPair.BTC_USD);
    OrderbookVolume _orderbookVolume = new OrderbookVolume(_orderbookProviderXChange, _tradeProviderXChange);
    PApplet.runSketch(new String[] { _name }, _orderbookVolume);
  }
  
  public OrderbookVolume(final IOrderbookProvider orderbookProvider, final ITradeProvider tradeProvider) {
    super();
    this.orderbookProvider = orderbookProvider;
    this.tradeProvider = tradeProvider;
  }
}
