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
 * A trade occurred between two orders.
 * The aggressor or taker order is the one executing immediately after being received and the maker order is a resting order on the book.
 * The side field indicates the maker order side.
 * If the side is sell this indicates the maker was a sell order and the match is considered an up-tick.
 * A buy side match is a down-tick.
 */
@Data
@SuppressWarnings("all")
public class UpdateMatch extends AbstractUpdate {
  private final UpdateType type = UpdateType.MATCH;
  
  private final long tradeID;
  
  private final UUID makerOrderID;
  
  private final UUID takerOrderID;
  
  private final double size;
  
  private final double price;
  
  private final Side side;
  
  public UpdateMatch(final Date time, final String productID, final long sequence, final long tradeID, final UUID makerOrderID, final UUID takerOrderID, final double size, final double price, final Side side) {
    super(time, productID, sequence);
    this.tradeID = tradeID;
    this.makerOrderID = makerOrderID;
    this.takerOrderID = takerOrderID;
    this.size = size;
    this.price = price;
    this.side = side;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = super.hashCode();
    result = prime * result + ((this.type== null) ? 0 : this.type.hashCode());
    result = prime * result + (int) (this.tradeID ^ (this.tradeID >>> 32));
    result = prime * result + ((this.makerOrderID== null) ? 0 : this.makerOrderID.hashCode());
    result = prime * result + ((this.takerOrderID== null) ? 0 : this.takerOrderID.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.size) ^ (Double.doubleToLongBits(this.size) >>> 32));
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
    UpdateMatch other = (UpdateMatch) obj;
    if (this.type == null) {
      if (other.type != null)
        return false;
    } else if (!this.type.equals(other.type))
      return false;
    if (other.tradeID != this.tradeID)
      return false;
    if (this.makerOrderID == null) {
      if (other.makerOrderID != null)
        return false;
    } else if (!this.makerOrderID.equals(other.makerOrderID))
      return false;
    if (this.takerOrderID == null) {
      if (other.takerOrderID != null)
        return false;
    } else if (!this.takerOrderID.equals(other.takerOrderID))
      return false;
    if (Double.doubleToLongBits(other.size) != Double.doubleToLongBits(this.size))
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
  public long getTradeID() {
    return this.tradeID;
  }
  
  @Pure
  public UUID getMakerOrderID() {
    return this.makerOrderID;
  }
  
  @Pure
  public UUID getTakerOrderID() {
    return this.takerOrderID;
  }
  
  @Pure
  public double getSize() {
    return this.size;
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
