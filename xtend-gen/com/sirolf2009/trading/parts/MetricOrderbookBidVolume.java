package com.sirolf2009.trading.parts;

import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.AsyncMetric;
import io.reactivex.functions.Consumer;
import java.math.BigDecimal;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.xtext.xbase.lib.DoubleExtensions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.knowm.xchange.dto.marketdata.OrderBook;
import org.knowm.xchange.dto.trade.LimitOrder;

@SuppressWarnings("all")
public class MetricOrderbookBidVolume extends AsyncMetric implements IExchangePart {
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Bid volume per second");
    final Consumer<OrderBook> _function = (OrderBook it) -> {
      try {
        final double mid = it.getBids().get(0).getLimitPrice().add(it.getAsks().get(0).getLimitPrice()).divide(BigDecimal.valueOf(2)).doubleValue();
        final Function1<LimitOrder, Boolean> _function_1 = (LimitOrder it_1) -> {
          double _doubleValue = it_1.getLimitPrice().doubleValue();
          double _minus = (mid - _doubleValue);
          return Boolean.valueOf((_minus <= 25d));
        };
        final Function1<LimitOrder, Double> _function_2 = (LimitOrder it_1) -> {
          return Double.valueOf(it_1.getRemainingAmount().doubleValue());
        };
        final Function2<Double, Double, Double> _function_3 = (Double a, Double b) -> {
          return Double.valueOf(DoubleExtensions.operator_plus(a, b));
        };
        final Double bids = IterableExtensions.<Double>reduce(IterableExtensions.<LimitOrder, Double>map(IterableExtensions.<LimitOrder>filter(it.getBids(), _function_1), _function_2), _function_3);
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
