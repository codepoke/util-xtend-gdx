package net.codepoke.util.xtend.annotations

import com.artemis.Component
import net.codepoke.util.xtend.processors.MappersProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Creates ComponentMapper fields and adds extension methods for the given Components.
 * This allows components to be accessed as if they were fields on Entity and EntityReference classes.
 *  
 */
@Active(MappersProcessor)
annotation Mappers {
	
	/**
	 * The components for which we need to generate ComponentMappers & extension access methods
	 */
	Class<? extends Component>[] value 

	/**
	 * The parts of the class name that will be stripped
	 */
	String[] excludeList = #["AttributeComponent", "Component"];
	
	/**
	 * The visibility of the extension accessor methods.
	 * The only usage to make this Public is to create a class which can be used as an extension target.
	 */
	Visibility visibility = Visibility.PRIVATE
	
}