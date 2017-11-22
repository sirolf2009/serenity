package com.sirolf2009.serenity.dto;

import com.sirolf2009.serenity.dto.AbstractUpdate;
import com.sirolf2009.serenity.dto.Reason;
import com.sirolf2009.serenity.dto.Side;
import com.sirolf2009.serenity.dto.UpdateType;
import java.util.Date;
import java.util.UUID;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

/**
 * The order is no longer on the order book. Sent for all orders for which there was a received message.
 * This message can result from an order being canceled or filled. There will be no more messages for this order_id after a done message.
 * remaining_size indicates how much of the order went unfilled; this will be 0 for filled orders.
 * market orders will not have a remaining_size or price field as they are never on the open order book at a given price.
 */
@Data
@SuppressWarnings("all")
public class UpdateDone extends AbstractUpdate {
  private final UpdateType type = UpdateType.DONE;
  
  private final UUID orderID;
  
  private final double price;
  
  private final Reason reason;
  
  private final Side side;
  
  private final double remaining_size;
  
  public UpdateDone(final Date time, final String productID, final long sequence, final UUID orderID, final double price, final Reason reason, final Side side, final double remaining_size) {
    super(time, productID, sequence);
    this.orderID = orderID;
    this.price = price;
    this.reason = reason;
    this.side = side;
    this.remaining_size = remaining_size;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = super.hashCode();
    result = prime * result + ((this.type== null) ? 0 : this.type.hashCode());
    result = prime * result + ((this.orderID== null) ? 0 : this.orderID.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.price) ^ (Double.doubleToLongBits(this.price) >>> 32));
    result = prime * result + ((this.reason== null) ? 0 : this.reason.hashCode());
    result = prime * result + ((this.side== null) ? 0 : this.side.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.remaining_size) ^ (Double.doubleToLongBits(this.remaining_size) >>> 32));
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
    if (!super.equals(obj))
      return false;
    UpdateDone other = (UpdateDone) obj;
    if (this.type == null) {
      if (other.type != null)
        return false;
    } else if (!this.type.equals(other.type))
      return false;
    if (this.orderID == null) {
      if (other.orderID != null)
        return false;
    } else if (!this.orderID.equals(other.orderID))
      return false;
    if (Double.doubleToLongBits(other.price) != Double.doubleToLongBits(this.price))
      return false; 
    if (this.reason == null) {
      if (other.reason != null)
        return false;
    } else if (!this.reason.equals(other.reason))
      return false;
    if (this.side == null) {
      if (other.side != null)
        return false;
    } else if (!this.side.equals(other.side))
      return false;
    if (Double.doubleToLongBits(other.remaining_size) != Double.doubleToLongBits(this.remaining_size))
      return false; 
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    String result = new ToStringBuilder(this)
    	.addAllFields()
    	.toString();
    return result;
  }
  
  @Pure
  public UpdateType getType() {
    return this.type;
  }
  
  @Pure
  public UUID getOrderID() {
    return this.orderID;
  }
  
  @Pure
  public double getPrice() {
    return this.price;
  }
  
  @Pure
  public Reason getReason() {
    return this.reason;
  }
  
  @Pure
  public Side getSide() {
    return this.side;
  }
  
  @Pure
  public double getRemaining_size() {
    return this.remaining_size;
  }
}
