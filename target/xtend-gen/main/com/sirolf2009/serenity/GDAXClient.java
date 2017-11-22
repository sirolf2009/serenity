package com.sirolf2009.serenity;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sirolf2009.serenity.UpdateParser;
import com.sirolf2009.serenity.dto.IUpdate;
import java.net.URI;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.function.Consumer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

@SuppressWarnings("all")
public class GDAXClient extends WebSocketClient {
  private final static Logger log = LogManager.getLogger();
  
  private final static Gson gson = new Gson();
  
  private final static UpdateParser parser = new UpdateParser();
  
  private final static ExecutorService executor = Executors.newCachedThreadPool();
  
  private final Consumer<IUpdate> onUpdate;
  
  public GDAXClient(final Consumer<IUpdate> onUpdate) {
    super(GDAXClient.uri());
    try {
      this.onUpdate = onUpdate;
      this.connectBlocking();
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{");
      _builder.newLine();
      _builder.append("\t\t    ");
      _builder.append("\"type\": \"subscribe\",");
      _builder.newLine();
      _builder.append("\t\t    ");
      _builder.append("\"product_ids\": [");
      _builder.newLine();
      _builder.append("\t\t        ");
      _builder.append("\"BTC-EUR\"");
      _builder.newLine();
      _builder.append("\t\t    ");
      _builder.append("],");
      _builder.newLine();
      _builder.append("\t\t    ");
      _builder.append("\"channels\": [");
      _builder.newLine();
      _builder.append("\t\t        ");
      _builder.append("\"full\"");
      _builder.newLine();
      _builder.append("\t\t    ");
      _builder.append("]");
      _builder.newLine();
      _builder.append("\t\t");
      _builder.append("}");
      this.send(_builder.toString());
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Override
  public void onClose(final int code, final String reason, final boolean remote) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Closed. code=");
    _builder.append(code);
    _builder.append(" reason=");
    _builder.append(reason);
    _builder.append(" remote=");
    _builder.append(remote);
    GDAXClient.log.warn(_builder);
  }
  
  @Override
  public void onError(final Exception exception) {
    GDAXClient.log.error("GDAX sent error", exception);
  }
  
  @Override
  public void onMessage(final String message) {
    final Runnable _function = new Runnable() {
      @Override
      public void run() {
        try {
          final JsonObject object = GDAXClient.gson.<JsonObject>fromJson(message, JsonObject.class);
          boolean _has = object.has("type");
          if (_has) {
            final Consumer<IUpdate> _function = new Consumer<IUpdate>() {
              @Override
              public void accept(final IUpdate it) {
                GDAXClient.this.onUpdate.accept(it);
              }
            };
            GDAXClient.parser.apply(object).ifPresent(_function);
          } else {
            GDAXClient.log.warn(("Unknown message: " + message));
          }
        } catch (final Throwable _t) {
          if (_t instanceof Exception) {
            final Exception e = (Exception)_t;
            GDAXClient.log.error(("Failed to handle message: " + message), e);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      }
    };
    GDAXClient.executor.submit(_function);
  }
  
  @Override
  public void onOpen(final ServerHandshake handshake) {
    URI _uRI = this.getURI();
    String _plus = ("Handshaking with " + _uRI);
    GDAXClient.log.info(_plus);
  }
  
  public static URI uri() {
    try {
      return new URI("wss://ws-feed.gdax.com");
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
