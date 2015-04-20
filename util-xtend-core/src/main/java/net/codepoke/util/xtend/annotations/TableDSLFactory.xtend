package net.codepoke.util.xtend.annotations

import com.badlogic.gdx.scenes.scene2d.ui.Table
import org.eclipse.xtend.lib.macro.Active
import net.codepoke.util.xtend.processors.TableDSLProcessor

@Active(TableDSLProcessor)
annotation TableDSLFactory {

	/**
	 * The classes we should target for extension method writing
	 */
	Class[] value;

	/**
	 * The different names which be removed from the name 
	 */
	String[] excludeList = #[];

	/**
	 * <p>The code that needs to be executed for the created instance.</p>
	 * ExtensionType resides under <i>EntityFactoryProcessor.EXTENSION_TARGET</i>, created instance under <i>EntityFactoryProcessor.DELEGATION_INSTANCE</i>
	 * 
	 * @see {@link EntityFactoryProcessor#createConstructorDelegate}
	 */
	String extensionCode = "";
	
}