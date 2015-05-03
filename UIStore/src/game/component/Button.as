package game.component
{
	/**
	 * @author LiuPeng
	 */	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class Button extends Container
	{
		private var _state:String;
		private var _label:Label; //optional
		private var _image:Image; //required
		/**
		 * 快速设置按钮点击的回调函数 
		 */
		public var click:Function, eclick:Function;
		/**
		 * 快速设置鼠标经过函数 
		 */
		public var over:Function, eover:Function;
		/**
		 * 快速设置鼠标移除函数 
		 */
		public var out:Function,eout:Function;
		
		/**
		 * button上tip参数 
		 */
		private var _info1:Object;
		/**
		 * button上tip参数 
		 */
		private var _info2:Object;

		public function Button()
		{
			super();
			initialize();
		}
		
		private function initialize():void
		{
			this.buttonMode = true;
			this.mouseChildren = false;
			this.enabled = true;
		}
		
		private function addMouseEventListener():void
		{
			addEventListener(MouseEvent.ROLL_OVER, onMouseEvent);
			addEventListener(MouseEvent.ROLL_OUT, onMouseEvent);
			addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
		}
		
		private function removeMouseEventListener():void
		{
			removeEventListener(MouseEvent.ROLL_OVER, onMouseEvent);
			removeEventListener(MouseEvent.ROLL_OUT, onMouseEvent);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
		}
		
		/**
		 * 显示文本Tips 
		 * @param info1	tips的内容1
		 * @param info2	tips的内容2
		 */		
		public function showTip(info1:Object, info2:Object = null):void
		{
			_info1 = info1;
			_info2 = info2
		}
		
		protected function onMouseEvent(evt:MouseEvent):void
		{
			switch(evt.type)
			{
				case MouseEvent.ROLL_OUT:
					this.state = ButtonState.STATE_NORMAL;
					out && out();
					eout && eout(evt);
					HIDE_TIP && HIDE_TIP();
					break;
				case MouseEvent.ROLL_OVER:
					this.state = ButtonState.STATE_OVER;
					over && over();
					eover && eover( evt );
					SHOW_TIP && _info1 && SHOW_TIP( _info1, _info2, new Rectangle(evt.stageX,evt.stageY));
					break;
				case MouseEvent.MOUSE_DOWN:
					this.state = ButtonState.STATE_DOWN;
					break;
				case MouseEvent.MOUSE_UP:
					this.state = ButtonState.STATE_OVER;
					click && click();
					eclick && eclick( evt );
					break;
			}
		}
		
		public override function set enabled(value:Boolean):void
		{
			super.enabled = value;
			this.mouseEnabled = value;
			if(value == true)
			{
				addMouseEventListener();
				this.state = ButtonState.STATE_NORMAL;
			}
			else
			{
				removeMouseEventListener();
				this.state = ButtonState.STATE_DISABLE;
			}
		}
		
		protected function set state(value:String):void
		{
			_state = value;
			if(_image != null)
			{
				_image.state = value;
			}
			if(_label != null)
			{
				_label.state = value;
			}
		}
		
		protected function get state():String
		{
			return _state;
		}
		
		protected override function configChildren():void
		{
			_image = getChildByType(Image) as Image;
			_label = getChildByType(Label) as Label;
		}
		
		public function get label():Label
		{
			return _label;
		}
		
		private function getChildByType(type:Class):DisplayObject
		{
			var len:int = this.numChildren;
			for(var i:int = 0; i < len; i++)
			{
				var child:DisplayObject = this.getChildAt(i);
				if(child is type)
				{
					return child;
				}
			}
			return null;
		}
		
		public override function set width(value:Number):void
		{
			if(_image != null)
			{
				_image.width = value;
			}
		}
		
		public override function set height(value:Number):void
		{
			if(_image != null)
			{
				_image.height = value;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeMouseEventListener();
			_image && _image.dispose();
			_label && _label.dispose();
			
			click	= eclick 	= null;
			over	= eover		= null;
			out		= eout		= null;
			_image 	= null;
			_label 	= null;
			
		}
	}
}