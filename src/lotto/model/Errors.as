package lotto.model {
public class Errors {

    public static const NO_ERR : int = 0;
    public static const ERR_AUTH_FIRST : int = 1;
    public static const ERR_NO_USER : int = 2;
    public static const ERR_NO_ROOM : int = 3;
    public static const ERR_NO_GAME : int = 4;
    public static const ERR_NO_PTABLE : int = 5;
    public static const ERR_INVALID_BARREL : int = 6;
    public static const ERR_NO_GOLD : int = 7;
    public static const ERR_INVALID_BONUS : int = 8;
    public static const ERR_NO_BONUS : int = 9;
    public static const ERR_GAME_FINISHED : int = 10;
    public static const ERR_INVALID_DATA : int = 11;
    public static const ERR_UNKNOWN_QUERY : int = 12;
    public static const ERR_NO_CHIPS : int = 13;
    public static const ERR_HAS_TABLE : int = 14;
    public static const ERR_USER_EXISTS : int = 15;
    public static const ERR_NOT_ENOUGH_USERS : int = 16;
    public static const ERR_TABLE_FULL : int = 17;

    static public function getMsg(errorCode : int) : Array {
        var msg : String = "ERR:" + errorCode + " ";
        switch(errorCode) {
            case NO_ERR: return [msg + "no error", ""];
            case ERR_AUTH_FIRST: return [msg + "auth first", "Вы не авторизованы"];
            case ERR_NO_USER: return [msg + "user not found", ""];
            case ERR_NO_ROOM: return [msg + "room not found", ""];
            case ERR_NO_GAME: return [msg + "game not found", ""];
            case ERR_NO_PTABLE: return [msg + "ptable not found", ""];
            case ERR_INVALID_BARREL: return [msg + "invalid barrel", ""];
            case ERR_NO_GOLD: return [msg + "not enough gold", "У вас недостаточно золота"];
            case ERR_INVALID_BONUS: return [msg + "invalid bonus id", ""];
            case ERR_NO_BONUS: return [msg + "user has no bonus", ""];
            case ERR_GAME_FINISHED: return [msg + "game finished", ""];
            case ERR_INVALID_DATA: return [msg + "invalid data", ""];
            case ERR_UNKNOWN_QUERY: return [msg + "unknown query", ""];
            case ERR_NO_CHIPS: return [msg + "user hasn't enough chips", "У вас недостаточно фишек"];
            case ERR_HAS_TABLE : return [msg + "user has table", "У вас уже есть свой стол"];
            case ERR_USER_EXISTS : return [msg + "user exists", "Вы уже присоединились к данному столу"];
            case ERR_NOT_ENOUGH_USERS : return [msg + "not enough users", "Недостаточно игроков за столом"];
            case ERR_TABLE_FULL : return [msg + "table full", "Стол уже заполнен"];
        }
        return [msg + "unknown error", "Ошибка на сервере " + msg];
    }
}
}
