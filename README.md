# util-xtend-gdx
General Xtend code which can be used for LibGDX &amp; Artemis, such as Active Annotations, extension methods and general utility code.

# ActiveAnnotations

## [[ExtensionDSLFactory]]

An Active Annotation which creates extension methods that unwrap and delegate the constructors of the targeted value, apply the created instance on given code, and then return it.

In summary, with a single annotation you can generate DSL instead of having to handroll your own.
This annotation generates the mundane parts of DSLs which normally need to be handwritten and are 80% of the DSL, such as [Kotlin's Anko](https://github.com/JetBrains/anko).

An example use case, as provided by the [[EntityDSLFactory]]:

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

or when used to create a DSL for Table and Scene2D:

```xtend
 table[
        label("Please select one of the following:", skin)

        table[
            textButton("Cancel", skin)
            textButton("OK", skin)
        ]
    ]
```

## [[Mappers]]

Used in the Artemis framework to generate the ComponentMappers for given targets, and create extension methods which allow components to be accessed in a variable-access like syntax.

This allows syntax such as '''xtend entity.health ''' to access the "HealthComponent", as opposed to using a ComponentMapper.get(), or Entity.getComponent(HealthComponent.class)

