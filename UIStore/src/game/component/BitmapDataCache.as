package game.component
{
	/**
	 * @author LiuPeng
	 * 生成并缓存九宫图片切片
	 * Grid表示源图片九宫切片定义的每个切片
	 * Slice表示目标图片中缩放后的每个切片
	 */	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import game.component.core.ISkinnable;

	public class BitmapDataCache
	{
		private static const SLICE_LIST_LENGTH:int 	= 9;
		private static const SPLIT_ROW_COUNT:int 	= 3;
		private static const SPLIT_COL_COUNT:int 	= 3;
		
		private static var _bitmapDataMap:Dictionary;  // key -> bitmapdata
		private static var _bitmapReferenceMap:Dictionary;  // key -> Vector.<ISkinable>
		
		//重用对象
		private static var _splitRow:Vector.<int>;
		private static var _splitCol:Vector.<int>;
		private static var _rect:Rectangle;
		private static var _dstPoint:Point;
		private static var _transformMatrix:Matrix;
		
		initialize();
		
		private static function initialize():void
		{
			_bitmapDataMap = new Dictionary();
			_bitmapReferenceMap = new Dictionary();
			 
			_splitRow = new Vector.<int>(SPLIT_ROW_COUNT + 1, true);
			_splitCol = new Vector.<int>(SPLIT_COL_COUNT + 1, true);
			_rect = new Rectangle();
			_dstPoint = new Point();
			_transformMatrix = new Matrix();
		}
		
		public static function getBitmapData(link:String):BitmapData
		{
			var result:BitmapData = _bitmapDataMap[link];
			if(result == null)
			{
				result = obtainBitmapDataInDomain(link);
				_bitmapDataMap[link] = result;
			}
			return result;
		}
		
		private static function obtainBitmapDataInDomain(link:String):BitmapData
		{
			var result:BitmapData = null;
			var domain:ApplicationDomain = Component.domain;
			if(domain == null)
			{
				throw new Error("尚未设置UI资源所放置的ApplicationDomain！");
			}
			if(domain.hasDefinition(link) == true)
			{
				var clz:Class = domain.getDefinition(link) as Class;
				result = new clz() as BitmapData;
			}
			else
			{
				if(Capabilities.isDebugger == true)
				{
					throw new Error("图片资源 " + link + "不存在!");
				}
			}
			return result;
		}
		
		public static function getScaleBitmapData(link:String, width:int, height:int, top:int, right:int, bottom:int, left:int):BitmapData
		{
			var result:BitmapData;
			var key:String = generateScaleBitmapDataKey(link, width, height);
			 
			result = _bitmapDataMap[key] as BitmapData;
			if(result == null)
			{
				result = createScaleBitmapData(link, width, height, top, right, bottom, left);
				_bitmapDataMap[key] = result;
			}
			
			return result;
		}
		
		private static function createScaleBitmapData(link:String, width:int, height:int, top:int, right:int, bottom:int, left:int):BitmapData
		{
			if(width < (left + right))
			{
				width = left + right;
			}
			if(height < (top + bottom))
			{
				height = top + bottom;
			}
			var result:BitmapData = new BitmapData(width, height, true, 0);
			var gridList:Vector.<BitmapData> = getBitmapDataGridList(link, top, right, bottom, left);
			updateSplitData(width, height, top, right, bottom, left);
			for(var i:int = 0; i < SPLIT_COL_COUNT; i++)
			{
				for(var j:int = 0; j < SPLIT_ROW_COUNT; j++)
				{
					var grid:BitmapData = gridList[i * 3 + j];
					_transformMatrix.a = (_splitRow[j + 1] - _splitRow[j]) / grid.width;
					_transformMatrix.b = 0;
					_transformMatrix.c = 0;
					_transformMatrix.d = (_splitCol[i + 1] - _splitCol[i]) / grid.height;
					_transformMatrix.tx = _splitRow[j];
					_transformMatrix.ty = _splitCol[i];
					//Matrix.setTo,Flash Player 11 API
					//_transformMatrix.setTo((_splitRow[j + 1] - _splitRow[j]) / grid.width, 0, 0, (_splitCol[i + 1] - _splitCol[i]) / grid.height, _splitRow[j], _splitCol[i]);
					result.draw(grid, _transformMatrix);
					
					disposeBitmapData(grid);
				}
			}
			
			return result;
		}
		
		private static function getBitmapDataGridList(link:String, top:int, right:int, bottom:int, left:int):Vector.<BitmapData>
		{
			var gridList:Vector.<BitmapData> = createBitmapDataGridList(link, top, right, bottom, left);
			return gridList;
		}
		
		private static function createBitmapDataGridList(link:String, top:int, right:int, bottom:int, left:int):Vector.<BitmapData>
		{
			var source:BitmapData = obtainBitmapDataInDomain(link);
			if((top + bottom) >= source.height || (left + right) >= source.width)
			{
				throw new Error("Bitmap scale9Grid setting error!");
			}
			var result:Vector.<BitmapData> = new Vector.<BitmapData>(SLICE_LIST_LENGTH, true);
			updateSplitData(source.width, source.height, top, right, bottom, left);
			for(var i:int = 0; i < SPLIT_COL_COUNT; i++)
			{
				for(var j:int = 0; j < SPLIT_ROW_COUNT; j++)
				{
					_rect.x = _splitRow[j];
					_rect.y = _splitCol[i];
					_rect.width = _splitRow[j + 1] - _splitRow[j];
					_rect.height = _splitCol[i + 1] - _splitCol[i];
					var bmpd:BitmapData = new BitmapData(_rect.width, _rect.height, true, 0);
					bmpd.copyPixels(source, _rect, _dstPoint);
					result[i * 3 + j] = bmpd;
				}
			}
			
			disposeBitmapData(source);
			return result;
		}
		
		private static function updateSplitData(width:int, height:int, top:int, right:int, bottom:int, left:int):void
		{
			_splitRow[0] = 0;
			_splitRow[1] = left;
			_splitRow[2] = width - right;
			_splitRow[3] = width;
			_splitCol[0] = 0;
			_splitCol[1] = top;
			_splitCol[2] = height - bottom;
			_splitCol[3] = height;
		}
		
		public static function generateScaleBitmapDataKey(link:String, width:int, height:int):String
		{
			return link + "_" + width + "_" + height;
		}
		
		private static function generateGridListKey(link:String, top:int, right:int, bottom:int, left:int):String
		{
			return link + "_" + top + "_"+ right + "_" + bottom + "_" + left;
		}
		
		private static function disposeBitmapData(bitmapData:BitmapData):void
		{
			if(bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		//仅用于预览模式
		public static function mergeBitmapDataMap(map:Dictionary):void
		{
			for(var key:String in map)
			{
				_bitmapDataMap[key] = map[key];
			}
		}

		// 增加引用
		public static function increaseReference(key:String, referencer:ISkinnable):void
		{
			var referenceList:Vector.<ISkinnable> = _bitmapReferenceMap[key];
			if(referenceList == null)
			{
				referenceList = new Vector.<ISkinnable>();
				_bitmapReferenceMap[key] = referenceList;
			}
			if( referenceList.indexOf(referencer) == -1)
			{
				referenceList.push(referencer);
			}
		}
		
		// 移除引用
		public static function decreaseReference(key:String, referencer:ISkinnable):void
		{
			var referenceList:Vector.<ISkinnable> = _bitmapReferenceMap[key];
			if(referenceList != null)
			{
				var index:int = referenceList.indexOf(referencer);
				referenceList.splice(index, 1);
				if(referenceList.length == 0)
				{
					var bitmapData:BitmapData = _bitmapDataMap[key];
					if(bitmapData != null)
					{
						bitmapData.dispose();
						_bitmapDataMap[key] = null;
						delete _bitmapDataMap[key];
					}
					referenceList = null;
					delete _bitmapReferenceMap[key];
				}
			}
		}
	}
}

