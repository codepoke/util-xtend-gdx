package test.dsl

import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton

import static extension net.codepoke.util.dsl.TableDSL.*

class TableDSLTest {


	def void setup() {

		val skin = null
				
		val base = new Table() => [

			stack [

				table [
					add(new Label("A", skin))
					add(new TextButton("B", skin))
				]

				table [
					table [
						add(new Label("E", skin))
					].expand.fill.pad(50)
				]

			]

			table [
				stack [
					add(new Label("C", skin))
					add(new Label("D", skin))

				].expand.fill.pad(50)
			]

		]

	}

}