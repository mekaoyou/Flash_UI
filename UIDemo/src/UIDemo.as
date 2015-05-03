package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.ApplicationDomain;
	
	import game.component.Component;
	
	public class UIDemo extends Sprite
	{
		public function UIDemo()
		{
			stage.align=StageAlign.TOP_LEFT;
			stage.scaleMode=StageScaleMode.NO_SCALE;
			
			Component.domain = ApplicationDomain.currentDomain;
			
			init();
		}
		
		private function init():void
		{
			var bag:BagPanel = new BagPanel();
			addChild(bag);
		}
	}
}