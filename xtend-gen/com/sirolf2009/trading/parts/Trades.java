package com.sirolf2009.trading.parts;

import com.sirolf2009.commonwealth.trading.ITrade;
import com.sirolf2009.trading.IExchangePart;
import io.reactivex.functions.Consumer;
import java.text.SimpleDateFormat;
import javax.annotation.PostConstruct;
import org.apache.commons.collections4.queue.CircularFifoQueue;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class Trades implements IExchangePart {
  private final CircularFifoQueue<ITrade> buffer = new CircularFifoQueue<ITrade>(512);
  
  private Table table;
  
  private TableColumn time;
  
  private TableColumn price;
  
  private TableColumn amount;
  
  @PostConstruct
  public void createPartControl(final Composite parent) {
    final Color green = parent.getDisplay().getSystemColor(SWT.COLOR_DARK_GREEN);
    final Color red = parent.getDisplay().getSystemColor(SWT.COLOR_DARK_RED);
    int _green = green.getGreen();
    int _plus = (_green + 40);
    final Color brightGreen = new Color(null, 0, _plus, 0);
    int _red = red.getRed();
    int _plus_1 = (_red + 40);
    final Color brightRed = new Color(null, _plus_1, 0, 0);
    final Color gray = parent.getDisplay().getSystemColor(SWT.COLOR_GRAY);
    final Composite comp = new Composite(parent, SWT.NONE);
    final SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    Table _table = new Table(comp, SWT.VIRTUAL);
    final Procedure1<Table> _function = (Table table) -> {
      table.setHeaderVisible(true);
      table.setLinesVisible(true);
      table.setBackground(gray);
      final Listener _function_1 = (Event it) -> {
        final TableItem item = ((TableItem) it.item);
        final int index = table.indexOf(item);
        int _size = this.buffer.size();
        int _minus = (_size - 1);
        int _minus_1 = (_minus - index);
        final ITrade trade = this.buffer.get(_minus_1);
        String _format = sdf.format(trade.getPoint().getDate());
        String _string = trade.getPrice().toString();
        String _string_1 = trade.getAmount().toString();
        item.setText(new String[] { _format, _string, _string_1 });
        Color _xifexpression = null;
        double _doubleValue = trade.getAmount().doubleValue();
        boolean _greaterThan = (_doubleValue > 0);
        if (_greaterThan) {
          _xifexpression = green;
        } else {
          _xifexpression = red;
        }
        final Color color = _xifexpression;
        item.setBackground(0, color);
        item.setBackground(1, color);
        item.setBackground(2, color);
      };
      table.addListener(SWT.SetData, _function_1);
      TableColumn _tableColumn = new TableColumn(table, SWT.NONE);
      this.time = _tableColumn;
      this.time.setText("Time");
      TableColumn _tableColumn_1 = new TableColumn(table, SWT.NONE);
      this.price = _tableColumn_1;
      this.price.setText("Price");
      TableColumn _tableColumn_2 = new TableColumn(table, SWT.NONE);
      this.amount = _tableColumn_2;
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
            Trades.this.time.setWidth((width / 3));
            Trades.this.price.setWidth((width / 3));
            Trades.this.amount.setWidth((width / 3));
            table.setSize(area.width, area.height);
          } else {
            table.setSize(area.width, area.height);
            Trades.this.time.setWidth((width / 3));
            Trades.this.price.setWidth((width / 3));
            Trades.this.amount.setWidth((width / 3));
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
          int _size = this.buffer.size();
          int _minus = (_size - 1);
          int _minus_1 = (_minus - index);
          int _intValue = this.buffer.get(_minus_1).getAmount().intValue();
          final int size = (_intValue * 2);
          it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
          if ((size > 0)) {
            it.gc.setBackground(brightGreen);
            it.gc.fillRectangle(it.x, it.y, size, (it.height - 1));
          } else {
            it.gc.setBackground(brightRed);
            it.gc.fillRectangle(it.x, it.y, (size * (-1)), (it.height - 1));
          }
          it.gc.setBackground(background);
          it.gc.drawText(item.getText(0), (it.x + 4), (it.y + 2), true);
        }
        it.gc.setBackground(background);
      };
      table.addListener(SWT.PaintItem, _function_2);
    };
    Table _doubleArrow = ObjectExtensions.<Table>operator_doubleArrow(_table, _function);
    this.table = _doubleArrow;
    final Consumer<ITrade> _function_1 = (ITrade it) -> {
      boolean _isDisposed = this.table.isDisposed();
      if (_isDisposed) {
        return;
      }
      this.buffer.add(it);
      final Runnable _function_2 = () -> {
        boolean _isDisposed_1 = this.table.isDisposed();
        if (_isDisposed_1) {
          return;
        }
        this.table.clearAll();
        this.table.setItemCount(this.buffer.size());
      };
      parent.getDisplay().syncExec(_function_2);
    };
    this.getTrades().subscribe(_function_1);
  }
}
