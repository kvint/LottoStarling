package {

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import lotto.Lotto;
	import lotto.LottoConfig;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.starlingViewMap.StarlingViewMapExtension;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	import starling.core.Starling;

	[SWF(backgroundColor = "#000000", frameRate = "60", width="100%",height = "100%")]
	public class Main extends Sprite {
		private var _context:IContext;
		public function Main() {
			var screenWidth:int  = stage.fullScreenWidth;
			var screenHeight:int = stage.fullScreenHeight;
			var viewPort:Rectangle = new Rectangle(0, 0, screenWidth, screenHeight)
			const starling:Starling = new Starling(Lotto, stage, viewPort);

			_context = new Context()
					.install( MVCSBundle, StarlingViewMapExtension)
					.configure( LottoConfig, new ContextView( this ), starling);
			starling.start();
		}
	}
}
