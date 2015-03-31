package net.codepoke.util.xtend.annotations

import com.artemis.Entity
import net.codepoke.lib.util.artemis.systems.rpg.Value
import net.codepoke.lib.util.libgdx.AssetReference
import net.codepoke.util.xtend.processors.ExtensionDSLProcessor
import org.eclipse.xtend.lib.macro.Active

@Active(ExtensionDSLProcessor)
annotation EntityDSLFactory {

	/**
	 * The classes we should target for extension method writing
	 */
	Class[] value;

	/**
	 * The classes we should create unwrapped constructor calls for
	 */
	Class[] unwrapped = #[Value, AssetReference];

	/**
	 * The different names which be removed from the name 
	 */
	String[] excludeList = #["AttributeComponent", "Component"];

	/**
	 * The extension target we want to create methods for.
	 */
	Class[] extensionTargets = #[Entity];

	/**
	 * <p>The code that needs to be executed for the created instance.</p>
	 * ExtensionType resides under <i>EntityFactoryProcessor.EXTENSION_TARGET</i>, created instance under <i>EntityFactoryProcessor.DELEGATION_INSTANCE</i>
	 * 
	 * @see {@link EntityFactoryProcessor#createConstructorDelegate}
	 */
	String extensionCode = ExtensionDSLProcessor.EXTENSION_TARGET + ".addComponent(" + ExtensionDSLProcessor.DELEGATION_INSTANCE + ");";

}