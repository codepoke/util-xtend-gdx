package net.codepoke.util.dsl

import com.badlogic.gdx.scenes.scene2d.ui.Table

import static extension net.codepoke.util.dsl.TableDSL.*

class TestTableDSL extends Table {
	
	def void setup(){
		
		stack [
			
		]
		
		table [
			stack [
				
					
			].expand.fill
		]
		
	}
	
}