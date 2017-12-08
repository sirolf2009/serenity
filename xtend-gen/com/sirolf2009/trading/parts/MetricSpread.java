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

@SuppressWarnings("all")
public class MetricSpread extends AsyncMetric implements IExchangePart {
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Spread");
    final Consumer<IOrderbook> _function = (IOrderbook it) -> {
      double _doubleValue = ((ILimitOrder[])Conversions.unwrapArray(it.getAsks(), ILimitOrder.class))[0].getPrice().doubleValue();
      double _doubleValue_1 = ((ILimitOrder[])Conversions.unwrapArray(it.getBids(), ILimitOrder.class))[0].getPrice().doubleValue();
      double _minus = (_doubleValue - _doubleValue_1);
      this.set(Double.valueOf(_minus));
    };
    this.getOrderbook().subscribe(_function);
  }
  
  @Focus
  public void setFocus() {
    this.getChart().setFocus();
  }
}
