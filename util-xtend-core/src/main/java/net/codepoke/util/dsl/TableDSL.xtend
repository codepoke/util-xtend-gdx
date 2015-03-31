package net.codepoke.util.dsl

import com.badlogic.gdx.scenes.scene2d.ui.Stack
import com.badlogic.gdx.scenes.scene2d.ui.Table

class TableDSL {

	def static table(Table root, (Table)=>void init) {
		val child = new Table()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

	def static table(Stack root, (Table)=>void init) {
		val child = new Table()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

	def static stack(Table root, (Stack)=>void init) {
		val child = new Stack()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

	def static stack(Stack root, (Stack)=>void init) {
		val child = new Stack()
		init.apply(child)
		if (root != null)
			root.add(child)
	}

}