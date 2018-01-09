package com.sirolf2009.trading

import com.sirolf2009.bitfinex.wss.model.SubscribeOrderbook
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.jface.preference.ComboFieldEditor
import org.eclipse.jface.preference.FieldEditorPreferencePage
import org.eclipse.jface.preference.StringFieldEditor
import org.eclipse.ui.IWorkbench
import org.eclipse.ui.IWorkbenchPreferencePage
import org.eclipse.jface.preference.IntegerFieldEditor
import org.eclipse.jface.preference.IPreferenceStore

class SerenityPreferences extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
	
	new() {
		super(GRID)
	}
	
	override protected createFieldEditors() {
		addField(new StringFieldEditor("symbol", "Symbol", getFieldEditorParent()))
		addField(new ComboFieldEditor("frequency", "Frequency", #[#["Realtime", SubscribeOrderbook.FREQ_REALTIME], #["2 seconds", SubscribeOrderbook.FREQ_2SECONDS]], fieldEditorParent))
		addField(new ComboFieldEditor("precision", "Precision", #[#["Most Precise", SubscribeOrderbook.PREC_MOST_PRECISE], #["Precise", SubscribeOrderbook.PREC_PRECISE], #["Imprecise", SubscribeOrderbook.PREC_IMPRECISE], #["Most Imprecise", SubscribeOrderbook.PREC_MOST_IMPRECISE]], fieldEditorParent))
		addField(new IntegerFieldEditor("largeVolume", "Large Volume:", getFieldEditorParent()))
		addField(new BooleanFieldEditor("trends", "Draw Trends", getFieldEditorParent()))
		addField(new BooleanFieldEditor("authenticate", "Authenticate", getFieldEditorParent()))
		addField(new StringFieldEditor("username", "Username:", getFieldEditorParent()))
		addField(new StringFieldEditor("apiKey", "API Key:", getFieldEditorParent()))
		addField(new StringFieldEditor("secretKey", "Secret Key:", getFieldEditorParent()))
	}
	
	override init(IWorkbench workbench) {
		preferenceStore = Activator.^default.getPreferenceStore()
	}
	
	def static setDefaults(IPreferenceStore it) {
		setDefault("symbol", "BTCUSD")
		setDefault("largeVolume", 50)
		setDefault("authenticate", false)
		setDefault("trends", false)
	}
	
}