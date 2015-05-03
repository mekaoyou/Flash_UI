package game.component
{
	/**
	 * @author LiuPeng
	 */	
	
	public class Panel extends Container
	{
		
		public function Panel()
		{
			super();
		}
		
		public override function set skin(value:Object):void
		{
			super.skin = value;
		}
		
		public override function set name(value:String):void
		{
			
		}
		
		public override function get name():String
		{
			return this.skin.name;
		}
	}
}