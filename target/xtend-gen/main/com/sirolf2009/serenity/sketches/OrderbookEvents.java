package com.sirolf2009.serenity.sketches;

import com.sirolf2009.serenity.client.GDAXClientOrders;
import com.sirolf2009.serenity.dto.IUpdate;
import com.sirolf2009.serenity.dto.Side;
import com.sirolf2009.serenity.dto.UpdateMatch;
import com.sirolf2009.serenity.dto.UpdateOpen;
import com.sirolf2009.serenity.sketches.Sketch;
import grafica.GAxis;
import grafica.GLayer;
import grafica.GPlot;
import grafica.GPointsArray;
import java.util.function.Consumer;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import processing.core.PApplet;

@SuppressWarnings("all")
public class OrderbookEvents extends Sketch {
  private GPlot plot;
  
  @Override
  public void settings() {
    this.size(1024, 900);
  }
  
  @Override
  public void setup() {
    this.frameRate(1);
    this.plot = this.darkPlot();
    this.plot.setTitleText("Orderbook events");
    GAxis _xAxis = this.plot.getXAxis();
    _xAxis.setAxisLabelText("Time");
    GAxis _yAxis = this.plot.getYAxis();
    _yAxis.setAxisLabelText("Price");
    this.plot.setPointColor(this.color(150, 40, 40));
    GPointsArray _gPointsArray = new GPointsArray();
    this.plot.addLayer("asks-removed", _gPointsArray);
    final GLayer asksRemoved = this.plot.getLayer("asks-removed");
    asksRemoved.setPointColor(this.color(150, 150, 40));
    GPointsArray _gPointsArray_1 = new GPointsArray();
    this.plot.addLayer("bids", _gPointsArray_1);
    final GLayer bids = this.plot.getLayer("bids");
    bids.setPointColor(this.color(40, 40, 150));
    GPointsArray _gPointsArray_2 = new GPointsArray();
    this.plot.addLayer("bids-removed", _gPointsArray_2);
    final GLayer bidsRemoved = this.plot.getLayer("bids-removed");
    bidsRemoved.setPointColor(this.color(40, 150, 150));
    final long start = System.currentTimeMillis();
    final Consumer<IUpdate> _function = (IUpdate it) -> {
      if ((it instanceof UpdateOpen)) {
        double _price = ((UpdateOpen)it).getPrice();
        boolean _greaterThan = (_price > 6000);
        if (_greaterThan) {
          synchronized (this.plot) {
            Side _side = ((UpdateOpen)it).getSide();
            boolean _tripleEquals = (_side == Side.BUY);
            if (_tripleEquals) {
              long _currentTimeMillis = System.currentTimeMillis();
              long _minus = (_currentTimeMillis - start);
              bids.addPoint(_minus, Double.valueOf(((UpdateOpen)it).getPrice()).floatValue());
              double _remainingSize = ((UpdateOpen)it).getRemainingSize();
              double _multiply = (_remainingSize * 2000);
              bids.setPointSizes(PApplet.append(bids.getPointSizes(), Double.valueOf(Math.log(_multiply)).floatValue()));
            } else {
              long _currentTimeMillis_1 = System.currentTimeMillis();
              long _minus_1 = (_currentTimeMillis_1 - start);
              this.plot.addPoint(_minus_1, Double.valueOf(((UpdateOpen)it).getPrice()).floatValue());
              double _remainingSize_1 = ((UpdateOpen)it).getRemainingSize();
              double _multiply_1 = (_remainingSize_1 * 2000);
              this.plot.setPointSizes(PApplet.append(bids.getPointSizes(), Double.valueOf(Math.log(_multiply_1)).floatValue()));
            }
          }
        }
      } else {
        if ((it instanceof UpdateMatch)) {
          double _price_1 = ((UpdateMatch)it).getPrice();
          boolean _greaterThan_1 = (_price_1 > 6000);
          if (_greaterThan_1) {
            synchronized (this.plot) {
              Side _side = ((UpdateMatch)it).getSide();
              boolean _tripleEquals = (_side == Side.BUY);
              if (_tripleEquals) {
                long _currentTimeMillis = System.currentTimeMillis();
                long _minus = (_currentTimeMillis - start);
                bidsRemoved.addPoint(_minus, Double.valueOf(((UpdateMatch)it).getPrice()).floatValue());
                double _size = ((UpdateMatch)it).getSize();
                double _multiply = (_size * 2000);
                bidsRemoved.setPointSizes(PApplet.append(bids.getPointSizes(), Double.valueOf(Math.log(_multiply)).floatValue()));
              } else {
                long _currentTimeMillis_1 = System.currentTimeMillis();
                long _minus_1 = (_currentTimeMillis_1 - start);
                asksRemoved.addPoint(_minus_1, Double.valueOf(((UpdateMatch)it).getPrice()).floatValue());
                double _size_1 = ((UpdateMatch)it).getSize();
                double _multiply_1 = (_size_1 * 2000);
                asksRemoved.setPointSizes(PApplet.append(bids.getPointSizes(), Double.valueOf(Math.log(_multiply_1)).floatValue()));
              }
            }
          }
        }
      }
    };
    new GDAXClientOrders(_function);
  }
  
  @Override
  public void draw() {
    this.background(0);
    synchronized (this.plot) {
      final Procedure1<GPlot> _function = (GPlot it) -> {
        it.beginDraw();
        it.drawBackground();
        it.drawTitle();
        it.drawXAxis();
        it.drawYAxis();
        it.drawPoints();
        it.endDraw();
      };
      ObjectExtensions.<GPlot>operator_doubleArrow(
        this.plot, _function);
    }
  }
  
  public static void main(final String[] args) {
    String _name = OrderbookEvents.class.getName();
    OrderbookEvents _orderbookEvents = new OrderbookEvents();
    PApplet.runSketch(new String[] { _name }, _orderbookEvents);
  }
}
