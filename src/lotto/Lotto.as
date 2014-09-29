/**
 * Created by kvint on 19.05.14.
 */
package lotto {
	import feathers.display.TiledImage;

	import lotto.views.RootView;

	import starling.display.Sprite;
	import starling.events.Event;

	public class Lotto extends Sprite {


	private var _bg:TiledImage;

	public function Lotto() {

		_bg = new TiledImage(Assets.get(Assets.BackTile));

		addChild(_bg);

		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(event:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		_bg.width = stage.stageWidth;
		_bg.height = stage.stageHeight;

		var root:RootView = new RootView();
		addChild(root);
	}
}
}
