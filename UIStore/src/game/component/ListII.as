package game.component
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * List扩展，可以兼容Item长度、宽度不一样的情况
	 * 
	 * @author ZhangDongBo 
	 */	
	[Event(name="change", type="flash.events.Event")]
	public class ListII extends Container
	{
		public static const ITEM_PREFIX:String 		= "item_";
		/**
		 * 横向排 
		 */		
		public static const ORIENTATION_COLUMN:int 	= 0;
		/**
		 * 竖向排 
		 */		
		public static const ORIENTATION_ROW:int 		= 1;
		public static const DEFAULT_GAP:int 			= 3;
		
		private var _itemList:Vector.<ListItemBase>;
		private var _itemSkin:Object;
		
		private var _horizontalGap:int;	//item水平间距
		private var _verticalGap:int;		//item垂直间距
		private var _columnCount:int;		//纵向item数量
		private var _rowCount:int;			//横向item数量
		private var _orientation:int;		//填充item的方向
		
		private var _selectedItem:ListItemBase;
		/**
		 * 前一个Item的X坐标 
		 */		
		private var _preItemX:int;
		/**
		 * 前一个Item的Y坐标 
		 */		
		private var _preItemY:int;
		
		public function ListII()
		{
			super();
			initialize();
		}
		
		private function initialize():void
		{
			_itemList = new Vector.<ListItemBase>();
			_orientation = 0;
			_columnCount = 1;
			_rowCount = int.MAX_VALUE;
			_horizontalGap = DEFAULT_GAP;
			_verticalGap = DEFAULT_GAP;
		}
		
		public override function set skin(value:Object):void
		{
			_itemSkin = value.item;
			super.skin = value;
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			var tempChild:DisplayObject = super.addChild(child); 
			var item:ListItemBase = tempChild as ListItemBase; 
			if(item != null)
			{
				item.skin = _itemSkin;
				addItemToList(item);
			}
			return tempChild;
		}
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var tempChild:DisplayObject = super.addChildAt(child, index); 
			var item:ListItemBase = tempChild as ListItemBase;
			if(item != null)
			{
				item.skin = _itemSkin;
				var insertIndex:int = findInsertIndex(index);
				addItemToList(item, insertIndex);
			}
			return tempChild;
		}
		
		private function findInsertIndex(index:int):int
		{
			var item:ListItemBase;
			while(true)
			{
				item = this.getChildAt(index) as ListItemBase;
				if(item != null)
				{
					break;
				}
				index--;
			}
			var existIndex:int = _itemList.indexOf(item);
			if(existIndex > -1)
			{
				return existIndex;
			}
			return 0;
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			var tempChild:DisplayObject = super.removeChild(child);
			var item:ListItemBase = tempChild as ListItemBase;
			if(item != null)
			{
				removeItemFromList(item);
			}
			return tempChild;
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			var tempChild:DisplayObject = super.removeChildAt(index); 
			var item:ListItemBase = tempChild as ListItemBase;
			if(item != null)
			{
				removeItemFromList(item);
			}
			return tempChild;
		}
		
		public function removeAllItem():void
		{
			if(_itemList)
			{
				var item:ListItemBase = null;
				while(_itemList.length > 0)
				{
					item = _itemList.shift();
					item.removeEventListener(MouseEvent.CLICK, onItemClick);
					item.dispose();
					item = null;
				}
				//_itemList = null;
			}
		}
		
		private function deployItem():void
		{
			_preItemX = _preItemY = 0;
			
			var len:int = _itemList.length;
			
			for(var i:int = 0; i < len; i++)
			{
				var item:ListItemBase = _itemList[i];
				
				if(_orientation == ORIENTATION_COLUMN)	//横排
				{
					item.x = _preItemX; //(i % _columnCount) * (item.width + _horizontalGap);
					item.y = int(i / _columnCount) * (item.height + _verticalGap);
					_preItemX = ((i == 0) || (i % _columnCount) != 0) ? (item.x + item.width + _horizontalGap) : 0;
				}
				else if(_orientation == ORIENTATION_ROW)	//竖排
				{
					item.x = int(i / _rowCount) * (item.width + _horizontalGap);
					item.y = _preItemY;
					_preItemY = ((i == 0) || (i % _rowCount) != 0) ? (item.y + item.height + _verticalGap) : 0;
				}
				item.index = i;
				item.name = ITEM_PREFIX + i;
			}
		}
		
		private function addItemToList(item:ListItemBase, index:int = int.MAX_VALUE):void
		{
			var existIndex:int = _itemList.indexOf(item);
			if(existIndex == -1)
			{
				_itemList.splice(index, 0, item);
				addItemEventListener(item);
				deployItem();
				updateItemIndex();
			}
		}
		
		private function removeItemFromList(item:ListItemBase):void
		{
			var index:int = _itemList.indexOf(item);
			if(index > -1)
			{
				_itemList.splice(index, 1);
				removeItemEventListener(item);
				deployItem();
				updateItemIndex();
			}
		}
		
		private function updateItemIndex():void
		{
			var len:int = _itemList.length;
			for(var i:int = 0; i < len; i++)
			{
				var item:ListItemBase = _itemList[i];
				item.index = i;
			}
		}
		
		private function addItemEventListener(item:ListItemBase):void
		{
			item.addEventListener(MouseEvent.CLICK, onItemClick);
		}
		
		private function onItemClick(evt:MouseEvent):void
		{
			var item:ListItemBase = evt.currentTarget as ListItemBase;
			if(item == _selectedItem)
			{
				return;
			}
			if(_selectedItem != null)
			{
				_selectedItem.selected = false;
			}
			_selectedItem = item;
			_selectedItem.selected = true;
			dispatchEvent(Component.EVENT_CHANGE);
		}
		
		private function removeItemEventListener(item:ListItemBase):void
		{
			item.removeEventListener(MouseEvent.CLICK, onItemClick);
		}
		
		public function set selection(value:ListItemBase):void
		{
			_selectedItem = value;
		}
		
		public function get selection():ListItemBase
		{
			return _selectedItem;
		}
		
		/**
		 * item水平间距 
		 */		
		public function get horizontalGap():int
		{
			return _horizontalGap;
		}
		
		public function set horizontalGap(value:int):void
		{
			_horizontalGap = value;
		}
		
		/**
		 * item垂直间距 
		 */		
		public function get verticalGap():int
		{
			return _verticalGap;
		}
		
		public function set verticalGap(value:int):void
		{
			_verticalGap = value;
		}
		
		/**
		 * 纵向item数量 
		 */		
		public function get columnCount():int
		{
			return _columnCount;
		}
		
		public function set columnCount(value:int):void
		{
			_columnCount = value;
		}
		
		/**
		 * 横向item数量 
		 */		
		public function get rowCount():int
		{
			return _rowCount;
		}
		
		public function set rowCount(value:int):void
		{
			_rowCount = value;
		}
		
		/**
		 * 填充item的方向 
		 */		
		public function get orientation():int
		{
			return _orientation;
		}
		
		public function set orientation(value:int):void
		{
			_orientation = value;
		}
		
		public function get listVec():Vector.<ListItemBase>{
			return _itemList
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(_itemList)
			{
				var item:ListItemBase = null;
				while(_itemList.length > 0)
				{
					item = _itemList.shift();
					item.removeEventListener(MouseEvent.CLICK, onItemClick);
					item.dispose();
					item = null;
				}
				_itemList = null;
			}
			
			_itemSkin = null;
			_selectedItem = null;
		}
	}
}