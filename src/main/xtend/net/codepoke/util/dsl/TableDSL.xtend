package net.codepoke.util.dsl

import com.badlogic.gdx.scenes.scene2d.ui.Cell
import com.badlogic.gdx.scenes.scene2d.ui.Stack
import com.badlogic.gdx.scenes.scene2d.ui.Table

class TableDSL {

	def static Cell<Table> table(Table root, (Table)=>void init) {
		val child = new Table()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

	def static table(Cell<? extends Table> cell, (Table)=>void init) {
		table(cell.actor, init)
	}

	def static rootTable((Table)=>void init) {
		table(null as Table, init)
	}

	def static Cell<Stack> stack(Table root, (Stack)=>void init) {
		val child = new Stack()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

	def static Cell<Stack> stack(Cell<? extends Table> cell, (Stack)=>void init) {
		stack(cell.actor, init);
	}

	def static rootStack((Stack)=>void init) {
		stack(null as Table, init)
	}

}
