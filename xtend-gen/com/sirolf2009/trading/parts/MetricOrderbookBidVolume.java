package com.sirolf2009.trading.parts;

import com.sirolf2009.commonwealth.trading.orderbook.ILimitOrder;
import com.sirolf2009.commonwealth.trading.orderbook.IOrderbook;
import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.AsyncMetric;
import io.reactivex.functions.Consumer;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.DoubleExtensions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class MetricOrderbookBidVolume extends AsyncMetric implements IExchangePart {
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Bid volume per second");
    final Consumer<IOrderbook> _function = (IOrderbook it) -> {
      try {
        double _doubleValue = ((ILimitOrder[])Conversions.unwrapArray(it.getBids(), ILimitOrder.class))[0].getPrice().doubleValue();
        double _doubleValue_1 = ((ILimitOrder[])Conversions.unwrapArray(it.getAsks(), ILimitOrder.class))[0].getPrice().doubleValue();
        double _plus = (_doubleValue + _doubleValue_1);
        final double mid = (_plus / 2);
        final Function1<ILimitOrder, Boolean> _function_1 = (ILimitOrder it_1) -> {
          double _doubleValue_2 = it_1.getPrice().doubleValue();
          double _minus = (mid - _doubleValue_2);
          return Boolean.valueOf((_minus <= 25d));
        };
        final Function1<ILimitOrder, Double> _function_2 = (ILimitOrder it_1) -> {
          return Double.valueOf(it_1.getAmount().doubleValue());
        };
        final Function2<Double, Double, Double> _function_3 = (Double a, Double b) -> {
          return Double.valueOf(DoubleExtensions.operator_plus(a, b));
        };
        final Double bids = IterableExtensions.<Double>reduce(IterableExtensions.<ILimitOrder, Double>map(IterableExtensions.<ILimitOrder>filter(it.getBids(), _function_1), _function_2), _function_3);
        if ((bids != null)) {
          this.set(bids);
        }
      } catch (final Throwable _t) {
        if (_t instanceof Exception) {
          final Exception e = (Exception)_t;
          System.err.println(("Failed to handle " + it));
          e.printStackTrace();
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    };
    this.getOrderbook().subscribe(_function);
  }
  
  @Focus
  public void setFocus() {
    this.getChart().setFocus();
  }
}
