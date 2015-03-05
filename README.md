# util-xtend-gdx
Active Annotations which can be used for LibGDX &amp; Artemis


# EntityDSLFactory

Accepts an array of Components, and populates the annotated class with static extensions methods which construct the component and add it to a given entity. A method is generated for each constructor of a given Component.

This in turn allows syntax like:

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
