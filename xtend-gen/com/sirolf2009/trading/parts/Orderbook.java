package com.sirolf2009.trading.parts;

import info.bitrich.xchangestream.bitfinex.BitfinexStreamingExchange;
import info.bitrich.xchangestream.core.StreamingExchange;
import info.bitrich.xchangestream.core.StreamingExchangeFactory;
import io.reactivex.functions.Consumer;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import javax.annotation.PostConstruct;
import org.eclipse.e4.ui.di.Focus;
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
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.DoubleExtensions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.knowm.xchange.currency.CurrencyPair;
import org.knowm.xchange.dto.marketdata.OrderBook;
import org.knowm.xchange.dto.trade.LimitOrder;

@SuppressWarnings("all")
public class Orderbook {
  @Data
  public static class Entry {
    private final Optional<LimitOrder> bid;
    
    private final Double cumulativeBid;
    
    private final Optional<LimitOrder> ask;
    
    private final Double cumulativeAsk;
    
    public Entry(final Optional<LimitOrder> bid, final Double cumulativeBid, final Optional<LimitOrder> ask, final Double cumulativeAsk) {
      super();
      this.bid = bid;
      this.cumulativeBid = cumulativeBid;
      this.ask = ask;
      this.cumulativeAsk = cumulativeAsk;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.bid== null) ? 0 : this.bid.hashCode());
      result = prime * result + ((this.cumulativeBid== null) ? 0 : this.cumulativeBid.hashCode());
      result = prime * result + ((this.ask== null) ? 0 : this.ask.hashCode());
      result = prime * result + ((this.cumulativeAsk== null) ? 0 : this.cumulativeAsk.hashCode());
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
      Orderbook.Entry other = (Orderbook.Entry) obj;
      if (this.bid == null) {
        if (other.bid != null)
          return false;
      } else if (!this.bid.equals(other.bid))
        return false;
      if (this.cumulativeBid == null) {
        if (other.cumulativeBid != null)
          return false;
      } else if (!this.cumulativeBid.equals(other.cumulativeBid))
        return false;
      if (this.ask == null) {
        if (other.ask != null)
          return false;
      } else if (!this.ask.equals(other.ask))
        return false;
      if (this.cumulativeAsk == null) {
        if (other.cumulativeAsk != null)
          return false;
      } else if (!this.cumulativeAsk.equals(other.cumulativeAsk))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("bid", this.bid);
      b.add("cumulativeBid", this.cumulativeBid);
      b.add("ask", this.ask);
      b.add("cumulativeAsk", this.cumulativeAsk);
      return b.toString();
    }
    
    @Pure
    public Optional<LimitOrder> getBid() {
      return this.bid;
    }
    
    @Pure
    public Double getCumulativeBid() {
      return this.cumulativeBid;
    }
    
    @Pure
    public Optional<LimitOrder> getAsk() {
      return this.ask;
    }
    
    @Pure
    public Double getCumulativeAsk() {
      return this.cumulativeAsk;
    }
  }
  
  private final List<Orderbook.Entry> entries = new ArrayList<Orderbook.Entry>();
  
  private Table table;
  
  private TableColumn bidPrice;
  
  private TableColumn bidAmount;
  
  private TableColumn bidCumAmount;
  
  private TableColumn askPrice;
  
  private TableColumn askAmount;
  
  private TableColumn askCumAmount;
  
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
    final DecimalFormat numberformat = new DecimalFormat("#########0.##");
    Table _table = new Table(comp, SWT.VIRTUAL);
    final Procedure1<Table> _function = (Table table) -> {
      table.setHeaderVisible(true);
      table.setBackground(gray);
      final Listener _function_1 = (Event it) -> {
        final TableItem item = ((TableItem) it.item);
        final int index = table.indexOf(item);
        final Function<LimitOrder, String> _function_2 = (LimitOrder it_1) -> {
          return it_1.getLimitPrice().toString();
        };
        String _orElse = this.entries.get(index).bid.<String>map(_function_2).orElse("");
        final Function<LimitOrder, String> _function_3 = (LimitOrder it_1) -> {
          return it_1.getRemainingAmount().toString();
        };
        String _orElse_1 = this.entries.get(index).bid.<String>map(_function_3).orElse("");
        String _format = numberformat.format(this.entries.get(index).cumulativeBid);
        String _format_1 = numberformat.format(this.entries.get(index).cumulativeAsk);
        final Function<LimitOrder, String> _function_4 = (LimitOrder it_1) -> {
          return it_1.getRemainingAmount().negate().toString();
        };
        String _orElse_2 = this.entries.get(index).ask.<String>map(_function_4).orElse("");
        final Function<LimitOrder, String> _function_5 = (LimitOrder it_1) -> {
          return it_1.getLimitPrice().toString();
        };
        String _orElse_3 = this.entries.get(index).ask.<String>map(_function_5).orElse("");
        item.setText(new String[] { _orElse, _orElse_1, _format, _format_1, _orElse_2, _orElse_3 });
        item.setBackground(0, green);
        item.setBackground(1, green);
        item.setBackground(2, green);
        item.setBackground(3, red);
        item.setBackground(4, red);
        item.setBackground(5, red);
      };
      table.addListener(SWT.SetData, _function_1);
      TableColumn _tableColumn = new TableColumn(table, SWT.NONE);
      this.bidPrice = _tableColumn;
      this.bidPrice.setText("Price");
      TableColumn _tableColumn_1 = new TableColumn(table, SWT.NONE);
      this.bidAmount = _tableColumn_1;
      this.bidAmount.setText("Amount");
      TableColumn _tableColumn_2 = new TableColumn(table, SWT.NONE);
      this.bidCumAmount = _tableColumn_2;
      this.bidCumAmount.setText("Cumulative");
      TableColumn _tableColumn_3 = new TableColumn(table, SWT.NONE);
      this.askCumAmount = _tableColumn_3;
      this.askCumAmount.setText("Cumulative");
      TableColumn _tableColumn_4 = new TableColumn(table, SWT.NONE);
      this.askAmount = _tableColumn_4;
      this.askAmount.setText("Amount");
      TableColumn _tableColumn_5 = new TableColumn(table, SWT.NONE);
      this.askPrice = _tableColumn_5;
      this.askPrice.setText("Price");
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
            Orderbook.this.bidPrice.setWidth((width / 6));
            Orderbook.this.bidAmount.setWidth((width / 6));
            Orderbook.this.bidCumAmount.setWidth((width / 6));
            Orderbook.this.askPrice.setWidth((width / 6));
            Orderbook.this.askAmount.setWidth((width / 6));
            Orderbook.this.askCumAmount.setWidth((width / 6));
            table.setSize(area.width, area.height);
          } else {
            table.setSize(area.width, area.height);
            Orderbook.this.bidPrice.setWidth((width / 6));
            Orderbook.this.bidAmount.setWidth((width / 6));
            Orderbook.this.bidCumAmount.setWidth((width / 6));
            Orderbook.this.askPrice.setWidth((width / 6));
            Orderbook.this.askAmount.setWidth((width / 6));
            Orderbook.this.askCumAmount.setWidth((width / 6));
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
          final Function<LimitOrder, Integer> _function_3 = (LimitOrder it_1) -> {
            int _intValue = it_1.getOriginalAmount().intValue();
            return Integer.valueOf((_intValue * 2));
          };
          final Integer size = this.entries.get(index).bid.<Integer>map(_function_3).orElse(Integer.valueOf(0));
          it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
          it.gc.setBackground(brightGreen);
          it.gc.fillRectangle(it.x, it.y, (size).intValue(), (it.height - 1));
          it.gc.setBackground(background);
          it.gc.drawText(item.getText(0), (it.x + 4), (it.y + 2), true);
        } else {
          if ((it.index == 2)) {
            final int size_1 = this.entries.get(index).cumulativeBid.intValue();
            it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
            it.gc.setBackground(brightGreen);
            int _width = this.bidAmount.getWidth();
            int _plus_2 = (it.x + _width);
            int _minus = (_plus_2 - size_1);
            int _minus_1 = (_minus - 1);
            it.gc.fillRectangle(_minus_1, it.y, size_1, (it.height - 1));
            it.gc.setBackground(background);
            it.gc.drawText(item.getText(2), (it.x + 4), (it.y + 2), true);
          } else {
            if ((it.index == 3)) {
              final int size_2 = this.entries.get(index).cumulativeAsk.intValue();
              it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
              it.gc.setBackground(brightRed);
              it.gc.fillRectangle(it.x, it.y, size_2, (it.height - 1));
              it.gc.setBackground(background);
              it.gc.drawText(item.getText(3), (it.x + 4), (it.y + 2), true);
            } else {
              if ((it.index == 5)) {
                final Function<LimitOrder, Integer> _function_4 = (LimitOrder it_1) -> {
                  int _intValue = it_1.getOriginalAmount().intValue();
                  return Integer.valueOf((_intValue * (-2)));
                };
                final Integer size_3 = this.entries.get(index).ask.<Integer>map(_function_4).orElse(Integer.valueOf(0));
                it.gc.fillRectangle(it.x, it.y, (it.width - 1), (it.height - 1));
                it.gc.setBackground(brightRed);
                int _width_1 = this.askAmount.getWidth();
                int _plus_3 = (it.x + _width_1);
                int _minus_2 = (_plus_3 - (size_3).intValue());
                it.gc.fillRectangle(_minus_2, it.y, (size_3).intValue(), (it.height - 1));
                it.gc.setBackground(background);
                it.gc.drawText(item.getText(5), (it.x + 4), (it.y + 2), true);
              }
            }
          }
        }
        it.gc.setBackground(background);
      };
      table.addListener(SWT.PaintItem, _function_2);
    };
    Table _doubleArrow = ObjectExtensions.<Table>operator_doubleArrow(_table, _function);
    this.table = _doubleArrow;
    final StreamingExchange exchange = StreamingExchangeFactory.INSTANCE.createExchange(BitfinexStreamingExchange.class.getName());
    exchange.connect().blockingAwait();
    final Consumer<OrderBook> _function_1 = (OrderBook it) -> {
      boolean _isDisposed = this.table.isDisposed();
      if (_isDisposed) {
        exchange.disconnect();
        return;
      }
      int _max = Math.max(it.getBids().size(), it.getAsks().size());
      final Function1<Integer, Pair<Optional<LimitOrder>, Optional<LimitOrder>>> _function_2 = (Integer index) -> {
        Optional<LimitOrder> _xifexpression = null;
        int _size = it.getBids().size();
        boolean _lessThan = ((index).intValue() < _size);
        if (_lessThan) {
          _xifexpression = Optional.<LimitOrder>of(it.getBids().get((index).intValue()));
        } else {
          _xifexpression = Optional.<LimitOrder>empty();
        }
        final Optional<LimitOrder> bid = _xifexpression;
        Optional<LimitOrder> _xifexpression_1 = null;
        int _size_1 = it.getAsks().size();
        boolean _lessThan_1 = ((index).intValue() < _size_1);
        if (_lessThan_1) {
          _xifexpression_1 = Optional.<LimitOrder>of(it.getAsks().get((index).intValue()));
        } else {
          _xifexpression_1 = Optional.<LimitOrder>empty();
        }
        final Optional<LimitOrder> ask = _xifexpression_1;
        return Pair.<Optional<LimitOrder>, Optional<LimitOrder>>of(bid, ask);
      };
      final List<Pair<Optional<LimitOrder>, Optional<LimitOrder>>> orders = IterableExtensions.<Pair<Optional<LimitOrder>, Optional<LimitOrder>>>toList(IterableExtensions.<Integer, Pair<Optional<LimitOrder>, Optional<LimitOrder>>>map(new ExclusiveRange(0, _max, true), _function_2));
      final Function1<Pair<Optional<LimitOrder>, Optional<LimitOrder>>, Orderbook.Entry> _function_3 = (Pair<Optional<LimitOrder>, Optional<LimitOrder>> it_1) -> {
        int _indexOf = orders.indexOf(it_1);
        final Function1<Integer, Double> _function_4 = (Integer it_2) -> {
          final Function<LimitOrder, Double> _function_5 = (LimitOrder it_3) -> {
            return Double.valueOf(it_3.getOriginalAmount().doubleValue());
          };
          return orders.get((it_2).intValue()).getKey().<Double>map(_function_5).orElse(Double.valueOf(0d));
        };
        final Function2<Double, Double, Double> _function_5 = (Double a, Double b) -> {
          return Double.valueOf(DoubleExtensions.operator_plus(a, b));
        };
        final Double cumulativeBid = IterableExtensions.<Double>reduce(IterableExtensions.<Integer, Double>map(new IntegerRange(0, _indexOf), _function_4), _function_5);
        int _indexOf_1 = orders.indexOf(it_1);
        final Function1<Integer, Double> _function_6 = (Integer it_2) -> {
          final Function<LimitOrder, Double> _function_7 = (LimitOrder it_3) -> {
            double _doubleValue = it_3.getOriginalAmount().doubleValue();
            return Double.valueOf((_doubleValue * (-1)));
          };
          return orders.get((it_2).intValue()).getValue().<Double>map(_function_7).orElse(Double.valueOf(0d));
        };
        final Function2<Double, Double, Double> _function_7 = (Double a, Double b) -> {
          return Double.valueOf(DoubleExtensions.operator_plus(a, b));
        };
        final Double cumulativeAsk = IterableExtensions.<Double>reduce(IterableExtensions.<Integer, Double>map(new IntegerRange(0, _indexOf_1), _function_6), _function_7);
        Optional<LimitOrder> _key = it_1.getKey();
        Optional<LimitOrder> _value = it_1.getValue();
        return new Orderbook.Entry(_key, cumulativeBid, _value, cumulativeAsk);
      };
      final List<Orderbook.Entry> newEntries = ListExtensions.<Pair<Optional<LimitOrder>, Optional<LimitOrder>>, Orderbook.Entry>map(orders, _function_3);
      final Runnable _function_4 = () -> {
        boolean _isDisposed_1 = this.table.isDisposed();
        if (_isDisposed_1) {
          exchange.disconnect();
          return;
        }
        this.entries.clear();
        this.entries.addAll(newEntries);
        this.table.clearAll();
        this.table.setItemCount(newEntries.size());
      };
      parent.getDisplay().syncExec(_function_4);
    };
    exchange.getStreamingMarketDataService().getOrderBook(CurrencyPair.BTC_USD).subscribe(_function_1);
  }
  
  @Focus
  public void setFocus() {
    this.table.setFocus();
  }
}
