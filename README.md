# util-xtend-gdx
General Xtend code which can be used for LibGDX &amp; Artemis, such as Active Annotations, extension methods and general utility code.

# ActiveAnnotations

## ExtensionDSLFactory

An Active Annotation which creates extension methods that unwrap and delegate the constructors of the targetted value, apply the created instance on given code, and then return it.

In summary, with a single annotation you can generate DSL instead of having to handroll your own.
This annotation generates the mundane parts of DSLs which normally need to be handwritten and are 80% of the DSL, such as [Kotlin's Anko](https://github.com/JetBrains/anko).

The ExtensionDSLFactory accepts the following values:

* Class[] value; the targets we want to create unwrapped extension methods for.
* Class[] extensionTargets; the target classes for which the extension methods should be created.
* Class[] unwrapped; the types for which single parameter constructors exist in the targets which we want to unwrap.
* String[] excludeList; the parts of the name in the type which should be removed from the method name.
* String extensionCode; the code which should be executed after the instance is created, and before the instance is returned.

### What?!

Ok, so why would we want this?

An example would be a set of extension methods created for the Scene2D elements in LibGDX, specifically for Table.

We can then use code such as:

```xtend
	table[
		label("Please select one of the following:", skin)
			
		table[
			textButton("Cancel", skin)
			textButton("OK", skin)
		]
	]
```

The call _label(...)_ takes the implied *Table it* in the context, creates a Label with the given arguments, and then adds it to the given Table.

Another example would be:

```xtend
def static character(Entity target, int health, int momentum) {
	target => [
		defence(0, 10)
		health(health)
		momentum(momentum, 40)
		spineAnimation(SkeletonData, "porcupine.json") => [
			defaultKey = "stance_idle#0"
			skin = "Brute"
			scale = 2
		]
	]
}
```

The EntityDSLFactory provides defaults which ensure the above example DSL is created.

### Roll your own XDSLFactory

By implementing your own XDSLFactory annotations, you can populate them with the correct defaults.
The annotation needs to be annotated with @Active(ExtensionDSLProcessor), and have the same variables as ExtensionDSLFactory.

EntityDSLFactory is such an example and accepts an array of Components as value. The generated static extension methods construct the component and add it to a given entity. A method is generated for each constructor of a given Component.

Example use case:

```xtend
@EntityDSLFactory(DefenceComponent)
class EntityDSL {}

// Then in a different class:

import static extension ... .EntityDSL.*

class EntityFactory{
	def static character(Entity target) {
		target => [
			// Assuming DefenceComponent has a constructor accepting 2 ints
			defence(0, 10)
		]
	}
}
```

The ActiveAnnotations goes through all constructors in a component and creates a static method according to the following template:

```xtend
/**
 * Where <name> is the lowercased, and "Component" stripped .toSimpleName() of the argument Component class.
 */
def <name>(Entity e, <args constructor>){
  val comp = new <ComponentClass>(<args constructor)
  e.addComponent(comp)
  return comp
}
```
