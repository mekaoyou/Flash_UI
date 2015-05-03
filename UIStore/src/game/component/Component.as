package game.component
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import game.component.core.IDisposable;
	import game.component.core.ISkinnable;
	
	/**
	 * @author LiuPeng
	 */
	public class Component extends Sprite implements ISkinnable, IDisposable
	{
		public static const EVENT_TYPE_CHANGE:String 		= "change";
		public static const EVENT_TYPE_CONSTRUCT:String 	= "construct";
		public static const EVENT_CHANGE:Event 				= new Event(EVENT_TYPE_CHANGE);
		
		/**
		 * 引用TipsUtil.show
		 */
		public static var SHOW_TIP:Function;
		/**
		 * 引用TipsUtil.hide
		 */
		public static var HIDE_TIP:Function;
		/**
		 * 引用MouseManager.setButtonMode
		 */		
		public static var MOUSE_SET_BUTTONMODE:Function;
		
		private static var _domain:ApplicationDomain; //所有UI面板资源放入该ApplicationDomain
		
		private var _skin:Object;
		private var _width:Number;
		private var _height:Number;
		private var _enabled:Boolean;
		
		private var _uiList:Array;
		
		public static function set domain(value:ApplicationDomain):void
		{
			_domain = value;
		}
		
		public static function get domain():ApplicationDomain
		{
			return _domain;
		}
		
		//--------------------------------------------------------
		//instance method
		//--------------------------------------------------------
		public function Component()
		{
			_enabled = true;
		}
		
		public function set skin(value:Object):void
		{
			_skin = value;
			this.name = _skin.name;
			this.x = _skin.x;
			this.y = _skin.y;
			_width = _skin.width;
			_height = _skin.height;
			if(_skin.children != null)
			{
				createChildren(_skin);
			}
			configChildren();
		}
		
		public function get skin():Object
		{
			return _skin;
		}
		
		private function createChildren(skin:Object):void
		{
			var children:Array = skin.children;
			var len:int = children.length;
			for(var i:int = len - 1; i >= 0; i--)
			{
				var childSkin:Object = children[i];
				var child:ISkinnable = ComponentFactory.createComponentByName(childSkin.name);
				if(child == null)
				{
					child = ComponentFactory.createComponentByType(childSkin.type);
				}
				child.skin = childSkin;
				addChild(child as DisplayObject);
			}
		}
		
		protected function configChildren():void
		{
			//子类中对元素建立引用入口
		}
		
		public override function set width(value:Number):void
		{
			super.width = value;
			_width = value;
		}
		
		public override function get width():Number
		{
			if(super.width > 0)
			{
				return super.width;
			}
			return _width;
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			_height = value;
		}
		
		public override function get height():Number
		{
			if(super.height > 0)
			{
				return super.height;
			}
			return _height;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			this.mouseChildren = _enabled;
			this.mouseEnabled = _enabled;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public override function set buttonMode(value:Boolean):void
		{
			super.buttonMode = value;
			if(MOUSE_SET_BUTTONMODE != null) MOUSE_SET_BUTTONMODE(this,value);
		}
		
		
		/**
		 * 从父容器中移除自己 
		 */
		public function removeFromParent():void
		{
			parent && parent.removeChild( this ); 
		}
		
		
		/**
		 * 设置Label的值 
		 * @param p_childName	目标Label的索引名
		 * @param p_txt			目标Label的值
		 * @param p_txt			目标Label的文本颜色（默认为0无）
		 * @return 				目标Label
		 */		
		public function setLabelTxt(p_childName:String, p_txt:String, p_txtColor:uint = 0):Label
		{
			var label:Label = getUiByName(p_childName) as Label;
			
			if(label)
			{
				label.htmlText = p_txt;
				if(p_txtColor != 0) label.textColor = p_txtColor;
			}
			
			return label;
		}
		
		
		/**
		 * 用于快速设置一个ui主键的tooltip
		 * 目前支持 Label & Button，如需传递扩展属性， 请直接调用组件的showTip方法
		 * 
		 * @param p_childName
		 * @param p_info
		 * @param p_info2
		 */
		public function setUITip(p_childName:String, p_info:Object ,p_info2:Object = null):void
		{
			var ui:DisplayObject = getUiByName(p_childName);
			
			if( !ui || !ui.hasOwnProperty('showTip' ) ) 
			{
				trace( '【警告】， 组件不存在， 或者还未实现showTip方法 ', ui, p_childName ) 
				return;
			}
			ui['showTip'](p_info, p_info2);
		}
		
		
		
		/**
		 * 设置UI的显示与否
		 * @param p_childName
		 * @param p_visable
		 */
		public function setUIVisible(p_childName:String, p_visible:Boolean):DisplayObject
		{
			var ui:DisplayObject = getUiByName(p_childName);
			if(ui) ui.visible = p_visible;
			return ui;
		}
		
		/**
		 * 根据名称显示坐标位置
		 */
		public function setUIXY( p_childName:String, p_x:int, p_y:int, p_oft:Boolean = false ):DisplayObject
		{
			var ui:DisplayObject = getUiByName(p_childName);
			if(ui) {
				ui.x = p_oft? ui.x + p_x : p_x;
				ui.y = p_oft? ui.y + p_y : p_y;
			}
			return ui;
		}
		
		/**
		 * 取UI 
		 * @param p_childName ui名
		 */		
		private function getUiByName(p_childName:String):DisplayObject
		{
			var disObj:DisplayObject;
			
			_uiList || ( _uiList = [] );
			
			if(_uiList[p_childName] == null)
			{
				disObj = this.getChildByName(p_childName);
				_uiList[p_childName] = disObj;
			}
			else
			{
				disObj = _uiList[p_childName];
			}
			
			return disObj;
		}
		
		public function dispose():void
		{
			removeFromParent();
			if(MOUSE_SET_BUTTONMODE != null) MOUSE_SET_BUTTONMODE(this,false);
			Mouse.cursor = MouseCursor.AUTO;
			_uiList && ( _uiList.length = 0 );
			_uiList = null;
		}
	}
}