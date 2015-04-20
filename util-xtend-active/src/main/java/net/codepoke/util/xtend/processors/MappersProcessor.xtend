package net.codepoke.util.xtend.processors

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.Active
import com.artemis.Component
import net.codepoke.util.xtend.annotations.Mappers
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import com.artemis.ComponentMapper
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import com.artemis.Entity
import com.artemis.EntityReference
import com.artemis.annotations.Wire
import com.artemis.EntitySystem
import net.codepoke.lib.util.libgdx.rendering.Layer
import net.codepoke.lib.util.artemis.widget.EntityWidget
import java.beans.Introspector

class MappersProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {

		val mapper = factory.findAnnotation(Mappers.findTypeGlobally)

		// Add the @Wire annotation, and possible warnings on usage
		factory.addAnnotation(Wire.newAnnotationReference [
			setBooleanValue("injectInherited", true)
		])

		var autoInjected = #[EntitySystem, Layer, EntityWidget]
		
		if (!autoInjected.exists[findTypeGlobally.isAssignableFrom(factory)])
			factory.
				addWarning(
					"This class requires injection by World.inject() as it does not inherit from EntitySystem, Layer or EntityWidget: "
				)

		for (component : Mappers.value(mapper)) {
			addMapper(factory, context, mapper, component)
		}

	}

	def addMapper(MutableClassDeclaration factory, extension TransformationContext context, AnnotationReference mappers,
		TypeReference target) {

		// Add the actual fields
		var name = Introspector.decapitalize(target.simpleName)

		for (replace : Mappers.excludeList(mappers))
			name = name.replaceAll(replace, "")

		val fieldName = name

		factory.addField("$" + name) [
			visibility = Visibility.PROTECTED
			type = ComponentMapper.newTypeReference(target)
		]

		val mapperVisibility = Mappers.visibility(mappers)
		
		for (parameter : #[Entity, EntityReference]) {

			factory.addMethod(name) [

				visibility = mapperVisibility
				final = true

				addParameter("e", parameter.newTypeReference)
				returnType = target

				body = [
					'''return $«fieldName».get(e);'''
				]
			]

		}

	}

	def static excludeList(Class<Mappers> clzz, AnnotationReference ref) {
		ref.getStringArrayValue("excludeList")
	}

	def static value(Class<Mappers> clzz, AnnotationReference ref) {
		ref.getClassArrayValue("value")
	}

	def static visibility(Class<Mappers> clzz, AnnotationReference ref) {
		Visibility.valueOf(ref.getEnumValue("visibility").simpleName)
	}

}