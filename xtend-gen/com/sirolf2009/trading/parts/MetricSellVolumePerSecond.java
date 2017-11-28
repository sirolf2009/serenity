package com.sirolf2009.trading.parts;

import com.google.common.util.concurrent.AtomicDouble;
import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.Metric;
import io.reactivex.functions.Consumer;
import java.math.BigDecimal;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.widgets.Composite;
import org.knowm.xchange.dto.marketdata.Trade;

@SuppressWarnings("all")
public class MetricSellVolumePerSecond extends Metric implements IExchangePart {
  private final AtomicDouble count = new AtomicDouble(0);
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Sell volume per second");
    final Consumer<Trade> _function = (Trade it) -> {
      int _compareTo = it.getOriginalAmount().compareTo(BigDecimal.ZERO);
      boolean _lessThan = (_compareTo < 0);
      if (_lessThan) {
        this.count.addAndGet(it.getOriginalAmount().negate().doubleValue());
      }
    };
    this.getTrades().subscribe(_function);
  }
  
  @Focus
  public void setFocus() {
    this.getChart().setFocus();
  }
  
  @Override
  public Double get() {
    final double value = this.count.get();
    this.count.set(0);
    return Double.valueOf(value);
  }
}
