package game.component
{
	/**
	 * @author LiuPeng
	 */	
	import flash.display.Bitmap;
	
	import game.component.core.IDisposable;
	import game.component.core.ISkinnable;
	
	public class Image extends Bitmap implements ISkinnable, IDisposable
	{
		public static const DEFAULT_STATE:String = "normal";
		
		protected var _skin:Object;
		protected var _state:String;
		
		protected var _keyList:Array;
		
		public function Image()
		{
			super(null, "auto", false);
			_keyList = [];
		}
		
		public function set skin(value:Object):void
		{
			_skin = value;
			this.name = _skin.name;
			this.state = DEFAULT_STATE;
		}
		
		public function get skin():Object
		{
			return _skin;
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
		
		/**
		 * 从父容器中移除自己 
		 */
		public function removeFromParent():void
		{
			parent && parent.removeChild( this ); 
		}
		
		protected function updateState():void
		{
			var obj:Object = _skin[_state];
			this.bitmapData = BitmapDataCache.getBitmapData(obj.link);
			
			this.x = _skin.x + obj.x;
			this.y = _skin.y + obj.y;
			this.width = obj.width;
			this.height = obj.height;
			
			saveKeyAndIncreateReference(obj.link)
		}
		
		protected function saveKeyAndIncreateReference(key:String):void
		{
			if(_keyList.indexOf(key) == -1)
			{
				_keyList.push(key);
			}
			BitmapDataCache.increaseReference(key, this);
		}
		
		public function dispose():void
		{
			if(_keyList)
			{
				var key:String;
				while(_keyList.length > 0)
				{
					key = _keyList.shift();
					BitmapDataCache.decreaseReference(key, this);
				}
				_keyList = null;
			}
		}
	}
}