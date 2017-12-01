package com.sirolf2009.trading

import org.eclipse.jface.preference.FieldEditorPreferencePage
import org.eclipse.ui.IWorkbenchPreferencePage
import org.eclipse.ui.IWorkbench
import org.eclipse.jface.preference.StringFieldEditor
import org.eclipse.jface.preference.BooleanFieldEditor

class SerenityPreferences extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
	
	new() {
		super(GRID)
	}
	
	override protected createFieldEditors() {
		addField(new BooleanFieldEditor("authenticate", "Authenticate", getFieldEditorParent()))
		addField(new StringFieldEditor("username", "Username:", getFieldEditorParent()))
		addField(new StringFieldEditor("apiKey", "API Key:", getFieldEditorParent()))
		addField(new StringFieldEditor("secretKey", "Secret Key:", getFieldEditorParent()))
	}
	
	override init(IWorkbench workbench) {
		preferenceStore = Activator.^default.getPreferenceStore()
	}
	
}