package com.sirolf2009.serenity;

import com.google.gson.JsonObject;
import com.sirolf2009.serenity.dto.IUpdate;
import com.sirolf2009.serenity.dto.Reason;
import com.sirolf2009.serenity.dto.Side;
import com.sirolf2009.serenity.dto.UpdateChange;
import com.sirolf2009.serenity.dto.UpdateDone;
import com.sirolf2009.serenity.dto.UpdateMatch;
import com.sirolf2009.serenity.dto.UpdateOpen;
import com.sirolf2009.serenity.dto.UpdateType;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class UpdateParser implements Function<JsonObject, Optional<IUpdate>> {
  private final static Logger log = LogManager.getLogger();
  
  @Override
  public Optional<IUpdate> apply(final JsonObject object) {
    try {
      final UpdateType type = UpdateType.valueOf(this.string(object, "type").toUpperCase());
      if ((type == UpdateType.OPEN)) {
        final Side side = this.side(object, "side");
        final Double price = this.getDouble(object, "price");
        final UUID orderID = this.uuid(object, "order_id");
        final Double remainingSize = this.getDouble(object, "remaining_size");
        final String productID = this.string(object, "product_id");
        final Long sequence = this.getLong(object, "sequence");
        final Date time = this.date(object, "time");
        UpdateOpen _updateOpen = new UpdateOpen(time, productID, (sequence).longValue(), orderID, (price).doubleValue(), (remainingSize).doubleValue(), side);
        return Optional.<IUpdate>of(_updateOpen);
      } else {
        if ((type == UpdateType.DONE)) {
          final Side side_1 = this.side(object, "side");
          final UUID orderID_1 = this.uuid(object, "order_id");
          final Reason reason = this.reason(object, "reason");
          final String productID_1 = this.string(object, "product_id");
          Double _xifexpression = null;
          boolean _has = object.has("price");
          if (_has) {
            _xifexpression = this.getDouble(object, "price");
          } else {
            _xifexpression = Double.valueOf(Double.NaN);
          }
          final Double price_1 = _xifexpression;
          final Double remainingSize_1 = this.getDouble(object, "remaining_size");
          final Long sequence_1 = this.getLong(object, "sequence");
          final Date time_1 = this.date(object, "time");
          UpdateDone _updateDone = new UpdateDone(time_1, productID_1, (sequence_1).longValue(), orderID_1, (price_1).doubleValue(), reason, side_1, (remainingSize_1).doubleValue());
          return Optional.<IUpdate>of(_updateDone);
        } else {
          if ((type == UpdateType.MATCH)) {
            final Long tradeID = this.getLong(object, "trade_id");
            final UUID makerOrderID = this.uuid(object, "maker_order_id");
            final UUID takerOrderID = this.uuid(object, "taker_order_id");
            final Side side_2 = this.side(object, "side");
            final Double size = this.getDouble(object, "size");
            final Double price_2 = this.getDouble(object, "price");
            final String productID_2 = this.string(object, "product_id");
            final Long sequence_2 = this.getLong(object, "sequence");
            final Date time_2 = this.date(object, "time");
            UpdateMatch _updateMatch = new UpdateMatch(time_2, productID_2, (sequence_2).longValue(), (tradeID).longValue(), makerOrderID, takerOrderID, (size).doubleValue(), (price_2).doubleValue(), side_2);
            return Optional.<IUpdate>of(_updateMatch);
          } else {
            if ((type == UpdateType.CHANGE)) {
              final Date time_3 = this.date(object, "time");
              final Long sequence_3 = this.getLong(object, "sequence");
              final UUID orderID_2 = this.uuid(object, "order_id");
              final String productID_3 = this.string(object, "product_id");
              final Double newSize = this.getDouble(object, "new_size");
              final Double oldSize = this.getDouble(object, "old_size");
              final Double price_3 = this.getDouble(object, "price");
              final Side side_3 = this.side(object, "side");
              UpdateChange _updateChange = new UpdateChange(time_3, productID_3, (sequence_3).longValue(), orderID_2, (newSize).doubleValue(), (oldSize).doubleValue(), (price_3).doubleValue(), side_3);
              return Optional.<IUpdate>of(_updateChange);
            }
          }
        }
      }
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        UpdateParser.log.warn(("Unknown object: " + object), e);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return Optional.<IUpdate>empty();
  }
  
  public Side side(final JsonObject object, final String key) {
    return Side.valueOf(this.string(object, key).toUpperCase());
  }
  
  public Reason reason(final JsonObject object, final String key) {
    return Reason.valueOf(this.string(object, key).toUpperCase());
  }
  
  public Date date(final JsonObject object, final String key) {
    try {
      return new SimpleDateFormat("yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSX").parse(this.string(object, key));
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public UUID uuid(final JsonObject object, final String key) {
    return UUID.fromString(this.string(object, key));
  }
  
  public String string(final JsonObject object, final String key) {
    return object.getAsJsonPrimitive(key).getAsString();
  }
  
  public Double getDouble(final JsonObject object, final String key) {
    return Double.valueOf(object.getAsJsonPrimitive(key).getAsDouble());
  }
  
  public Integer getInt(final JsonObject object, final String key) {
    return Integer.valueOf(object.getAsJsonPrimitive(key).getAsInt());
  }
  
  public Long getLong(final JsonObject object, final String key) {
    return Long.valueOf(object.getAsJsonPrimitive(key).getAsLong());
  }
}
