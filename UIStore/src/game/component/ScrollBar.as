package game.component
{
	/**
	 * @author LiuPeng
	 * 由track条的高度定义thumb的可拖拽范围，制作时PSD文件时需注意。
	 * arrowUp上边界和arrowDown下边界范围是滚动条目标对象的遮罩范围。
	 * 可伸缩的滚动条arrowUp，arrowDown按钮和track条之间不留间隙
	 */	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ScrollBar extends Container
	{
		public static const MODE_HIDE_THUMB:int = 0;
		public static const MODE_HIDE_BAR:int 	= 1;
		
		private var _mode:int;
		private var _stage:Stage;
		
		private var _arrowUp:Button;
		private var _arrowDown:Button;
		private var _thumb:Button;
		private var _thumbIcon:Image;
		private var _track:Container;
		private var _scrollStep:int = 5;
		
		private var _target:DisplayObject;
		private var _targetStartY:int;
		private var _maskWidth:Number;
		private var _maskHeight:Number;
		private var _mask:Shape;
		
		private var _dragRect:Rectangle;
		private var _isThumbDrag:Boolean;
		
		public function ScrollBar()
		{
			initialize();
		}
		
		private function initialize():void
		{
			_dragRect = new Rectangle();
			_scrollStep = 5;
			_mask = new Shape();
			_mode = MODE_HIDE_THUMB;
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function onAddToStage(evt:Event):void
		{
			_stage = this.stage;
		}
		
		private function onRemoveFromStage(evt:Event):void
		{
			if(_isThumbDrag == true)
			{
				endDrag();
			}
			_stage = null;
		}
		
		protected override function configChildren():void
		{
			_track = getChildByName("track") as Container;
			_arrowUp = getChildByName("arrowUp") as Button;
			_arrowDown = getChildByName("arrowDown") as Button;
			_thumb = getChildByName("thumb") as Button;
			_thumbIcon = getChildByName("thumbIcon") as Image;
			_thumb.visible = false;
			_thumb.y = _track.y;
			_maskHeight = (_arrowDown.y + _arrowDown.height) - _arrowUp.y;
		}
		
		private function addMouseEventListener():void
		{
			_arrowUp.addEventListener(MouseEvent.CLICK, onArrowClick);
			_arrowDown.addEventListener(MouseEvent.CLICK, onArrowClick);
			_track.addEventListener(MouseEvent.CLICK, onTrackClick);
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
			_thumb.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
			if(_target != null)
			{
				_target.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
			}
		}
		
		private function onMouseWheelHandler(e:MouseEvent):void
		{	
			if (e.delta > 0)
			{
				scrollOneStep(-_scrollStep);
			}
			else if (e.delta < 0)
			{
				scrollOneStep(_scrollStep);
			}
		}
		
		private function onArrowClick(evt:MouseEvent):void
		{
			switch(evt.target)
			{
				case _arrowUp:
					scrollOneStep(-_scrollStep);
					break;
				case _arrowDown:
					scrollOneStep(_scrollStep);
					break;
			}
		}
		
		private function scrollOneStep(step:int):void
		{
			var upBound:int = _track.y;
			var lowBound:int = _track.y + _track.height - _thumb.height;
			var targetY:int = _thumb.y + step;
			_thumb.y = Math.min(Math.max(targetY, upBound), lowBound);
			scrollTarget();
		}
		
		private function onTrackClick(evt:MouseEvent):void
		{
			var halfThumbHeight:int = _thumb.height >> 1;
			var localY:int = evt.localY;
			var thumbCenterY:int = Math.min(Math.max(localY, _track.y + halfThumbHeight), _track.y + _track.height - halfThumbHeight);
			_thumb.y = thumbCenterY - halfThumbHeight;
			scrollTarget();
		}
		
		private function onThumbMouseDown(evt:MouseEvent):void
		{
			beginDrag();
		}
		
		private function onThumbMouseUp(evt:MouseEvent):void
		{
			endDrag();
		}
		
		private function beginDrag():void
		{
			_thumb.startDrag(false, _dragRect);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			_isThumbDrag = true;
		}
		
		private function endDrag():void
		{
			_thumb.stopDrag();
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			_isThumbDrag = false;
		}
		
		private function onStageMouseMove(evt:MouseEvent):void
		{
			scrollTarget();
		}
		
		private function scrollTarget():void
		{
			if(_target.height <= _maskHeight)
			{
				_target.y = _targetStartY;
			}
			else
			{
				var ratio:Number = (_thumb.y - _dragRect.y) / _dragRect.height;
				_target.y = _targetStartY - (_target.height - _maskHeight) * ratio;
			}
			dispatchEvent(EVENT_CHANGE);
		}
		
		public function scrollToBottom():void
		{
			var lowBound:int = _track.y + _track.height - _thumb.height;
			_thumb.y = lowBound;
			scrollTarget();
		}
		
		public function scrollToHeight(height:int):void
		{
			var lowBound:Number = (_track.y + _track.height - _thumb.height)*height/_target.height;
			_thumb.y = lowBound;
			scrollTarget();
		}
		
		public function scroolToHeightII(height:int):void
		{
			var lowBound:Number = (_track.y + _track.height - _thumb.height)*height/(_target.height - this.height);
			if(height == 0)
			{
				lowBound = _track.y;
			}
			if(height >= _target.height - this.height)
			{
				lowBound = _track.y + _track.height - _thumb.height;
			}
			_thumb.y = lowBound;
			scrollTarget();
		}
		
		public function scrollToY(y:Number):void
		{
			_thumb.y = y;
			scrollTarget();
		}
		
		public function get scrollY():Number
		{
			return _thumb.y;
		}
		
		public function set target(value:DisplayObject):void
		{
			if(_target != null)
			{
				_target.y = _targetStartY;
			}
			_target = value;
			_targetStartY = _target.y;
			_mask.x = _target.x;
			_mask.y = _target.y;
			if(_target.parent != null)
			{
				_target.parent.addChild(_mask);
			}
			addMouseEventListener();
			update();
		}
		
		public function get target():DisplayObject
		{
			return _target;
		}
		
		public override function set height(value:Number):void
		{
			_track.height = value - _arrowUp.height - _arrowDown.height;
			_arrowDown.y = _track.y + _track.height;
			_maskHeight = value;
		}
		
		public function update():void
		{
			updateTargetPosition();
			updateMask();
			updateThumbHeight();
			updateThumbPosition();
		}
		
		private function updateTargetPosition():void
		{
			if(_target.height <= _maskHeight)
			{
				_target.y = _targetStartY;
			}
			else
			{
				if((_target.y + _target.height) < (_maskHeight + _targetStartY))
				{
					_target.y = _targetStartY + _maskHeight - _target.height ;
				}
			}
		}
		
		private function updateMask():void
		{
			_maskWidth = _target.width;
			updateMaskShape(_maskWidth, _maskHeight);
			_target.mask = _mask;
			_mask.x = _target.x;
			_mask.y = _targetStartY;
		}
		
		private function updateMaskShape(w:int, h:int):void
		{
			var g:Graphics = _mask.graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0, 0, w, h);
			g.endFill();
		}
		
		private function updateThumbHeight():void
		{
			var scrollableHeight:int = _track.height;
			var thumbHeight:int = 0;
			if(_target.height > _maskHeight)
			{
				thumbHeight = scrollableHeight * scrollableHeight / _target.height;
			}
			else
			{
				thumbHeight = scrollableHeight;
			}
			_thumb.height = thumbHeight;
			if(thumbHeight < scrollableHeight)
			{
				this.visible = true;
				_thumb.visible = true;
				//				_thumb.height = thumbHeight;
				//				updateDragRect();
				updateThumbIcon();
			}
			else
			{
				_thumb.visible = false;
				if(_mode == MODE_HIDE_BAR)
				{
					this.visible = false;
				}
			}
			updateDragRect();
		}
		
		private function updateThumbPosition():void
		{
			if(_thumb.visible == true)
			{
				var thumbRatio:Number = (_thumb.y - _dragRect.y) / _dragRect.height;
				var targetRatio:Number = (_targetStartY - _target.y) / (_target.height - _maskHeight);
				if(thumbRatio > targetRatio)
				{
					_thumb.y = _dragRect.y + _dragRect.height * targetRatio;
				}
			}
		}
		
		private function updateThumbIcon():void
		{
			if(_thumbIcon != null)
			{
				_thumbIcon.x = (_thumb.width - _thumbIcon.width) >> 1;
				_thumbIcon.y = (_thumb.height - _thumbIcon.height) >> 1;
				_thumb.addChild(_thumbIcon);
			}
		}
		
		private function updateDragRect():void
		{
			_dragRect.x = _thumb.x;
			_dragRect.y = _track.y;
			_dragRect.width = 0;
			_dragRect.height = _track.height - _thumb.height;
		}
		
		public function set mode(value:int):void
		{
			_mode = value;
		}
		
		public function get mode():int
		{
			return _mode;
		}
		
		private function removeAllEventListener():void
		{ 
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			if(_stage)
			{
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			}
			if(_arrowUp == null) return;
			_arrowUp.removeEventListener(MouseEvent.CLICK, onArrowClick);
			_arrowDown.removeEventListener(MouseEvent.CLICK, onArrowClick);
			
			_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
			_thumb.removeEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
			
			_track.removeEventListener(MouseEvent.CLICK, onTrackClick);
			_track.removeEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheelHandler);
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeAllEventListener()
			
			if(_mask)
			{
				_mask.graphics.clear();
				_mask = null;
			}
			if(_arrowUp)
			{
				_arrowUp.dispose();
				_arrowUp = null;
			}
			if(_arrowDown)
			{
				_arrowDown.dispose();
				_arrowDown = null;
			}
			if(_thumb)
			{
				_thumb.dispose();
				_thumb = null;
			}
			if(_thumbIcon)
			{
				_thumbIcon.dispose();
				_thumbIcon = null;
			}
			if(_track)
			{
				_track.dispose();
				_track = null;
			}
			_stage = null;
			_dragRect = null;
			_target = null;
		}
	}
}