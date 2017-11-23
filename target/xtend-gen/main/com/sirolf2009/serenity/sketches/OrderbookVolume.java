package com.sirolf2009.serenity.sketches;

import com.sirolf2009.serenity.IOrderbookProvider;
import com.sirolf2009.serenity.OrderbookProviderXChange;
import com.sirolf2009.serenity.model.Order;
import com.sirolf2009.serenity.model.Orderbook;
import com.sirolf2009.serenity.sketches.Sketch;
import grafica.GAxis;
import grafica.GLayer;
import grafica.GPlot;
import grafica.GPointsArray;
import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange;
import java.time.Duration;
import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
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
  
  private final long start = System.currentTimeMillis();
  
  private final IOrderbookProvider orderbookProvider;
  
  private GPlot plot;
  
  private GLayer volumesLayer;
  
  private GLayer bidLayer;
  
  private double meanPrice;
  
  private double meanStep;
  
  private float zoom = 25f;
  
  @Override
  public void settings() {
    this.size(1024, 900);
  }
  
  @Override
  public void setup() {
    this.frameRate(60f);
    this.plot = this.darkPlot();
    this.plot.setOuterDim((this.width - 20), this.height);
    this.plot.setLineWidth(4);
    this.plot.setLineColor(this.color(200, 40, 40));
    this.plot.setTitleText("Orderbook Volume");
    GAxis _xAxis = this.plot.getXAxis();
    _xAxis.setAxisLabelText("Time");
    GAxis _yAxis = this.plot.getYAxis();
    _yAxis.setAxisLabelText("Price");
    GPointsArray _gPointsArray = new GPointsArray();
    this.plot.addLayer("volumes", _gPointsArray);
    this.volumesLayer = this.plot.getLayer("volumes");
    this.volumesLayer.setPointSize(2);
    GPointsArray _gPointsArray_1 = new GPointsArray();
    this.plot.addLayer("best-bid", _gPointsArray_1);
    this.bidLayer = this.plot.getLayer("best-bid");
    this.bidLayer.setLineWidth(4);
    this.bidLayer.setLineColor(this.color(40, 200, 40));
  }
  
  @Override
  public void draw() {
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
      _xifexpression = (((oldMeanStep * 99) + this.meanPrice) / 100);
    } else {
      _xifexpression = this.meanPrice;
    }
    this.meanStep = _xifexpression;
    Orderbook _get = this.orderbookProvider.get();
    final Procedure1<Orderbook> _function = (Orderbook it) -> {
      final Procedure1<List<Order>> _function_1 = (List<Order> it_1) -> {
        final Consumer<Order> _function_2 = (Order it_2) -> {
          double _size = it_2.getSize();
          boolean _greaterEqualsThan = (_size >= 0.5);
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
    synchronized (this.plot) {
      float _floatValue_1 = Double.valueOf(this.meanStep).floatValue();
      float _minus = (_floatValue_1 - this.zoom);
      float _floatValue_2 = Double.valueOf(this.meanStep).floatValue();
      float _plus = (_floatValue_2 + this.zoom);
      this.plot.setYLim(new float[] { _minus, _plus });
      long _millis = Duration.ofMinutes(15).toMillis();
      long _minus_1 = (x - _millis);
      float _max = PApplet.max(0, _minus_1);
      long _millis_1 = Duration.ofMinutes(1).toMillis();
      long _plus_1 = (x + _millis_1);
      this.plot.setXLim(new float[] { _max, _plus_1 });
      final Procedure1<GPlot> _function_1 = (GPlot it) -> {
        if ((this.meanPrice > 0)) {
          it.addPoint(x, Double.valueOf(this.orderbookProvider.getLowestAsk()).floatValue());
          this.bidLayer.addPoint(x, Double.valueOf(this.orderbookProvider.getHighestBid()).floatValue());
        }
        it.beginDraw();
        it.drawBackground();
        it.drawTitle();
        it.drawXAxis();
        it.drawYAxis();
        this.plot.getMainLayer().drawLines();
        this.bidLayer.drawLines();
        this.plot.getLayer("volumes").drawPoints();
        it.endDraw();
      };
      ObjectExtensions.<GPlot>operator_doubleArrow(
        this.plot, _function_1);
    }
    this.image(this.legend, (this.width - 40), ((this.height / 2) - 50));
    this.textSize(10f);
    this.text("0", (this.width - 60), ((this.height / 2) + 50));
    this.text(this.largeVolume, (this.width - 60), ((this.height / 2) - 40));
  }
  
  @Override
  public void mouseWheel(final MouseEvent event) {
    float _zoom = this.zoom;
    float _floatValue = Integer.valueOf(event.getCount()).floatValue();
    float _divide = (_floatValue / 2f);
    this.zoom = (_zoom + _divide);
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
    String _name = OrderbookVolume.class.getName();
    OrderbookProviderXChange _orderbookProviderXChange = new OrderbookProviderXChange(BitfinexStreamingExchange.class, CurrencyPair.BTC_USD);
    OrderbookVolume _orderbookVolume = new OrderbookVolume(_orderbookProviderXChange);
    PApplet.runSketch(new String[] { _name }, _orderbookVolume);
  }
  
  public OrderbookVolume(final IOrderbookProvider orderbookProvider) {
    super();
    this.orderbookProvider = orderbookProvider;
  }
}
