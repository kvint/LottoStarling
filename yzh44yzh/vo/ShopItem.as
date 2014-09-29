package vo {

public class ShopItem {

    public var num : int = 0;
    public var free : int = 0;
    public var price : int = 0;

    public static function init(num : int, free : int, price : int) : ShopItem {
        var item : ShopItem = new ShopItem();
        item.num = num;
        item.free = free;
        item.price = price;
        return item;
    }

    public function toString() : String {
        return "ShopItem: " + num + " " + free + " " + price;
    }
}
}
