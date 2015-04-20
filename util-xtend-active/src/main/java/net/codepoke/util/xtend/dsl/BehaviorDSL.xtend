package net.codepoke.util.xtend.dsl

import net.codepoke.lib.util.datastructures.tuples.Pair
import net.codepoke.lib.util.predicates.IPredicate
import net.codepoke.lib.util.ai.behaviortrees.DecisionNode
import net.codepoke.lib.util.ai.behaviortrees.IBehavior
import net.codepoke.lib.util.ai.behaviortrees.DelegateBehavior
import net.codepoke.lib.util.ai.behaviortrees.PredicateNode

/**
 * DSL language for constructing BehaviorTrees, for example usage see {@link test.dsl.BehaviorDSLTest}.
 * Currently supports DSL for:
 * <pre>
 * - Selector node: Try all children in order, return after first behavior returns true.
 * - Sequence node: Go through all children in order, return after first behavior returns false.
 * - Guard node: A node which returns the results of a predicate, mostly used first in a sequence; as a "guard" against the rest of the sequence.
 * - Execute node: A node which executes the given logic upon each tick.
 * - Node: Creates and returns a node to which logic can be attached.
 * </pre>
 */
class BehaviorDSL {

	/**
	 * Block for the sequence node, which allows the construction of Selector nodes. 
 	 */
	static def <P, C> selector(DecisionNode<P, C> root, String name, (DecisionNode<P, C>)=>void init) {
		var node = DecisionNode.Patterns.Selector.create
		node.name = name;
		init.apply(node);
		if (root != null)
			root.add(node)
		node;
	}

	static def <P, C> selector(DecisionNode<P, C> root, (DecisionNode<P, C>)=>void init) {
		selector(root, "selector", init)
	}

	static def <P, C> selector((DecisionNode<P, C>)=>void init) {
		selector(null, "selector", init)
	}

	static def <P, C> root(String name, (DecisionNode<P, C>)=>void init) {
		selector(null, name, init)
	}

	/**
	 * Block for the sequence node, which allows the construction of Sequence nodes. 
 	 */
	static def <P, C> sequence(DecisionNode<P, C> root, String name, (DecisionNode<P, C>)=>void init) {
		var node = DecisionNode.Patterns.Sequence.create
		node.name = name;
		init.apply(node)
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> sequence(DecisionNode<P, C> root, (DecisionNode<P, C>)=>void init) {
		sequence(root, "sequence", init)
	}

	static def <P, C> sequence((DecisionNode<P, C>)=>void init) {
		sequence(null, "sequence", init)
	}

	/**
	 * Block for the guard node, which serves as a predicate guard clause node in primarily Sequence nodes
	 */
	static def <P, C> guard(DecisionNode<P, C> root, String name, IPredicate<Pair<P, C>> check) {
		var node = new PredicateNode<P, C>(check);
		node.name = name;
		if (root != null)
			root.add(node)
		node
	}
	
	static def <P, C> guard(DecisionNode<P, C> root, IPredicate<Pair<P, C>> check) {
		guard(root, "guard", check);
	}

	/**
	 * Block for Node methods, which allow the construction of nodes which delegate their behavior
	 */
	static def <P, C> node(DecisionNode<P, C> root, String name, (DelegateBehavior<P, C>)=>void init) {
		var node = new DelegateBehavior(name)
		init.apply(node)
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> node(DecisionNode<P, C> root, (DelegateBehavior<P, C>)=>void init) {
		node(root, "node", init)
	}

	static def <P, C> node((DelegateBehavior<P, C>)=>void init) {
		node(null, "node", init)
	}

	static def <P, C> execute(DecisionNode<P, C> root, String name, (P, C)=>IBehavior.Status init) {
		var node = new DelegateBehavior<P, C>(name) => [
			tick = init;
		]
		if (root != null)
			root.add(node)
		node
	}

	static def <P, C> execute(DecisionNode<P, C> root, (DelegateBehavior<P, C>)=>void init) {
		node(root, "execute", init)
	}

}
