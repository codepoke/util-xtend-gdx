package net.codepoke.util.xtend.annotations

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Active(AttributeComponentProcessor)
annotation AttributeComponent {
}

class AttributeComponentProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration targetClzz, extension TransformationContext context) {

		targetClzz.addAnnotation(newAnnotationReference("lombok.NoArgsConstructor"));
		targetClzz.addAnnotation(
			newAnnotationReference("lombok.ToString") [
				setBooleanValue("callSuper", true)
			]);
		targetClzz.addAnnotation(
			newAnnotationReference("lombok.EqualsAndHashCode") [
				setBooleanValue("callSuper", true)
			]);

		targetClzz.extendedClass = newTypeReference("net.codepoke.lib.util.artemis.components.AttributeComponent")

		val assetField = targetClzz.simpleName.replace("AttributeComponent", "").toUpperCase + "_META"

		targetClzz.addField(assetField) [
			static = true;
			type = newTypeReference("net.codepoke.lib.util.libgdx.AssetReference",
				newTypeReference("net.codepoke.lib.util.artemis.systems.rpg.data.Attribute"))
				
			addAnnotation(newAnnotationReference("net.codepoke.lib.util.libgdx.assets.annotations.LoadAsset")[
				setStringValue("value", targetClzz.simpleName.toLowerCase + ".json")
			])
		]

		targetClzz.addConstructor [
			addParameter("other", targetClzz.newSelfTypeReference)
			body = ['''super(other);''']
		]

		targetClzz.addConstructor [
			addParameter("initialValue", newTypeReference("net.codepoke.lib.util.artemis.systems.rpg.Value"))
			body = ['''super(initialValue, «assetField»);''']
		]

		targetClzz.addMethod("clone") [
			returnType = targetClzz.newSelfTypeReference
			body = ['''return new «targetClzz.simpleName»(this);''']
		]

	}

}
