package com.sirolf2009.serenity.dto;

import com.sirolf2009.serenity.dto.UpdateType;
import java.util.Date;

@SuppressWarnings("all")
public interface IUpdate {
  public abstract UpdateType getType();
  
  public abstract Date getTime();
  
  public abstract String getProductID();
  
  public abstract long getSequence();
}
