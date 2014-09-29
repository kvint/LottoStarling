package apiTest {
import flash.events.TimerEvent;
import flash.utils.Timer;

public class Test {

    static public function runAll() : void {
        /*
        var test1 : Test = new Test("Login Api Test", LoginApiClient);
        var test2 : Test = new Test("UserInfo Api Test", UserInfoApiClient);
        var test3 : Test = new Test("Room Api Test", RoomApiClient);
        var test4 : Test = new Test("Bonus Api Test", BonusApiClient);
        var test5 : Test = new Test("Purchases Api Test", PurchasesApiClient);
        var test6 : Test = new Test("Game Api Test", GameApiClient);
        test1.start(5, 30000);
        test2.start(5, 60000);
        test3.start(5, 90000);
        test4.start(5, 120000);
        test5.start(5, 150000);
        test6.start(5, 300000);
        */
        var test : Test = new Test("Auto Bonus Test", AutoBonusClient);
        test.start(5, 30000);
    }

    private var title : String;
    private var clientClass : Class;
    private var clients : Array = [];
    private var timer : Timer;

    public function Test(title : String, clientClass : Class) {
        this.title = title;
        this.clientClass = clientClass;
    }

    public function start(numClients : int, time : int) : void {
        trace("Start " + title + " " + numClients + " " + time);
        if(timer == null) {
            timer = new Timer(time, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }

        for(var i : int = 1; i <= numClients; i++) {
            var client : BaseClient = new clientClass(i);
            client.start();
            clients.push(client);
        }

        timer.start();
    }

    private function onTimerComplete(event : TimerEvent) : void {
        stop();
    }

    public function stop() : void {
        timer.stop();
        var report : String = "";
        var totalSuccConnects : int = 0;
        var totalDisconnects : int = 0;
        for each(var client : BaseClient in clients) {
            client.stop();
            totalSuccConnects += client.numSuccConnects;
            totalDisconnects += client.numDisconnects;
            report += client.report() + "\n";
        }
        report = "\n\nREPORT " + title + "\n\n" + report + "\n\n" +
            "Success Connects: " + totalSuccConnects + "\n" +
            "Disconnects: " + totalDisconnects
        trace(report);
    }
}
}
