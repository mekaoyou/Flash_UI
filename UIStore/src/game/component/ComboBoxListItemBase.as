package game.component
{
	/**
	 * 
	 * @author LiuPeng
	 * 
	 */	
	public class ComboBoxListItemBase extends ListItemBase
	{
		protected var _label:String;
		
		public function ComboBoxListItemBase()
		{
			buttonMode = true;
			super();
		}
		
		public function set label(value:String):void
		{
			_label = value;
		}
		
		public function get label():String
		{
			return _label;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_label = null;
		}
	}
}