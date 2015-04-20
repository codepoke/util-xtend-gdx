package test.dsl

import net.codepoke.lib.util.ai.behaviortrees.IBehavior

import static extension net.codepoke.util.xtend.dsl.BehaviorDSL.*

class BehaviorDSLTest {
	
	static def testScript() {

		val unit = new Unit()

		root("Simple Behavior") [
			
			sequence("Treasure Collection") [
				val treasure = new Target()
				
				selector("Find Treasure") [
					sequence("Dagobert Duck") [
						guard[unit.greed > 50]
						execute[treasure.name = "Treasure Chest"]
					]
					sequence("Monk") [
						guard[unit.greed <= 50]
						execute[treasure.name = "Apple"]
					]
				]
				
				execute[moveTo(treasure)]
				
				sequence("Grab Treasure") [
					guard[isNear(treasure)]
					execute[grabTreasure]
				]
				
			]
			
			sequence("Aggressive") [
				
				val extension enemy = new Target()
				
				selector("Select Target") [
					
					sequence("Strong Target") [
						guard[unit.health > 50]
						execute[enemy.name = "Tower"]
					]
					
					sequence("Weak Target") [
						guard[unit.health <= 50]
						execute[enemy.name = "Minion"]
					]
				]
				execute[moveTo(enemy)]
				
				sequence("Attack Target") [
					guard [isNear(enemy)]
					execute[attack(enemy)]
				]
			]
		]

	}

	static def IBehavior.Status attack(Target t) {
		IBehavior.Status.Running
	}

	static def IBehavior.Status moveTo(Target t) {
		IBehavior.Status.Running
	}

	static def isNear(Target target) {
		true
	}

	static def grabTreasure() {
		IBehavior.Status.Ready
	}

	static class Target {
		String name;
	}

	static class Unit {
		int health;
		int greed;
	}
}