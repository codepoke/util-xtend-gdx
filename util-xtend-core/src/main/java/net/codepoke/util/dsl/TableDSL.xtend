package net.codepoke.util.dsl

import com.badlogic.gdx.scenes.scene2d.ui.Cell
import com.badlogic.gdx.scenes.scene2d.ui.Stack
import com.badlogic.gdx.scenes.scene2d.ui.Table
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

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

//	def static table(Cell<? extends Table> cell, (Table)=>void init) {
//		table(cell.actor, init)
//	}

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

//	def static stack(Cell<? extends Table> cell, (Stack)=>void init) {
//		stack(cell.actor, init);
//	}

}

@Active(CellInlinerProcessor)
annotation CellInliner {

	Class[] value;

}

class CellInlinerProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val cellAnn = factory.findAnnotation(newTypeReference(CellInliner).type)

		for (type : cellAnn.getClassArrayValue("value")) {

			for (sub : cellAnn.getClassArrayValue("value")) { 

				val addMethod = sub.declaredResolvedMethods.findFirst[it.declaration.simpleName == "add"]
				val returnsCell = addMethod.resolvedReturnType.name != "void";
				
				factory.addMethod(type.simpleName.toLowerCase) [

					if (returnsCell)
						returnType = newTypeReference(Cell, type)

					visibility = Visibility.PUBLIC
					static = true;
					addParameter("root", sub)
					addParameter("init", newTypeReference(Procedure1, type))

					body = [
						'''
						«type» child = new «type.simpleName»();
						init.apply(child);
						«IF returnsCell»
							return root.add(child);
						«ELSE»
							root.add(child);
						«ENDIF»'''
					]

				]
			}
		}


	}

}