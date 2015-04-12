package net.codepoke.util.xtend.extensions

import java.util.stream.Stream
import java.util.stream.Collectors

class StreamExtensions {


	/**
	 * TODO: Write autogen for different types
	 * @Inline number?
	 */
	 
	/**
	 * Simple operators for Streams, Number is treated as a Double
	 */
	def static divide(Stream<? extends Number> stream, Number n) {
		return stream.map[it.doubleValue / n]
	}

	def static multiply(Stream<? extends Number> stream, Number n) {
		return stream.map[it.doubleValue * n]
	}

	def static plus(Stream<? extends Number> stream, Number n) {
		return stream.map[it.doubleValue + n]
	}

	def static minus(Stream<? extends Number> stream, Number n) {
		return stream.map[it.doubleValue - n]
	}
	
	/**
	 * Delegators for commonly used operations on a Stream
	 */

	def static <T> format(Stream<T> stream, String formatter) {
		return stream.map[String.format(formatter, it)]
	}

	/**
	 * Delegation to Collectors.joining
	 */
	def static <T> joining(Stream<String> stream, String delimiter, String prefix, String suffix) {
		return stream.collect(Collectors.joining(delimiter, prefix, suffix))
	}

	def static <T> joining(Stream<String> stream, String delimiter) {
		return stream.collect(Collectors.joining(delimiter))
	}

	def static <T> joining(Stream<String> stream) {
		return stream.collect(Collectors.joining())
	}

}