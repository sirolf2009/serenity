package com.sirolf2009.trading.parts;

import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.AsyncMetric;
import io.reactivex.functions.Consumer;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.widgets.Composite;
import org.knowm.xchange.dto.marketdata.OrderBook;

@SuppressWarnings("all")
public class MetricSpread extends AsyncMetric implements IExchangePart {
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Spread");
    final Consumer<OrderBook> _function = (OrderBook it) -> {
      this.set(Double.valueOf(it.getAsks().get(0).getLimitPrice().subtract(it.getBids().get(0).getLimitPrice()).doubleValue()));
    };
    this.getOrderbook().subscribe(_function);
  }
  
  @Focus
  public void setFocus() {
    this.getChart().setFocus();
  }
}
