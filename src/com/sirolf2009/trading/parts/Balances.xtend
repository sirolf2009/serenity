package com.sirolf2009.trading.parts

import com.sirolf2009.trading.IExchangePart
import java.util.ArrayList
import java.util.List
import javax.annotation.PostConstruct
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Table
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.swt.widgets.TableItem
import org.eclipse.xtend.lib.annotations.Data

class Balances implements IExchangePart {

	val List<Balance> balances = new ArrayList()
	var Table table
	var TableColumn currency
	var TableColumn total
	var TableColumn available
	var TableColumn frozen

	@PostConstruct
	def void createPartControl(Composite parent) {
		table = new Table(parent, SWT.VIRTUAL) => [
			headerVisible = true
			linesVisible = true
			currency = new TableColumn(it, SWT.NONE)
			currency.text = "Currency"
			total = new TableColumn(it, SWT.NONE)
			total.text = "Total"
			available = new TableColumn(it, SWT.NONE)
			available.text = "Available"
			frozen = new TableColumn(it, SWT.NONE)
			frozen.text = "Frozen"
			addListener(SWT.SetData) [
				val item = item as TableItem
				val index = table.indexOf(item)
				val balance = balances.get(index)
				item.text = #[balance.getCurrency, balance.getTotal, balance.getAvailable, balance.getFrozen]
			]
			currency.pack()
			total.pack()
			available.pack()
			frozen.pack()
		]
		new Thread [
			while(true) {
				try {
					if(table.disposed) {
						return
					}
					val wallets = accountService.accountInfo.wallets
					balances.clear()
					wallets.entrySet.forEach [
						value.balances.entrySet.forEach [
							balances.add(new Balance(key.displayName, value.total.toString(), value.available.toString(), value.frozen.toString()))
						]
					]
					parent.display.syncExec [
						if(table.disposed) {
							return
						}
						table.clearAll()
						table.itemCount = balances.size()
					]
					Thread.sleep(5000)
				} catch(Exception e) {
					e.printStackTrace()
				}
			}
		].start()
	}

	@Data
	static class Balance {
		val String currency
		val String total
		val String available
		val String frozen
	}
}
