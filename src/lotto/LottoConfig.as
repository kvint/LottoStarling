/**
 * Created by kvint on 20.05.14.
 */
package lotto {
	import dssocket.DSBertSocket;

	import lotto.controller.LoginService;
	import lotto.controller.MainService;
	import lotto.controller.SoundService;
	import lotto.mediators.GameMediator;
	import lotto.mediators.RoomMediator;

	import lotto.mediators.RootMediator;
	import lotto.mediators.TablesMediator;
	import lotto.mediators.WelcomeMediator;
	import lotto.model.AppModel;
	import lotto.model.GameModel;
	import lotto.screens.GameScreen;
	import lotto.screens.RoomScreen;
	import lotto.screens.TablesScreen;
	import lotto.screens.WelcomeScreen;
	import lotto.views.RootView;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IInjector;

	public class LottoConfig implements IConfig {

	[Inject]
	public var mediatorMap:IMediatorMap;
	[Inject]
	public var injector:IInjector;

	public function LottoConfig() {
	}

	public function configure():void {
		mediatorMap.map(RootView).toMediator(RootMediator);
		mediatorMap.map(WelcomeScreen).toMediator(WelcomeMediator);
		mediatorMap.map(RoomScreen).toMediator(RoomMediator);
		mediatorMap.map(TablesScreen).toMediator(TablesMediator);
		mediatorMap.map(GameScreen).toMediator(GameMediator);
		injector.map(DSBertSocket).toSingleton(DSBertSocket);
		injector.map(LoginService).toSingleton(LoginService);
		injector.map(GameModel).toSingleton(GameModel);
		injector.map(AppModel).toSingleton(AppModel);
		injector.map(SoundService);
		injector.map(MainService);
	}
}
}
