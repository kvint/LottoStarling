package {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.ProgressEvent;

import model.MainModel;

import mx.preloaders.SparkDownloadProgressBar;

public class Preloader extends SparkDownloadProgressBar {

    [Embed(source="/assets/img/preloader/splash3.jpg")]
    private var SplashImage : Class;

    [Embed(source="/assets/img/preloader/bg.png")]
    private var BgImage : Class;

    [Embed(source="/assets/img/preloader/line.png")]
    private var LineImage : Class;

    private var view : Sprite;

    private var line : Bitmap = new LineImage();

    public function Preloader() {
        super();
    }

    /**
     *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
     *  NOTE: This event can be commented out to stop preloader from completing during testing
     */
    override protected function initCompleteHandler(event : Event) : void {
        dispatchEvent(new Event(Event.COMPLETE));
    }

    override protected function createChildren() : void {
        if(view != null) return;

        this.addChild(new SplashImage());

        view = new Sprite();
        view.addChild(new BgImage());
        view.addChild(line);
        line.x = 20;
        line.y = 6;

        var startX : Number = Math.round((stageWidth - view.width) / 2);
        var startY : Number = 620;

        view.x = startX;
        view.y = startY;
        addChild(view);
    }

    // NOTE: prevent null pointer exception
    override protected function setInitProgress(completed:Number, total:Number):void {
        // do nothing
    }

    override protected function progressHandler(e : ProgressEvent) : void {
        if (view) {
            var maxWidth : int = 660;
            line.width = Math.round((maxWidth * e.bytesLoaded) / e.bytesTotal);
        }
        else show();
    }

    private function show() : void {
        // swfobject reports 0 sometimes at startup
        // if we get zero, wait and try on next attempt
        if (stageWidth == 0 && stageHeight == 0) {
            try {
                stageWidth = stage.stageWidth;
                stageHeight = stage.stageHeight
            }
            catch (e : Error) {
                stageWidth = loaderInfo.width;
                stageHeight = loaderInfo.height;
            }
            if (stageWidth == 0 && stageHeight == 0) return;
        }

        createChildren();
    }
}
}
