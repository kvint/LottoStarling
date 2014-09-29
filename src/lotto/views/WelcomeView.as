/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto.views {
	import feathers.controls.Button;

	import starling.display.DisplayObjectContainer;

	public class WelcomeView extends DisplayObjectContainer {

		private var _buttonPlay:Button;

		public function WelcomeView() {
			super();
			_buttonPlay = new Button();
			_buttonPlay.label = "Play";
			addChild(_buttonPlay);
		}
	}
}
