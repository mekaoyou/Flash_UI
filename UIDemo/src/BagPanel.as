package
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.ApplicationDomain;
	
	import game.component.Component;
	import game.component.Panel;
	import game.skin.BagPanelSkin;
	
	public class BagPanel extends Panel
	{
		public function BagPanel()
		{
			super();
			init();
		}
		
		private function init():void
		{
			skin = BagPanelSkin.skin;
			
		}
	}
}