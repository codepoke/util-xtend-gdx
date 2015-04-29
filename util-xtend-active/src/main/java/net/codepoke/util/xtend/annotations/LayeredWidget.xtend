package net.codepoke.util.xtend.annotations

import com.badlogic.gdx.scenes.scene2d.Group
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.google.common.base.CaseFormat
import java.util.ArrayList
import java.util.HashMap
import net.codepoke.lib.util.io.JsonSerializer
import net.codepoke.lib.util.libgdx.AssetReference
import net.codepoke.lib.util.libgdx.assets.annotations.LoadAsset
import net.codepoke.lib.util.libgdx.scene2d.ActorWidgetLayer
import net.codepoke.lib.util.libgdx.scene2d.GroupWidgetLayer
import net.codepoke.lib.util.libgdx.scene2d.WidgetLayer
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.AccessorsProcessor
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.Path

import static extension net.codepoke.util.xtend.util.FactoryUtils.sanitizeVariable
import static extension org.apache.commons.lang3.StringUtils.*

/**
 * Generates a Widget based on the given JSON encoded Layered Image.
 * Generates specific classes for all GroupWidgetLayers and sets up the root class with the required AssetReference.
 */
@Active(LayeredWidgetProcessor)
annotation LayeredWidget {

	/** The location of the JSON encoded Layered Image (E.g.: PSD) file that we want to transform. */
	String value
	
	/** The raw text of the JSON we want to transform. */
	String rawText = ""
	
	/**
	 * The package prefix to use for the generated classes
	 */
	String pckage = "net.codepoke.generated.ui.widget"
	
}

/**
 * Whether this class was a generated widget class
 */
annotation GeneratedWidget {
	
}

class LayeredWidgetProcessor extends AbstractClassProcessor {
	
	/**
	 * Holds a mapping to the loaded files, so we don't load from disk twice
	 */
	val fileWidget = new HashMap<String, GroupWidgetLayer>();
	
	override doRegisterGlobals(ClassDeclaration factory, extension RegisterGlobalsContext context) {
		
	    val layeredWidget = factory.findAnnotation(LayeredWidget.findUpstreamType)
		val file = layeredWidget.getStringValue("value")
		
		val targetWidget = new Path("/poke-story-base/content/psd/"+file);
		
		if(!exists(targetWidget)){
			return
		}
		
		// Load the file
		val json = new JsonSerializer();
		val widget = json.fromJson(GroupWidgetLayer, targetWidget.contentsAsStream)
		
		fileWidget.put(file, widget);
		
		// Create the types for the class
		val package = layeredWidget.getStringValue("pckage") + "." + widget.name
		
		walkLayers(widget)[
			// Skip the root and any actor children.
			if (!(it instanceof GroupWidgetLayer))
				return;
				
			if(it.parent != null)
				defineGroupClassName([findUpstreamType != null], package, it as GroupWidgetLayer).registerClass
			
			
		]
	}
	
	def void walkLayers(WidgetLayer root, (WidgetLayer)=>void lambda){
		
		lambda.apply(root)
		
		if(root instanceof GroupWidgetLayer)
			for(child : root.children.values){
				walkLayers(child, lambda)		
			}
		
	}
	
	override doTransform(MutableClassDeclaration factory, extension TransformationContext context) {
    
		val layeredWidget = factory.findAnnotation(LayeredWidget.findTypeGlobally)
		val file = layeredWidget.getStringValue("value")
		
		val widget = fileWidget.get(file)
		
		if(widget == null){
			factory.addError("Cannot find the file:"+file)
			return
		}			
		
		val package = layeredWidget.getStringValue("pckage") + "." + widget.name
		
		// Create a static field which will hold the AssetReference, and create a Constructor which delegates to this.
		val staticName = CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_UNDERSCORE, widget.name.sanitizeVariable)
		factory.addField(staticName)[
			static = true
			visibility = Visibility.PUBLIC
			type = AssetReference.newTypeReference(GroupWidgetLayer.newTypeReference)
			addAnnotation(LoadAsset.newAnnotationReference[	setStringValue("value", file) ])			
			initializer = '''new AssetReference<«GroupWidgetLayer.simpleName»>(«GroupWidgetLayer».class, "«file»")'''
		]
		
		factory.addConstructor[
			docComment = '''
				Constructs the «factory.simpleName» with the AssetReference stored within. («file»).
				This requires that the assetreference was injected through the load process. (I.e.: add this class to the Class Dependents of the ManagedScreen)
			'''
			addParameter("skin", Skin.newTypeReference)
			
			body = [
				'''this(skin, «staticName».get());'''
			]
		]
		
		factory.addConstructor[
			docComment = '''
				Constructs the «factory.simpleName» with the given AssetReference. This LayeredWidget was setup using: («file»).
			'''
			
			addParameter("skin", Skin.newTypeReference)
			addParameter("reference", AssetReference.newTypeReference(GroupWidgetLayer.newTypeReference))
			
			body = [
				'''this(skin, reference.get());'''
			]
		]
		
		defineWidget(factory, context, widget, package)
		
		// Release the resources
		fileWidget.remove(file)

	}
	
	def void defineWidget(MutableClassDeclaration factory, extension TransformationContext context, GroupWidgetLayer layer, String widgetPackage){
		
		if(factory.findAnnotation(GeneratedWidget.findTypeGlobally) != null){
			return
		}
		
		val groupName = [ GroupWidgetLayer child | defineGroupClassName([findClass != null], widgetPackage, child)]
		
		// Mark the class as handled
		factory.extendedClass = Group.newTypeReference
		factory.addAnnotation(GeneratedWidget.newAnnotationReference)
		factory.addAnnotation(Accessors.newAnnotationReference)
		
		var newFields = new ArrayList<MutableFieldDeclaration>();

		for(child : layer.children.values){
			
			if(child instanceof GroupWidgetLayer){
				val clzz = context.findClass(groupName.apply(child))
				
				newFields.add(factory.addField(child.name.sanitizeVariable)[
					visibility = Visibility.PROTECTED
					type = clzz.newSelfTypeReference
				])
				
				defineWidget(clzz, context, child, widgetPackage);
				
			} else {
				val typeRef = (child as ActorWidgetLayer).actor.findTypeGlobally.newSelfTypeReference
				
				// Create the Field, and the Getters/Setters
				newFields.add(factory.addField(child.name.sanitizeVariable)[
					visibility = Visibility.PROTECTED
					type = typeRef
				])
			}
		}
		
		// Create the constructor that gets the asset reference and constructs everything.
		factory.addConstructor[
			addParameter("skin", Skin.newTypeReference)
			addParameter("layer", GroupWidgetLayer.newTypeReference)
			body = [
				'''
					layer.fill(this);
«««					Initialize the variables by looking them up in the Group PSD
					«FOR child : layer.children.values»
						«IF child instanceof GroupWidgetLayer»
							this.«child.name.sanitizeVariable» = new «groupName.apply(child)»(skin, (GroupWidgetLayer) layer.getChild("«child.name»"));
						«ENDIF»
						«IF child instanceof ActorWidgetLayer» 
							this.«child.name.sanitizeVariable» = («child.actor.simpleName») layer.getChild("«child.name»").create(skin);
						«ENDIF»
					«ENDFOR»
					
«««					Adding them to the Group
					«FOR child : layer.children.values»
						addActor(«child.name.sanitizeVariable»);
					«ENDFOR»
					
«««					Set them to the proper Z-Index
					«FOR child : layer.children.values»
						this.«child.name.sanitizeVariable».setZIndex(«child.ZIndex»);
					«ENDFOR»
				'''
			]
		]
		
		// Create the Getters/Setters
		// We delay this so the generated source doesn't look like a complete wreck
		val extension accessor = new AccessorsProcessor();
		newFields.forEach[transform(context)]
	}	
	
	/**
	 * Tries to create a unique name for the Widget
	 */
	def defineGroupClassName((String)=>boolean classExists, String widgetPackage, GroupWidgetLayer targetLayer){
		
		var layer = targetLayer
		var name = layer.name.capitalize + "Group"
		
		// TODO: We normally enforce layers should have a unique name
//		while(classExists.apply(widgetPackage +"." + name) && layer != null){
//			name = layer.parent.name.capitalize + name
//			layer = layer.parent as GroupWidgetLayer
//		}
		
		return widgetPackage + "." + name;		
	}

}