package com.sirolf2009.serenity;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sirolf2009.serenity.UpdateParser;
import com.sirolf2009.serenity.dto.IUpdate;
import com.sirolf2009.serenity.dto.UpdateChange;
import com.sirolf2009.serenity.dto.UpdateDone;
import com.sirolf2009.serenity.dto.UpdateMatch;
import com.sirolf2009.serenity.dto.UpdateOpen;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.function.Consumer;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.junit.Assert;
import org.junit.Test;

@SuppressWarnings("all")
public class TestUpdateParser {
  @Test
  public void testExampleUpdates() {
    try {
      final Gson gson = new Gson();
      final UpdateParser parser = new UpdateParser();
      final Consumer<String> _function = new Consumer<String>() {
        @Override
        public void accept(final String it) {
          InputOutput.<Optional<IUpdate>>println(parser.apply(gson.<JsonObject>fromJson(it, JsonObject.class)));
        }
      };
      Files.readAllLines(Paths.get("src/test/resources/example_response")).forEach(_function);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Test
  public void testUpdateOpen() {
    final Gson gson = new Gson();
    final UpdateParser parser = new UpdateParser();
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"type\":\"open\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"side\":\"buy\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"price\":\"7156.85000000\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"order_id\":\"b8e8ebdd-9480-4c48-a69e-40871c3ef8b6\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"remaining_size\":\"0.66000000\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"product_id\":\"BTC-EUR\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"sequence\":2934264449,");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"time\":\"2017-11-22T08:45:10.919000Z\"");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("}");
    final IUpdate parsed = parser.apply(gson.<JsonObject>fromJson(_builder.toString(), JsonObject.class)).get();
    Assert.assertTrue((parsed instanceof UpdateOpen));
    Assert.assertEquals(7156.85, ((UpdateOpen) parsed).getPrice(), 0.0001d);
  }
  
  @Test
  public void testUpdateDone() {
    final Gson gson = new Gson();
    final UpdateParser parser = new UpdateParser();
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"type\":\"done\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"side\":\"buy\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"order_id\":\"15d15d4c-1822-44d6-9d38-dac351379781\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"reason\":\"canceled\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"product_id\":\"BTC-EUR\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"price\":\"7155.02000000\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"remaining_size\":\"0.08892208\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"sequence\":2934264446,");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"time\":\"2017-11-22T08:45:10.903000Z\"");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("}");
    final IUpdate parsed = parser.apply(gson.<JsonObject>fromJson(_builder.toString(), JsonObject.class)).get();
    Assert.assertTrue((parsed instanceof UpdateDone));
    Assert.assertEquals(7155.02, ((UpdateDone) parsed).getPrice(), 0.0001d);
  }
  
  @Test
  public void testUpdateMatch() {
    final Gson gson = new Gson();
    final UpdateParser parser = new UpdateParser();
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"type\":\"match\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"trade_id\":5570161,");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"maker_order_id\":\"1c2afd6d-8bc6-4257-93b5-6b50655c7c19\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"taker_order_id\":\"5c9d7212-5d55-4761-8e31-6b3d400b98d0\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"side\":\"sell\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"size\":\"0.10000000\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"price\":\"7160.00000000\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"product_id\":\"BTC-EUR\",");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"sequence\":2934264460,");
    _builder.newLine();
    _builder.append("\t\t\t");
    _builder.append("\"time\":\"2017-11-22T08:45:11.575000Z\"");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("}");
    final IUpdate parsed = parser.apply(gson.<JsonObject>fromJson(_builder.toString(), JsonObject.class)).get();
    Assert.assertTrue((parsed instanceof UpdateMatch));
    Assert.assertEquals(7160.00, ((UpdateMatch) parsed).getPrice(), 0.0001d);
  }
  
  @Test
  public void testUpdateChange() {
    final Gson gson = new Gson();
    final UpdateParser parser = new UpdateParser();
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"type\": \"change\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"time\": \"2014-11-07T08:19:27.028459Z\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"sequence\": 80,");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"order_id\": \"ac928c66-ca53-498f-9c13-a110027a60e8\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"product_id\": \"BTC-USD\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"new_size\": \"5.23512\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"old_size\": \"12.234412\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"price\": \"400.23\",");
    _builder.newLine();
    _builder.append("\t\t    ");
    _builder.append("\"side\": \"sell\"");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("}");
    final IUpdate parsed = parser.apply(gson.<JsonObject>fromJson(_builder.toString(), JsonObject.class)).get();
    Assert.assertTrue((parsed instanceof UpdateChange));
    Assert.assertEquals(400.23, ((UpdateChange) parsed).getPrice(), 0.0001d);
  }
}
