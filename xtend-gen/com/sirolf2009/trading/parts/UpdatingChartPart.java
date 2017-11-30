package com.sirolf2009.trading.parts;

import com.sirolf2009.trading.parts.ChartPart;
import java.time.Duration;
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import org.apache.commons.collections4.queue.CircularFifoQueue;
import org.swtchart.Chart;

@SuppressWarnings("all")
public abstract class UpdatingChartPart<T extends Object> extends ChartPart {
  public void init(final Chart chart, final String name) {
    final CircularFifoQueue<T> buffer = this.createBuffer();
    final Timer timer = new Timer(name);
    timer.scheduleAtFixedRate(new TimerTask() {
      @Override
      public void run() {
        boolean _isDisposed = chart.isDisposed();
        if (_isDisposed) {
          return;
        }
        UpdatingChartPart.this.update(chart, buffer);
      }
    }, this.getFirstRunTime(), this.getPeriod());
  }
  
  public void update(final Chart chart, final CircularFifoQueue<T> buffer) {
    final T newValue = this.get();
    boolean _isValid = this.isValid(newValue);
    if (_isValid) {
      buffer.add(newValue);
      final Runnable _function = () -> {
        boolean _isDisposed = chart.isDisposed();
        if (_isDisposed) {
          return;
        }
        this.setData(chart, buffer);
        chart.redraw();
      };
      chart.getDisplay().syncExec(_function);
    }
  }
  
  public abstract T get();
  
  public abstract CircularFifoQueue<T> createBuffer();
  
  public abstract void setData(final Chart chart, final CircularFifoQueue<T> buffer);
  
  public boolean isValid(final T t) {
    return true;
  }
  
  public Date getFirstRunTime() {
    final Calendar cal = Calendar.getInstance();
    cal.set(Calendar.MILLISECOND, 0);
    int _get = cal.get(Calendar.SECOND);
    int _plus = (_get + 1);
    cal.set(Calendar.SECOND, _plus);
    return cal.getTime();
  }
  
  public long getPeriod() {
    return Duration.ofSeconds(1).toMillis();
  }
}
