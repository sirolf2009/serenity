package com.sirolf2009.trading.parts;

import com.google.common.util.concurrent.AtomicDouble;
import com.sirolf2009.commonwealth.trading.ITrade;
import com.sirolf2009.trading.IExchangePart;
import com.sirolf2009.trading.parts.Metric;
import io.reactivex.functions.Consumer;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
import org.eclipse.swt.widgets.Composite;

@SuppressWarnings("all")
public class MetricBuyVolumePerSecond extends Metric implements IExchangePart {
  private final AtomicDouble count = new AtomicDouble(0);
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    this.init(parent, "Buy volume per second");
    final Consumer<ITrade> _function = (ITrade it) -> {
      double _doubleValue = it.getAmount().doubleValue();
      boolean _greaterThan = (_doubleValue > 0);
      if (_greaterThan) {
        this.count.addAndGet(it.getAmount().doubleValue());
      }
    };
    this.getTrades().subscribe(_function);
  }
  
  @Focus
  public void setFocus() {
    this.getChart().setFocus();
  }
  
  @Override
  public Double measure() {
    final double value = this.count.get();
    this.count.set(0);
    return Double.valueOf(value);
  }
}
