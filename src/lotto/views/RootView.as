/**
 * Created by kvint on 20.05.14.
 */
package lotto.views {
	import feathers.display.TiledImage;

	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	public class RootView extends Sprite{

	private var _screensCont:Sprite;

	public function RootView() {
		_screensCont = new Sprite();
		addChild(_screensCont);

	}

	public function get screensCont():Sprite {
		return _screensCont;
	}
}
}
