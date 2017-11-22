package com.sirolf2009.serenity.dto;

import com.sirolf2009.serenity.dto.IUpdate;
import java.util.Date;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public abstract class AbstractUpdate implements IUpdate {
  private final Date time;
  
  private final String productID;
  
  private final long sequence;
  
  public AbstractUpdate(final Date time, final String productID, final long sequence) {
    super();
    this.time = time;
    this.productID = productID;
    this.sequence = sequence;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.time== null) ? 0 : this.time.hashCode());
    result = prime * result + ((this.productID== null) ? 0 : this.productID.hashCode());
    result = prime * result + (int) (this.sequence ^ (this.sequence >>> 32));
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
    AbstractUpdate other = (AbstractUpdate) obj;
    if (this.time == null) {
      if (other.time != null)
        return false;
    } else if (!this.time.equals(other.time))
      return false;
    if (this.productID == null) {
      if (other.productID != null)
        return false;
    } else if (!this.productID.equals(other.productID))
      return false;
    if (other.sequence != this.sequence)
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("time", this.time);
    b.add("productID", this.productID);
    b.add("sequence", this.sequence);
    return b.toString();
  }
  
  @Pure
  public Date getTime() {
    return this.time;
  }
  
  @Pure
  public String getProductID() {
    return this.productID;
  }
  
  @Pure
  public long getSequence() {
    return this.sequence;
  }
}
