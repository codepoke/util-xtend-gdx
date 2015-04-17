package net.codepoke.util.dsl

import net.codepoke.lib.util.datastructures.tuples.Pair
import net.codepoke.lib.util.predicates.IPredicate
import net.codepoke.lib.util.ai.behaviortrees.DecisionNode
import net.codepoke.lib.util.ai.behaviortrees.IBehavior

class BehaviorDSL {

	/**
	 * Block for the sequence node, which allows the construction of Selector nodes. 
 	 */
	static def <P, C> selector(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, String name, (net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		var node = DecisionNode.Patterns.Selector.create
		node.name = name;
		init.apply(node);
		if (root != null)
			root.add(node)
		node;
	}

	static def <P, C> selector(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, (net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		selector(root, "selector", init)
	}

	static def <P, C> selector((net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		selector(null, "selector", init)
	}

	static def <P, C> root(String name, (net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		selector(null, name, init)
	}

	/**
	 * Block for the sequence node, which allows the construction of Sequence nodes. 
 	 */
	static def <P, C> sequence(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, String name, (net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		var node = DecisionNode.Patterns.Sequence.create
		node.name = name;
		init.apply(node)
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> sequence(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, (net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		sequence(root, "sequence", init)
	}

	static def <P, C> sequence((net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C>)=>void init) {
		sequence(null, "sequence", init)
	}

	/**
	 * Block for the guard node, which serves as a predicate guard clause node in primarily Sequence nodes
	 */
	static def <P, C> guard(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, String name, IPredicate<Pair<P, C>> check) {
		var node = new net.codepoke.lib.util.ai.behaviortrees.PredicateNode<P, C>(check);
		node.name = name;
		if (root != null)
			root.add(node)
		node
	}
	
	static def <P, C> guard(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, IPredicate<Pair<P, C>> check) {
		guard(root, "guard", check);
	}

	/**
	 * Block for Node methods, which allow the construction of nodes which delegate their behavior
	 */
	static def <P, C> node(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, String name, (net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior<P, C>)=>void init) {
		var node = new net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior(name)
		init.apply(node)
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> node(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, (net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior<P, C>)=>void init) {
		node(root, "node", init)
	}

	static def <P, C> node((net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior<P, C>)=>void init) {
		node(null, "node", init)
	}

	static def <P, C> execute(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, String name, (P, C)=>net.codepoke.lib.util.ai.behaviortrees.IBehavior.Status init) {
		var node = new net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior<P, C>(name) => [
			tick = init;
		]
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> execute(net.codepoke.lib.util.ai.behaviortrees.DecisionNode<P, C> root, (net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior<P, C>)=>void init) {
		node(root, "execute", init)
	}

}
