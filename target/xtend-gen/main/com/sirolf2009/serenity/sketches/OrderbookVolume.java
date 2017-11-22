package com.sirolf2009.serenity.sketches;

import com.google.common.util.concurrent.AtomicDouble;
import com.sirolf2009.serenity.GDAXClient;
import com.sirolf2009.serenity.dto.IUpdate;
import com.sirolf2009.serenity.dto.Side;
import com.sirolf2009.serenity.dto.UpdateMatch;
import com.sirolf2009.serenity.dto.UpdateOpen;
import com.sirolf2009.serenity.sketches.Sketch;
import grafica.GAxis;
import grafica.GLayer;
import grafica.GPlot;
import grafica.GPointsArray;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import processing.core.PApplet;

@SuppressWarnings("all")
public class OrderbookVolume extends Sketch {
  private final List<Integer> colors = Collections.<Integer>unmodifiableList(CollectionLiterals.<Integer>newArrayList(Integer.valueOf(this.color(0, 0, 255, 100)), Integer.valueOf(this.color(0, 255, 0, 100)), Integer.valueOf(this.color(255, 255, 0, 100)), Integer.valueOf(this.color(255, 0, 0, 100))));
  
  private final int stepSize = ((10 / this.colors.size()) - 1);
  
  private GPlot plot;
  
  @Override
  public void settings() {
    this.size(1024, 900);
  }
  
  @Override
  public void setup() {
    this.frameRate(1);
    this.plot = this.darkPlot();
    this.plot.setLineWidth(2);
    this.plot.setTitleText("Orderbook Volume");
    GAxis _xAxis = this.plot.getXAxis();
    _xAxis.setAxisLabelText("Time");
    GAxis _yAxis = this.plot.getYAxis();
    _yAxis.setAxisLabelText("Price");
    GPointsArray _gPointsArray = new GPointsArray();
    this.plot.addLayer("volumes", _gPointsArray);
    final GLayer volumesLayer = this.plot.getLayer("volumes");
    final long start = System.currentTimeMillis();
    final AtomicDouble highestBid = new AtomicDouble();
    final AtomicDouble lowestAsk = new AtomicDouble(Double.MAX_VALUE);
    final HashMap<Double, Double> volumes = new HashMap<Double, Double>();
    final Consumer<IUpdate> _function = new Consumer<IUpdate>() {
      @Override
      public void accept(final IUpdate it) {
        if ((it instanceof UpdateOpen)) {
          Side _side = ((UpdateOpen)it).getSide();
          boolean _tripleEquals = (_side == Side.BUY);
          if (_tripleEquals) {
            highestBid.set(Math.max(highestBid.get(), ((UpdateOpen)it).getPrice()));
          } else {
            lowestAsk.set(Math.min(lowestAsk.get(), ((UpdateOpen)it).getPrice()));
          }
          if (((lowestAsk.get() != 0) && (highestBid.get() != Double.MAX_VALUE))) {
            double _get = lowestAsk.get();
            double _get_1 = highestBid.get();
            double _plus = (_get + _get_1);
            final double midPrice = (_plus / 2);
            synchronized (OrderbookVolume.this.plot) {
              long _currentTimeMillis = System.currentTimeMillis();
              long _minus = (_currentTimeMillis - start);
              OrderbookVolume.this.plot.addPoint(_minus, Double.valueOf(midPrice).floatValue());
            }
            synchronized (volumes) {
              boolean _containsKey = volumes.containsKey(Double.valueOf(((UpdateOpen)it).getPrice()));
              boolean _not = (!_containsKey);
              if (_not) {
                volumes.put(Double.valueOf(((UpdateOpen)it).getPrice()), Double.valueOf(((UpdateOpen)it).getRemainingSize()));
              } else {
                Double _get_2 = volumes.get(Double.valueOf(((UpdateOpen)it).getPrice()));
                double _remainingSize = ((UpdateOpen)it).getRemainingSize();
                double _plus_1 = ((_get_2).doubleValue() + _remainingSize);
                volumes.put(Double.valueOf(((UpdateOpen)it).getPrice()), Double.valueOf(_plus_1));
              }
              final Consumer<Map.Entry<Double, Double>> _function = new Consumer<Map.Entry<Double, Double>>() {
                @Override
                public void accept(final Map.Entry<Double, Double> it) {
                  synchronized (OrderbookVolume.this.plot) {
                    long _currentTimeMillis = System.currentTimeMillis();
                    long _minus = (_currentTimeMillis - start);
                    volumesLayer.addPoint(_minus, it.getKey().floatValue());
                    volumesLayer.setPointColors(PApplet.append(volumesLayer.getPointColors(), OrderbookVolume.this.getGradientColor((it.getValue()).doubleValue())));
                  }
                }
              };
              volumes.entrySet().forEach(_function);
            }
          }
        } else {
          if ((it instanceof UpdateMatch)) {
            Side _side_1 = ((UpdateMatch)it).getSide();
            boolean _tripleEquals_1 = (_side_1 == Side.BUY);
            if (_tripleEquals_1) {
              highestBid.set(Math.max(highestBid.get(), ((UpdateMatch)it).getPrice()));
            } else {
              lowestAsk.set(Math.min(lowestAsk.get(), ((UpdateMatch)it).getPrice()));
            }
            if (((lowestAsk.get() != 0) && (highestBid.get() != Double.MAX_VALUE))) {
              double _get_2 = lowestAsk.get();
              double _get_3 = highestBid.get();
              double _plus_1 = (_get_2 + _get_3);
              final double midPrice_1 = (_plus_1 / 2);
              synchronized (OrderbookVolume.this.plot) {
                long _currentTimeMillis = System.currentTimeMillis();
                long _minus = (_currentTimeMillis - start);
                OrderbookVolume.this.plot.addPoint(_minus, Double.valueOf(midPrice_1).floatValue());
              }
              synchronized (volumes) {
                boolean _containsKey = volumes.containsKey(Double.valueOf(((UpdateMatch)it).getPrice()));
                if (_containsKey) {
                  Double _get_4 = volumes.get(Double.valueOf(((UpdateMatch)it).getPrice()));
                  double _size = ((UpdateMatch)it).getSize();
                  double _minus = ((_get_4).doubleValue() - _size);
                  volumes.put(Double.valueOf(((UpdateMatch)it).getPrice()), Double.valueOf(_minus));
                }
                final Consumer<Map.Entry<Double, Double>> _function = new Consumer<Map.Entry<Double, Double>>() {
                  @Override
                  public void accept(final Map.Entry<Double, Double> it) {
                    synchronized (OrderbookVolume.this.plot) {
                      long _currentTimeMillis = System.currentTimeMillis();
                      long _minus = (_currentTimeMillis - start);
                      volumesLayer.addPoint(_minus, it.getKey().floatValue());
                      volumesLayer.setPointColors(PApplet.append(volumesLayer.getPointColors(), OrderbookVolume.this.getGradientColor((it.getValue()).doubleValue())));
                    }
                  }
                };
                volumes.entrySet().forEach(_function);
              }
            }
          }
        }
      }
    };
    new GDAXClient(_function);
  }
  
  @Override
  public void draw() {
    this.background(0);
    synchronized (this.plot) {
      final Procedure1<GPlot> _function = new Procedure1<GPlot>() {
        @Override
        public void apply(final GPlot it) {
          it.beginDraw();
          it.drawBackground();
          it.drawTitle();
          it.drawXAxis();
          it.drawYAxis();
          OrderbookVolume.this.plot.getMainLayer().drawLines();
          OrderbookVolume.this.plot.getLayer("volumes").drawPoints();
          it.endDraw();
        }
      };
      ObjectExtensions.<GPlot>operator_doubleArrow(
        this.plot, _function);
    }
  }
  
  public int getGradientColor(final double volume) {
    int _intValue = Double.valueOf((volume / this.stepSize)).intValue();
    int _size = this.colors.size();
    int _minus = (_size - 1);
    final Integer cs = this.colors.get(PApplet.min(_intValue, _minus));
    int _intValue_1 = Double.valueOf(((volume / this.stepSize) + 1)).intValue();
    int _size_1 = this.colors.size();
    int _minus_1 = (_size_1 - 1);
    final Integer ce = this.colors.get(PApplet.min(_intValue_1, _minus_1));
    final double amt = ((volume % this.stepSize) / this.stepSize);
    return this.lerpColor((cs).intValue(), (ce).intValue(), Double.valueOf(amt).floatValue());
  }
  
  public static void main(final String[] args) {
    String _name = OrderbookVolume.class.getName();
    OrderbookVolume _orderbookVolume = new OrderbookVolume();
    PApplet.runSketch(new String[] { _name }, _orderbookVolume);
  }
}
