package net.codepoke.util.xtend.literals;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.xtext.xbase.lib.Inline;

public class ArrayLiterals {

	@Inline("new double[$1][$2]")
	public static double[][] newDoubleArray(int outerSize, int innerSize) {
		throw new UnsupportedOperationException();
	}

	/**
	 * Returns a sub range of the array.
	 * 
	 * @param array
	 * @param range
	 * @return
	 */
	public static List<Integer> get(int[] array, Iterable<Integer> range) {
		List<Integer> sub = new ArrayList<Integer>();
		for (Integer idx : range) {
			sub.add(array[idx]);
		}
		
		return sub;
	}
	
}
