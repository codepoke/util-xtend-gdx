package net.codepoke.util.xtend.extensions;

import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Pure;

import net.codepoke.lib.util.artemis.systems.rpg.IValue;

/**
 * Contains sensible operator overload extension methods for IValue.
 * All the basic arithmetic operators work on the getVal() of an IValue.
 * 
 * @author GJ Roelofs <gj.roelofs@codepoke.net>
 *
 */
public class ValueExtension {

	@Pure
	@Inline("$1.getVal() % $2")
	public static int operator_modulo(final IValue value, final int n) {
		return (value.getVal() % n);
	}

	@Pure
	@Inline("$1.getVal() * $2")
	public static int operator_multiply(final IValue value, final int n) {
		return (value.getVal() * n);
	}

	@Pure
	@Inline("$1.getVal() / $2")
	public static int operator_divide(final IValue value, final int n) {
		return (value.getVal() / n);
	}

	@Pure
	@Inline("$1.getVal() + $2")
	public static int operator_plus(final IValue value, final int n) {
		return (value.getVal() + n);
	}

	@Pure
	@Inline("$1.getVal() - $2")
	public static int operator_minus(final IValue value, final int n) {
		return (value.getVal() - n);
	}

	@Inline("$1.modifyValue(-$2)")
	public static void operator_remove(final IValue value, final int n) {
		value.modifyValue(-n);
	}

	@Inline("$1.modifyValue($2)")
	public static void operator_add(final IValue value, final int n) {
		value.modifyValue(n);
	}

}
