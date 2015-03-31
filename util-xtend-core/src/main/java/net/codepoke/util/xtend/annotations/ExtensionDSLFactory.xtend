package net.codepoke.util.xtend.annotations

import net.codepoke.util.xtend.annotations.processors.ExtensionDSLProcessor
import org.eclipse.xtend.lib.macro.Active

@Active(ExtensionDSLProcessor)
annotation ExtensionDSLFactory {

	/**
	 * The classes we should target for extension method writing
	 */
	Class[] value;

	/**
	 * The classes we should create unwrapped constructor calls for
	 */
	Class[] unwrapped = #[];

	/**
	 * The different names which be removed from the name 
	 */
	String[] excludeList = #[];

	/**
	 * The extension target we want to create methods for.
	 */
	Class[] extensionTargets;

	/**
	 * <p>The code that needs to be executed for the created instance.</p>
	 * ExtensionType resides under <i>EntityFactoryProcessor.EXTENSION_TARGET</i>, created instance under <i>EntityFactoryProcessor.DELEGATION_INSTANCE</i>
	 * 
	 * @see {@link EntityFactoryProcessor#createConstructorDelegate}
	 */
	String extensionCode = "";

}