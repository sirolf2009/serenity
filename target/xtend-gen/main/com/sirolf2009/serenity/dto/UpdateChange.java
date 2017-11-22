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
 * An order has changed.
 * This is the result of self-trade prevention adjusting the order size or available funds.
 * Orders can only decrease in size or funds.
 * change messages are sent anytime an order changes in size; this includes resting orders (open) as well as received but not yet open.
 * change messages are also sent when a new market order goes through self trade prevention and the funds for the market order have changed.
 */
@Data
@SuppressWarnings("all")
public class UpdateChange extends AbstractUpdate {
  private final UpdateType type = UpdateType.CHANGE;
  
  private final UUID orderID;
  
  private final double newSize;
  
  private final double oldSize;
  
  private final double price;
  
  private final Side side;
  
  public UpdateChange(final Date time, final String productID, final long sequence, final UUID orderID, final double newSize, final double oldSize, final double price, final Side side) {
    super(time, productID, sequence);
    this.orderID = orderID;
    this.newSize = newSize;
    this.oldSize = oldSize;
    this.price = price;
    this.side = side;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = super.hashCode();
    result = prime * result + ((this.type== null) ? 0 : this.type.hashCode());
    result = prime * result + ((this.orderID== null) ? 0 : this.orderID.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.newSize) ^ (Double.doubleToLongBits(this.newSize) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.oldSize) ^ (Double.doubleToLongBits(this.oldSize) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.price) ^ (Double.doubleToLongBits(this.price) >>> 32));
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
    UpdateChange other = (UpdateChange) obj;
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
    if (Double.doubleToLongBits(other.newSize) != Double.doubleToLongBits(this.newSize))
      return false; 
    if (Double.doubleToLongBits(other.oldSize) != Double.doubleToLongBits(this.oldSize))
      return false; 
    if (Double.doubleToLongBits(other.price) != Double.doubleToLongBits(this.price))
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
  public double getNewSize() {
    return this.newSize;
  }
  
  @Pure
  public double getOldSize() {
    return this.oldSize;
  }
  
  @Pure
  public double getPrice() {
    return this.price;
  }
  
  @Pure
  public Side getSide() {
    return this.side;
  }
}
