package net.codepoke.util.xtend.annotations

import com.badlogic.gdx.utils.Array
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedConstructor
import org.eclipse.xtend.lib.macro.declaration.ResolvedParameter
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(EntityFactoryProcessor)
annotation EntityDSLFactory {

	Class[] value;

}

class EntityFactoryProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val facAnn = factory.findAnnotation(newTypeReference(EntityDSLFactory).type)
		val valueType = newTypeReference("net.codepoke.lib.util.artemis.systems.rpg.Value")
		val entityType = newTypeReference("com.artemis.Entity")
		
		val targets = facAnn.getClassArrayValue("value");

		for (orgCompType : targets) {

			var compType = orgCompType

			var name = compType.simpleName;
			name = name.replace("AttributeComponent", "");
			name = name.replace("Component", "");
			name = Character.toLowerCase(name.charAt(0)) + name.substring(1);

			for (constructor : compType.declaredResolvedConstructors.filter[
				declaration.visibility == Visibility.PUBLIC]) {

				val params = constructor.resolvedParameters

				// Create delegate constructor-methods for all public constructors with a single argument of Type Value or AssetReference
				if (params.size == 1) {
					val firstParam = params.head.resolvedType

					switch firstParam {
						case valueType: {

							// Create the Value inlined methods
							// Ignoring the copy constructor in Value & the no-args constructor
							for (valConstr : valueType.declaredResolvedConstructors.filter [
								val head = resolvedParameters.head
								head?.resolvedType != valueType && resolvedParameters.size > 0
							]) {
								createConstructorDelegate(context, factory, name, compType, entityType,
									valConstr.resolvedParameters, valConstr)
							}
						}
						case firstParam.name.contains("AssetReference"): {

							// Create the Reference inlined methods
							// Ignoring the copy constructor in AssetReference
							for (refConstr : firstParam.declaredResolvedConstructors.filter [
								val head = resolvedParameters.head
								declaration.visibility == Visibility.PUBLIC && resolvedParameters.size > 0 &&
									!head?.resolvedType.name.contains("AssetReference")
							]) {
								createConstructorDelegate(context, factory, name, compType, entityType,
									refConstr.resolvedParameters, refConstr)
							}
						}
					}
				}

				// Create the delegate constructor-methods 
				createConstructorDelegate(context, factory, name, compType, entityType, params, null)

			}

		}

	}

	def createConstructorDelegate(extension TransformationContext context, MutableClassDeclaration factory, String name,
		TypeReference compType, TypeReference entityType, Iterable<? extends ResolvedParameter> params,
		ResolvedConstructor wrapConstr) {

		factory.addMethod(name) [
			returnType = compType
			visibility = Visibility.PUBLIC
			static = true;
			addParameter("$0", entityType)
			var idx = 1;
			
			var types = "";
			
			for( type : compType.actualTypeArguments){
				types += ", "+type
			}
		
			
			for (param : params) {
				
				// TODO: Handle <Enum<E>>
				if(param.resolvedType.simpleName.contains(compType.simpleName)){
					addParameter("$" + idx++, compType)
				} else if (!param.resolvedType.actualTypeArguments.empty || param.resolvedType.array) {
					val paramType = cleanType(context, it, factory, param.resolvedType)
					addParameter("$" + idx++, paramType)
				} else
					addParameter("$" + idx++, param.resolvedType)
			}
			val numParams = idx - 1;
			if (wrapConstr == null) {
				body = [
					'''	«compType» comp = new «compType»(«IF numParams > 0»«FOR x : 1 .. numParams SEPARATOR ','»«"$" +
						x»«ENDFOR»«ENDIF»);
		$0.addComponent(comp);
		return comp;
	'''
				]
			} else {
				body = [
					'''	«compType» comp = new «compType»(new «wrapConstr.declaration.declaringType.simpleName»( «IF numParams >
						0»«FOR x : 1 .. numParams SEPARATOR ','»«"$" + x»«ENDFOR»«ENDIF»));
		$0.addComponent(comp);
		return comp;
	'''
				]

			}
		]
	}

/** Removes any typed arguments that are not resolved. TODO: Build in support for generic types */
	def TypeReference cleanType(extension TransformationContext context, MutableMethodDeclaration method, MutableClassDeclaration factory, TypeReference org) {
	
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
