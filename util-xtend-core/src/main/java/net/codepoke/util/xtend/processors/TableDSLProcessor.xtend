package net.codepoke.util.xtend.processors

import net.codepoke.util.xtend.processors.ExtensionDSLProcessor
import net.codepoke.util.xtend.util.FactoryUtils
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedConstructor
import org.eclipse.xtend.lib.macro.declaration.ResolvedParameter
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static net.codepoke.util.xtend.processors.ExtensionDSLProcessor.*
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.Cell

class TableDSLProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val activeAnnotation = Active.findTypeGlobally
		val factoryType = newTypeReference(TableDSLProcessor)

		// Find the annotation which has the the EntityFactoryProcessor as its value
		val facAnn = factory.annotations.filter [ annotation |
			val active = annotation.annotationTypeDeclaration.annotations.filter [
				annotationTypeDeclaration == activeAnnotation
			].head
			active?.getClassValue("value").equals(factoryType)
		].head

		if (facAnn == null)
			throw new RuntimeException("Couldn't find an Active Annotation which uses TableDSLProcessor")

		val extensionTargets = #[Table.newTypeReference]
		val unwrappedTypes = #[]
		val exclusionList = facAnn.getStringArrayValue("excludeList")
		val extensionTargetCode = facAnn.getStringValue("extensionCode")

		if (extensionTargets.isEmpty) {
			throw new RuntimeException(
				"The annotation should have a field \"extensionTarget\" which shouldn't be null.");
		}

		for (extensionTarget : extensionTargets) {
			for (componentType : facAnn.getClassArrayValue("value")) {

				// Sanitize and create the name for the static extension method 
				var temporaryName = componentType.simpleName;

				for (exclude : exclusionList)
					temporaryName = temporaryName.replace(exclude, "");

				temporaryName = Character.toLowerCase(temporaryName.charAt(0)) + temporaryName.substring(1);
				val finalName = temporaryName

				// Create the extension methods for all public accessible constructors
				componentType.declaredResolvedConstructors.filter[declaration.visibility == Visibility.PUBLIC].forEach [ constructor |

					val params = constructor.resolvedParameters

					// Create delegate constructor extension-methods for all public constructors with a single argument of a Type in unwrappedTypes
					if (params.size == 1) {
						val targetType = params.head.resolvedType

						// For each matching unwrapped type, create a delegation call to its constructor (if it isn't a copy constructor, nor empty)
						// Either we are a perfect match, or we are a generics discarded match
						unwrappedTypes.filter [
							it == targetType || targetType?.type?.newTypeReference?.equals(it)
						].forEach [
							targetType.declaredResolvedConstructors.filter [
								declaration.visibility == Visibility.PUBLIC &&
									resolvedParameters.head?.resolvedType != targetType && resolvedParameters.size > 0
							].forEach [
								createConstructorDelegate(context, factory, finalName, extensionTargetCode,
									componentType, extensionTarget, resolvedParameters, it)
							]
						]
					}

					// Create the delegate constructor-methods 
					createConstructorDelegate(context, factory, finalName, extensionTargetCode, componentType,
						extensionTarget, params, null)
				]

			}
		}

	}


	/**
	 * <p>
	 * Creates a static method for the creation, and immediate adding of a Component to an Entity.
	 * The method has the <b>entityType</b> as its first argument, followed by the parameters resolved in params.
	 * </p>
	 * 
	 * <p>
	 * The extension method created constructs the <b>targetType</b>, then executes the <b>extensionTargetCode</b>, finally returning the constructed <b>targetType</b>.
	 * The constructed targetType resides under <i>param</i>, the extensionTarget under <i>target</i>.
	 * </p>
	 * 
	 * E.g.: targetType == Label, no-args, extensionTarget == Table, extensionTargetCode: "target.add(param);"<pre>
	 * Label param = new Label();
	 * target.add(param);
	 * return param;
	 * </pre>
	 * 
	 * @param extensionTarget The type which will be the first argument of the extension method
	 * @param wrappedConstructor If set, all arguments are fed into this constructor; the result of which is fed to the constructor of the componentType
	 */
	def createConstructorDelegate(extension TransformationContext context, MutableClassDeclaration factory,
		String methodName, String extensionTargetCode, TypeReference componentType, TypeReference extensionTarget,
		Iterable<? extends ResolvedParameter> params, ResolvedConstructor wrappedConstructor) {

		factory.addMethod(methodName) [
			returnType = Cell.newTypeReference(componentType)
			visibility = Visibility.PUBLIC
			static = true;

			// Sanitize and add all the parameters needed
			var idx = 1;
			addParameter(EXTENSION_TARGET, extensionTarget)
			for (param : params) {

				val paramString = "$" + idx

				// TODO: Support typed classes
				// This fixes X<Enum<Y>> cases, TODO: Properly handle X<Enum<T>>
				if (param.resolvedType.type?.newTypeReference()?.equals(componentType)) {
					addParameter(paramString, componentType)
				} else if (!param.resolvedType.actualTypeArguments.empty || param.resolvedType.array) {
					val paramType = FactoryUtils.cleanType(context, it, factory, param.resolvedType)
					addParameter(paramString, paramType)
				} else
					addParameter(paramString, param.resolvedType)

				idx++
			}

			val numParams = idx - 1;
			body = [

				var parameters = ""

				// Create the direct call, or the wrapped call list of arguments
				if (numParams > 0) {
					if (wrappedConstructor == null) {
						parameters = '''«FOR x : 1 .. numParams SEPARATOR ','»«"$" + x»«ENDFOR»'''
					} else {
						parameters = '''new «wrappedConstructor.declaration.declaringType.simpleName»( «FOR x : 1 .. numParams SEPARATOR ','»«"$" + x»«ENDFOR»)'''
					}
				}

				'''	
					«componentType» «DELEGATION_INSTANCE» = new «componentType»(«parameters»);
					«extensionTargetCode»
					return «EXTENSION_TARGET».add(«DELEGATION_INSTANCE»);
				'''
			]
		]
	}

}