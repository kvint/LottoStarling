/**
 * Created by AlexanderSla on 04.06.2014.
 */
package lotto {
	import flash.utils.Dictionary;

	import starling.textures.Texture;

	public class Assets {

		[Embed(source="../../assets/back_tile.png")]
		public static const BackTile:Class;

		[Embed(source="../../assets/top_panel@2x.png")]
		public static const TopPanel:Class;

		[Embed(source="../../assets/avatar_table.png")]
		public static const AvatarTable:Class;

		[Embed(source="../../assets/room_bg@2x.png")]
		public static const RoomBg:Class;

		[Embed(source="../../assets/table_person@2x.png")]
		public static const TablePerson:Class;

		[Embed(source="../../assets/table_person_h@2x.png")]
		public static const TablePersonH:Class;

		private static var assets:Dictionary = new Dictionary();

		public static function get(item:Class):Texture {
			if(assets[item] == null)
				assets[item] = Texture.fromEmbeddedAsset(item);

			return assets[item];
		}
	}
}
