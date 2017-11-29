package com.sirolf2009.trading.parts;

import com.google.common.util.concurrent.AtomicDouble;
import com.sirolf2009.trading.IExchangePart;
import io.reactivex.functions.Consumer;
import java.util.HashMap;
import javax.annotation.PostConstruct;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.knowm.xchange.dto.marketdata.Trade;

@SuppressWarnings("all")
public class VolumeByPrice implements IExchangePart {
  @Data
  public static class Entry {
    private final double buyAmount;
    
    private final double sellAmount;
    
    public Entry(final double buyAmount, final double sellAmount) {
      super();
      this.buyAmount = buyAmount;
      this.sellAmount = sellAmount;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + (int) (Double.doubleToLongBits(this.buyAmount) ^ (Double.doubleToLongBits(this.buyAmount) >>> 32));
      result = prime * result + (int) (Double.doubleToLongBits(this.sellAmount) ^ (Double.doubleToLongBits(this.sellAmount) >>> 32));
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      VolumeByPrice.Entry other = (VolumeByPrice.Entry) obj;
      if (Double.doubleToLongBits(other.buyAmount) != Double.doubleToLongBits(this.buyAmount))
        return false; 
      if (Double.doubleToLongBits(other.sellAmount) != Double.doubleToLongBits(this.sellAmount))
        return false; 
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("buyAmount", this.buyAmount);
      b.add("sellAmount", this.sellAmount);
      return b.toString();
    }
    
    @Pure
    public double getBuyAmount() {
      return this.buyAmount;
    }
    
    @Pure
    public double getSellAmount() {
      return this.sellAmount;
    }
  }
  
  private final HashMap<Double, VolumeByPrice.Entry> map = new HashMap<Double, VolumeByPrice.Entry>();
  
  private final AtomicDouble max = new AtomicDouble(0);
  
  private Table table;
  
  private TableColumn price;
  
  private TableColumn amount;
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    final Color green = parent.getDisplay().getSystemColor(SWT.COLOR_DARK_GREEN);
    final Color red = parent.getDisplay().getSystemColor(SWT.COLOR_DARK_RED);
    Display _display = parent.getDisplay();
    int _green = green.getGreen();
    int _plus = (_green + 40);
    final Color brightGreen = new Color(_display, 0, _plus, 0);
    Display _display_1 = parent.getDisplay();
    int _red = red.getRed();
    int _plus_1 = (_red + 40);
    final Color brightRed = new Color(_display_1, _plus_1, 0, 0);
    final Color gray = parent.getDisplay().getSystemColor(SWT.COLOR_GRAY);
    final Composite comp = new Composite(parent, SWT.NONE);
    Table _table = new Table(comp, SWT.VIRTUAL);
    final Procedure1<Table> _function = (Table table) -> {
      table.setHeaderVisible(true);
      table.setLinesVisible(true);
      table.setBackground(gray);
      final Listener _function_1 = (Event it) -> {
        final TableItem item = ((TableItem) it.item);
        final int index = table.indexOf(item);
        final Double price = ListExtensions.<Double>reverse(IterableExtensions.<Double>sort(this.map.keySet())).get(index);
        final VolumeByPrice.Entry entry = this.map.get(price);
        String _string = price.toString();
        String _string_1 = Double.valueOf((entry.buyAmount + entry.sellAmount)).toString();
        item.setText(new String[] { _string, _string_1 });
      };
      table.addListener(SWT.SetData, _function_1);
      TableColumn _tableColumn = new TableColumn(table, SWT.NONE);
      this.price = _tableColumn;
      this.price.setText("Price");
      TableColumn _tableColumn_1 = new TableColumn(table, SWT.NONE);
      this.amount = _tableColumn_1;
      this.amount.setText("Amount");
      comp.addControlListener(new ControlListener() {
        @Override
        public void controlResized(final ControlEvent e) {
          final Rectangle area = comp.getClientArea();
          final Point size = table.computeSize(SWT.DEFAULT, SWT.DEFAULT);
          final ScrollBar vBar = table.getVerticalBar();
          int width = ((area.width - table.computeTrim(0, 0, 0, 0).width) - vBar.getSize().x);
          int _headerHeight = table.getHeaderHeight();
          int _plus = (area.height + _headerHeight);
          boolean _greaterThan = (size.y > _plus);
          if (_greaterThan) {
            final Point vBarSize = vBar.getSize();
            int _width = width;
            width = (_width - vBarSize.x);
          }
          final Point oldSize = table.getSize();
          if ((oldSize.x > area.width)) {
            VolumeByPrice.this.price.setWidth((width / 2));
            VolumeByPrice.this.amount.setWidth((width / 2));
            table.setSize(area.width, area.height);
          } else {
            table.setSize(area.width, area.height);
            VolumeByPrice.this.price.setWidth((width / 2));
            VolumeByPrice.this.amount.setWidth((width / 2));
          }
        }
        
        @Override
        public void controlMoved(final ControlEvent e) {
        }
      });
      final Listener _function_2 = (Event it) -> {
        final Color background = it.gc.getBackground();
        final TableItem item = ((TableItem) it.item);
        final int index = table.indexOf(item);
        if ((it.index == 0)) {
          final Double price = ListExtensions.<Double>reverse(IterableExtensions.<Double>sort(this.map.keySet())).get(index);
          final VolumeByPrice.Entry entry = this.map.get(price);
          final double amount = (entry.buyAmount + entry.sellAmount);
          final double largestAmount = this.max.get();
          int _width = this.price.getWidth();
          final double size = ((amount / largestAmount) * _width);
          int _width_1 = this.price.getWidth();
          final double buySize = ((entry.buyAmount / largestAmount) * _width_1);
          final double sellSize = (size - buySize);
          it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
          it.gc.setBackground(brightGreen);
          it.gc.fillRectangle(it.x, it.y, Double.valueOf(buySize).intValue(), (it.height - 1));
          it.gc.setBackground(brightRed);
          it.gc.fillRectangle(Double.valueOf(buySize).intValue(), it.y, Double.valueOf(sellSize).intValue(), (it.height - 1));
          it.gc.setBackground(background);
          it.gc.drawText(item.getText(0), (it.x + 4), (it.y + 2), true);
        }
        it.gc.setBackground(background);
      };
      table.addListener(SWT.PaintItem, _function_2);
    };
    Table _doubleArrow = ObjectExtensions.<Table>operator_doubleArrow(_table, _function);
    this.table = _doubleArrow;
    final Consumer<Trade> _function_1 = (Trade it) -> {
      boolean _isDisposed = this.table.isDisposed();
      if (_isDisposed) {
        return;
      }
      double _doubleValue = it.getPrice().doubleValue();
      double _divide = (_doubleValue / 10.0);
      long _round = Math.round(_divide);
      final double price = (_round * 10d);
      final double amount = it.getOriginalAmount().doubleValue();
      final VolumeByPrice.Entry existing = this.map.get(Double.valueOf(price));
      VolumeByPrice.Entry _xifexpression = null;
      if ((existing != null)) {
        VolumeByPrice.Entry _xifexpression_1 = null;
        if ((amount > 0)) {
          _xifexpression_1 = new VolumeByPrice.Entry((existing.buyAmount + amount), existing.sellAmount);
        } else {
          _xifexpression_1 = new VolumeByPrice.Entry(existing.buyAmount, (existing.sellAmount - amount));
        }
        _xifexpression = _xifexpression_1;
      } else {
        VolumeByPrice.Entry _xifexpression_2 = null;
        if ((amount > 0)) {
          _xifexpression_2 = new VolumeByPrice.Entry(amount, 0);
        } else {
          _xifexpression_2 = new VolumeByPrice.Entry(0, (-amount));
        }
        _xifexpression = _xifexpression_2;
      }
      final VolumeByPrice.Entry newEntry = _xifexpression;
      this.map.put(Double.valueOf(price), newEntry);
      double _get = this.max.get();
      boolean _greaterThan = ((newEntry.buyAmount + newEntry.sellAmount) > _get);
      if (_greaterThan) {
        this.max.set((newEntry.buyAmount + newEntry.sellAmount));
      }
      final Runnable _function_2 = () -> {
        boolean _isDisposed_1 = this.table.isDisposed();
        if (_isDisposed_1) {
          return;
        }
        this.table.clearAll();
        this.table.setItemCount(this.map.keySet().size());
        this.table.setTopIndex(ListExtensions.<Double>reverse(IterableExtensions.<Double>sort(this.map.keySet())).indexOf(newEntry));
      };
      parent.getDisplay().syncExec(_function_2);
    };
    this.getTrades().subscribe(_function_1);
  }
}
