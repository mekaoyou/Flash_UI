package game.component
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	[Event(name="change", type="flash.events.Event")]
	public class CountInputField extends Container
	{
		private var _countUpBtn:Button;
		private var _countDownBtn:Button;
		private var _countImg:ScaleImage;
		private var _countLabel:Label;
		
		private var _currentCount:int = 1;
		private var _maxCount:int;
		private var _minCount:int;
		
		public function CountInputField()
		{
			_minCount = 1;
			_maxCount = 999;
			super();
		}
		
		protected override function configChildren():void
		{
			_countUpBtn = getChildByName("up") as Button;
			_countDownBtn = getChildByName("down") as Button;
			_countImg = getChildByName("countBg") as ScaleImage;
			_countLabel = getChildByName("count") as Label;
			
			_countLabel.enabled = _countLabel.selectable = true;
			_countLabel.type = TextFieldType.INPUT;
			_countLabel.restrict = "0-9";
			_countLabel.width = _countImg.width - 2;
			//_countLabel.maxChars = 3;
			setCountLabelTxt(_currentCount);
			
			addChildEventListener();
		}
		
		private function addChildEventListener():void
		{
			_countUpBtn.addEventListener(MouseEvent.CLICK,countUpHandler);
			_countDownBtn.addEventListener(MouseEvent.CLICK,countDownHandler);
			_countLabel.addEventListener(MouseEvent.MOUSE_WHEEL,wheelHandler);
			_countLabel.addEventListener(Event.CHANGE,labelChangeHandler);
			_countLabel.addEventListener(FocusEvent.FOCUS_OUT,focusOuntHandler);	
		}
		
		private function removeChildEventListener():void
		{
			if(_countUpBtn == null) return; 
			_countUpBtn.removeEventListener(MouseEvent.CLICK,countUpHandler);
			_countDownBtn.removeEventListener(MouseEvent.CLICK,countDownHandler);
			_countLabel.removeEventListener(MouseEvent.MOUSE_WHEEL,wheelHandler);
			_countLabel.removeEventListener(Event.CHANGE,labelChangeHandler);
			_countLabel.removeEventListener(FocusEvent.FOCUS_OUT,focusOuntHandler);
		}
		
		private function countUpHandler(e:MouseEvent):void
		{
			_currentCount++;
			if(_currentCount > _maxCount)
			{
				_currentCount = _maxCount;
			}
			setCountLabelTxt(_currentCount);
		}
		
		private function countDownHandler(e:MouseEvent):void
		{
			_currentCount--;
			if(_currentCount < _minCount)
			{
				_currentCount = _minCount;
			}
			setCountLabelTxt(_currentCount);
		}
		
		private function wheelHandler(e:MouseEvent):void
		{
			if(e.delta > 0)
			{
				countUpHandler(null);
			}
			else
			{
				countDownHandler(null);
			}
		}
		
		private function labelChangeHandler(e:Event):void
		{
			if(_countLabel.text.charAt(0) == "")
			{
				_countLabel.text = "1";
				return;
			}
			if(0 == int( _countLabel.text.charAt(0)))
			{
				setCountLabelTxt(1);
				return;
			}
			if(int( _countLabel.text) > _maxCount)
			{
				setCountLabelTxt(_maxCount);
			}
		}
		
		private function focusOuntHandler(e:FocusEvent):void
		{
			if(_countLabel.text == "")
			{
				setCountLabelTxt(1);
			}
		}
		
		private function setCountLabelTxt(value:int):void
		{
			_currentCount = value;
			_countLabel.text = value.toString();
			dispatchEvent(Component.EVENT_CHANGE);
		}
		
		public function set maxChars(value:int):void
		{
			this._countLabel.maxChars = value;
		}
		
		public function set maxCount(max:int):void
		{
			this._maxCount = max;
		}
		
		public function set minCount(min:int):void
		{
			this._minCount = min;
		}
		
		public function get value():int
		{
			_currentCount = int( _countLabel.text);
			return _currentCount;
		}
		
		public function set value(value:int):void
		{
			this._currentCount = value;
			setCountLabelTxt(_currentCount);
		}
		
		public override function set enabled(value:Boolean):void
		{
			super.enabled = value;
			_countUpBtn.enabled = value;
			_countDownBtn.enabled = value;
			_countLabel.enabled = value;
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeChildEventListener();
			if(_countUpBtn)
			{
				_countUpBtn.dispose();
				_countUpBtn = null;
			}
			if(_countDownBtn)
			{
				_countDownBtn.dispose();
				_countDownBtn = null;
			}
			if(_countImg)
			{
				_countImg.dispose();
				_countImg = null;
			}
			if(_countLabel)
			{
				_countLabel.dispose();
				_countLabel = null;
			}
		}
	}
}