package net.codepoke.util.xtend.extensions

import java.util.List

class ListExtensions {
	
	def static average(List<? super Number> array){
		var value = 0.0
		for( v : array)
			value += (v as Number).doubleValue
		return value / array.size
	}
	
}