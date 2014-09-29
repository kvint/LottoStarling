package vo {
public class Room {
    public var id : int;
    public var bet : int;
    public var waitingTimeout : int;
    public var users : Array = [];

    public function findUser(userId : String) : User {
        for each(var user : User in users) {
            if(user.id == userId) return user;
        }
        return null;
    }

    public function addUser(newUser : User) : Boolean {
        for each(var user : User in users) {
            if(user.id == newUser.id) return false;
        }
        users.push(newUser);
        return true;
    }

    public function removeUser(userId : String) : Boolean {
        for(var i : String in users) {
            var user : User = users[i];
            if(user.id == userId) {
                users.splice(i, 1);
                return true;
            }
        }
        return false;
    }
}
}
