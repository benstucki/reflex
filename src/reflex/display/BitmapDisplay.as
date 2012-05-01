package reflex.display
{
	import flash.display.Bitmap;
	import flash.events.IEventDispatcher;
	
	import reflex.events.DataChangeEvent;
	import reflex.measurement.IMeasurable;
	import reflex.measurement.IMeasurablePercent;
	import reflex.measurement.IMeasurements;
	import reflex.measurement.Measurements;
	import reflex.styles.IStyleable;
	import reflex.styles.Style;
	import reflex.styles.parseStyles;
	
	/**
	 * Provides a styling and state management implementation
	 * 
	 * @alpha
	 */
	public class BitmapDisplay extends Bitmap implements IStyleable, IMeasurable, IMeasurablePercent
	{
		
		private var _id:String;
		private var _styleName:String;
		private var _style:Style;
		private var _explicit:IMeasurements;
		private var _measured:IMeasurements;
		
		private var _percentWidth:Number;
		private var _percentHeight:Number;
		
		protected var unscaledWidth:Number = 160;
		protected var unscaledHeight:Number = 22;
		
		
		public function BitmapDisplay() {
			super(null, "auto", true);
			_style = new Style();
			_explicit = new Measurements(this, NaN, NaN);
			_measured = new Measurements(this, 160, 22);
		}
		
		
		// IStyleable implementation
		
		[Bindable(event="idChange", noEvent)]
		public function get id():String { return _id; }
		public function set id(value:String):void {
			notify("id", _id, _id = value);
		}
		
		[Bindable(event="styleNameChange", noEvent)]
		public function get styleName():String { return _styleName;}
		public function set styleName(value:String):void {
			notify("styleName", _styleName, _styleName= value);
		}
		
		[Bindable(event="styleChange", noEvent)]
		public function get style():Style { return _style; }
		public function set style(value:*):void { // this needs expanding in the future
			if (value is String) {
				var token:String = value as String;
				
				// css specs dictate that this should fail silently
				// reflex.data.checkPropertyValueDelimiters(token);
				
				reflex.styles.parseStyles(_style, token);
			} else {
				throw new Error("BitmapDisplay.set style() does not currently accept a parameter of type: " + value);
			}
		}
		
		public function getStyle(property:String):* {
			return style[property];
		}
		
		public function setStyle(property:String, value:*):void {
			style[property] = value;
		}
		
		[Bindable(event="xChange", noEvent)]
		override public function set x(value:Number):void {
			notify("x", super.x, super.x = value);
		}
		
		[Bindable(event="yChange", noEvent)]
		override public function set y(value:Number):void {
			notify("y", super.y, super.y = value);
		}
		
		// IMeasurable implementation
		
		// these width/height setters need review in regards to scaling.
		// I think I would perfer following Flex's lead here.
		
		/**
		 * @inheritDoc
		 */
		[PercentProxy("percentWidth")]
		[Bindable(event="widthChange", noEvent)]
		override public function get width():Number { return unscaledWidth; }
		override public function set width(value:Number):void {
			unscaledWidth = _explicit.width = value; // this will dispatch for us if needed
		}
		
		/**
		 * @inheritDoc
		 */
		[PercentProxy("percentHeight")]
		[Bindable(event="heightChange", noEvent)]
		override public function get height():Number { return unscaledHeight; }
		override public function set height(value:Number):void {
			unscaledHeight  = _explicit.height = value; // this will dispatch for us if needed (order is important)
		}
		
		/**
		 * @inheritDoc
		 */
		//[Bindable(event="explicitChange", noEvent)]
		public function get explicit():IMeasurements { return _explicit; }
		/*public function set explicit(value:IMeasurements):void {
		if (value != null) { // must not be null
		DataChange.change(this, "explicit", _explicit, _explicit = value);
		}
		}*/
		
		/**
		 * @inheritDoc
		 */
		//[Bindable(event="measuredChange", noEvent)]
		public function get measured():IMeasurements { return _measured; }
		/*public function set measured(value:IMeasurements):void {
		if (value != null) { // must not be null
		DataChange.change(this, "measured", _measured, _measured = value);
		}
		}*/
		
		/**
		 * @inheritDoc
		 */
		[Bindable(event="percentWidthChange", noEvent)]
		public function get percentWidth():Number { return _percentWidth; }
		public function set percentWidth(value:Number):void {
			notify("percentWidth", _percentWidth, _percentWidth = value);
		}
		
		/**
		 * @inheritDoc
		 */
		[Bindable(event="percentHeightChange", noEvent)]
		public function get percentHeight():Number { return _percentHeight; }
		public function set percentHeight(value:Number):void {
			notify("percentHeight", _percentHeight, _percentHeight = value);
		}
		
		[Bindable(event="visibleChange")]
		override public function get visible():Boolean { return super.visible; }
		override public function set visible(value:Boolean):void {
			notify("visible", super.visible, super.visible = value);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setSize(width:Number, height:Number):void {
			if (unscaledWidth != width) { notify("width", unscaledWidth, unscaledWidth = width); }
			if (unscaledHeight != height) { notify("height", unscaledHeight, unscaledHeight = height); }
		}
		
		protected function notify(property:String, oldValue:*, newValue:*):void {
			var force:Boolean = false;
			var instance:IEventDispatcher = this;
			if(oldValue != newValue || force) {
				var eventType:String = property + "Change";
				if(instance is IEventDispatcher && (instance as IEventDispatcher).hasEventListener(eventType)) {
					var event:DataChangeEvent = new DataChangeEvent(eventType, oldValue, newValue);
					(instance as IEventDispatcher).dispatchEvent(event);
				}
			}
		}
		
	}
}