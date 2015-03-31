package net.codepoke.util.xtend.util

import com.badlogic.gdx.utils.Array
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

/**
 * This class contains utility code used in factory processing of Active Annotations
 */
class FactoryUtils {

	/** Removes any generic type arguments that are not resolved from the type reference. TODO: Build in support for generic types */
	def static TypeReference cleanType(extension TransformationContext context, MutableMethodDeclaration method, MutableClassDeclaration factory, TypeReference org) {
		
		if(org.array){
			
			var arrayType = org.arrayComponentType
			
			var outList = new Array(TypeReference)
			for (type : arrayType.actualTypeArguments) {
				if (type.simpleName.equals("Object") || arrayType.type == null) {
				} else {
					outList.add(cleanType(context, method, factory, type))
				}
			}
			
			newArrayTypeReference(newTypeReference(arrayType.type))

		} else {

			var outList = new Array(TypeReference)
			for (type : org.actualTypeArguments) {
				if (type.simpleName.equals("Object") || org.type == null) {
				} else {
					outList.add(cleanType(context, method, factory, type))
				}
			}

			if (outList.size > 0)
				newTypeReference(org.type, outList.toArray())
			else
				newTypeReference(org.type)
			
		}
	}
	
}