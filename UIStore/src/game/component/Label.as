package game.component
{
	/**
	 * @author LiuPeng
	 */	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import game.component.core.IDisposable;
	import game.component.core.ISkinnable;
	
	public class Label extends TextField implements ISkinnable, IDisposable
	{
		public static const FILTER_BLACK:Array = [new GlowFilter(0x000000, 0.8, 2, 2, 12)];
		public static const FILTER_WHITE:Array = [new GlowFilter(0xFFFFFF, 0.8, 2, 2, 12)];
		public static const DEFAULT_FORMAT:Object = {align:"left", bold:false, color:0x000000, font:"SimSun", italic:false, leading:0, letterSpacing:0, size:12, underline:false};
		public static const DEFAULT_STATE:String = "normal";
		
		
		private var _defaultFormat:TextFormat
		private var _skin:Object;
		private var _width:Number;
		private var _height:Number;
		private var _state:String;
		
		/**
		 * tips显示的内容1
		 */
		private var _info1:Object;
		/**
		 * tips显示的内容2
		 */
		private var _info2:Object;
		/**
		 * 显示tips的回调函数
		 */
		private var _showTipFunc:Function;
		/**
		 * 隐藏tips的回调函数
		 */
		private var _hideTipsFunc:Function;
		/**
		 * 鼠标悬浮移除事件的标识
		 */
		private var _isEventOn:Boolean;
		/**
		 * 鼠标点击事件 
		 */		
		private var _click:Function;
		
		public function Label()
		{
			initialize();
		}
		
		private function initialize():void
		{
			this.mouseEnabled = false;
			this.mouseWheelEnabled = false;
			this.wordWrap = true;
			this.selectable = false;
			this.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function set skin(value:Object):void
		{
			_skin = value;
			this.autoSize = TextFieldAutoSize.NONE;
			this.name = _skin.name;
			this.state = DEFAULT_STATE;
		}
		
		public function get skin():Object
		{
			return _skin;
		}	
		
		private function updateDefaultTextFormat(format:Object):void
		{
			var defaultTextFormat:TextFormat = new TextFormat();
			for(var property:String in format)
			{
				defaultTextFormat[property] = format[property];
			}
			this.defaultTextFormat = defaultTextFormat;
		}
		
		private function updateFilter(color:int):void
		{
			if(color == 0x000000)
			{
				this.filters = FILTER_WHITE;
			}
			else
			{
				this.filters = FILTER_BLACK;
			}
		}
		
		public function set state(value:String):void
		{
			if(_skin[value] != null)
			{
				_state = value;
				updateState();
			}
		}
		
		public function get state():String
		{
			return _state;
		}
		
		private function updateState():void
		{
			var obj:Object = _skin[_state];
			this.x = _skin.x + obj.x;
			this.y = _skin.y + obj.y;
			this.width = obj.width;
			this.height = obj.height;
			updateDefaultTextFormat(obj.format);
			updateFilter(int(this.defaultTextFormat.color));
			this.htmlText = obj.content;
		}
		
		public function set enabled(value:Boolean):void
		{
			this.mouseEnabled = value;
		}
		
		public function get enabled():Boolean
		{
			return this.mouseEnabled;
		}
		
		/**
		 * 从父容器中移除自己 
		 */
		public function removeFromParent():void
		{
			parent && parent.removeChild( this );
		}
		
		public function dispose():void
		{
			removeFromParent();
			if(type == TextFieldType.INPUT)
			{
				removeEventListener(MouseEvent.ROLL_OUT, outHandler);
				removeEventListener(MouseEvent.ROLL_OVER, overHandler);
			}
			if(_isEventOn) 
			{
				_isEventOn		= false;
				_info1			= null;
				_info2			= null;
				_showTipFunc	= null;
				_hideTipsFunc	= null;
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			}
			removeEventListener(MouseEvent.CLICK, onClick);
		}
		/**
		 * 设置鼠标点击事件执行的函数
		 * @param p_click 点击需要执行的回调函数
		 * 
		 */		
		public function set click(p_click:Function):void
		{
			if(p_click == null) 
			{
				_click = null;
				hasEventListener(MouseEvent.CLICK ) &&  removeEventListener(MouseEvent.CLICK, onClick);
				return;
			}
			enabled = true;
			_click = p_click;
			hasEventListener(MouseEvent.CLICK ) ||  addEventListener(MouseEvent.CLICK, onClick );
		}
		
		/**
		 * 鼠标点击事件
		 */		
		private function onClick( p_evt:Event ):void
		{
			_click && _click();
		}
		
		
		/**
		 * 显示文本Tips 
		 * @param info1			tips的内容1
		 * @param info2			tips的内容2
		 * @param showTipFunc	显示tips的回调函数(默认是 TipsUtil.show)
		 * @param hideTipFunc	隐藏tips的回调函数(默认是 TipsUtil.hide)
		 */		
		public function showTip(info1:Object, info2:Object = null, showTipFunc:Function = null, hideTipFunc:Function = null):void
		{
			if(!_isEventOn) 
			{
				mouseEnabled = true;
				_isEventOn = true;
				addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			}
			_info1			= info1;
			_info2			= info2;
			_showTipFunc	= showTipFunc != null ? showTipFunc : Component.SHOW_TIP;
			_hideTipsFunc	= hideTipFunc != null ? hideTipFunc : Component.HIDE_TIP;
		}
		
		
		/**
		 * 文本鼠标悬浮事件
		 */
		private function onRollOver(evt:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
			_showTipFunc(_info1, _info2, new Rectangle(evt.stageX, evt.stageY));
		}
		
		
		/**
		 * 文本鼠标移开事件
		 */
		private function onRollOut(evt:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
			_hideTipsFunc();
		}
		
		public override function set type(value:String):void
		{
			super.type = value;
			if(value == TextFieldType.INPUT)
			{
				addEventListener(MouseEvent.ROLL_OUT, outHandler);
				addEventListener(MouseEvent.ROLL_OVER, overHandler);
			}				
		}
			
			/**
			 * 输入框文本鼠标悬浮事件
			 */
			private function overHandler(evt:MouseEvent):void
			{
				Mouse.cursor = MouseCursor.IBEAM;
			}
			
			
			/**
			 * 输入框文本鼠标移开事件
			 */
			private function outHandler(evt:MouseEvent):void
			{
				Mouse.cursor = MouseCursor.AUTO;
			}
	}
}