package game.component
{
	/**
	 * @author LiuPeng
	 */	
	import flash.events.MouseEvent;

	[Event(name="change", type="flash.events.Event")]
	public class RadioButton extends Button
	{
		private var _selected:Boolean;
		private var _data:Object;
		
		public function RadioButton()
		{
			super();
			initialize();
		}
		
		private function initialize():void
		{
			_selected = false;
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(_selected == true)
			{
				this.state = ButtonState.STATE_DOWN;
			}
			else
			{
				this.state = ButtonState.STATE_NORMAL;
			}
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		private function onClick(evt:MouseEvent):void
		{
			if((this.parent is RadioButtonGroup) == false)
			{
				this.selected = !this.selected;
				dispatchEvent(Component.EVENT_CHANGE);
			}
		}
		
		protected override function onMouseEvent(evt:MouseEvent):void
		{
			if(_selected == false)
			{
				super.onMouseEvent(evt);
			}
		}
		
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		override public function dispose():void
		{
			super.dispose();	
			
			removeEventListener(MouseEvent.CLICK, onClick);
			_selected = false;
			_data = null;
		}
	}
}