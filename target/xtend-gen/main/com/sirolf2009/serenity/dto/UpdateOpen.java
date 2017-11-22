package com.sirolf2009.serenity.dto;

import com.sirolf2009.serenity.dto.AbstractUpdate;
import com.sirolf2009.serenity.dto.Side;
import com.sirolf2009.serenity.dto.UpdateType;
import java.util.Date;
import java.util.UUID;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

/**
 * The order is now open on the order book.
 * This message will only be sent for orders which are not fully filled immediately.
 * remaining_size will indicate how much of the order is unfilled and going on the book.
 */
@Data
@SuppressWarnings("all")
public class UpdateOpen extends AbstractUpdate {
  private final UpdateType type = UpdateType.OPEN;
  
  private final UUID orderID;
  
  private final double price;
  
  private final double remainingSize;
  
  private final Side side;
  
  public UpdateOpen(final Date time, final String productID, final long sequence, final UUID orderID, final double price, final double remainingSize, final Side side) {
    super(time, productID, sequence);
    this.orderID = orderID;
    this.price = price;
    this.remainingSize = remainingSize;
    this.side = side;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = super.hashCode();
    result = prime * result + ((this.type== null) ? 0 : this.type.hashCode());
    result = prime * result + ((this.orderID== null) ? 0 : this.orderID.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.price) ^ (Double.doubleToLongBits(this.price) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.remainingSize) ^ (Double.doubleToLongBits(this.remainingSize) >>> 32));
    result = prime * result + ((this.side== null) ? 0 : this.side.hashCode());
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
    UpdateOpen other = (UpdateOpen) obj;
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
    if (Double.doubleToLongBits(other.remainingSize) != Double.doubleToLongBits(this.remainingSize))
      return false; 
    if (this.side == null) {
      if (other.side != null)
        return false;
    } else if (!this.side.equals(other.side))
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
  public double getRemainingSize() {
    return this.remainingSize;
  }
  
  @Pure
  public Side getSide() {
    return this.side;
  }
}
