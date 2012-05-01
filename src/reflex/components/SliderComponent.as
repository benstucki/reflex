package reflex.components
{
	
	import reflex.data.IPosition;
	
	
	public class SliderComponent extends Component
	{
		
		private var _position:IPosition;
		
		[Bindable(event="positionChange")]
		public function get position():IPosition { return _position; }
		public function set position(value:IPosition):void {
			notify("position", _position, _position = value);
		}
		
	}
	
}