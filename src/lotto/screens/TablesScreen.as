/**
 * Created by AlexanderSla on 26.09.2014.
 */
package lotto.screens {
	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.Screen;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class TablesScreen extends Screen {

		public var backBtn:Button;
		public var tablesList:List;

		public function TablesScreen() {
			backBtn = new Button();
			tablesList = new List();
			addChild(tablesList);

			var listLayout:AnchorLayoutData = new AnchorLayoutData();
			listLayout.topAnchorDisplayObject = backBtn;
			listLayout.top = 10;
			listLayout.left = 10;
			listLayout.right = 10;
			listLayout.bottom = 10;
			tablesList.layoutData = listLayout;

			backBtn.label = "Back to lobby";
			addChild(backBtn);

			layout = new AnchorLayout();
		}
	}
}
