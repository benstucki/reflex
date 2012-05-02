﻿package reflex.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import reflex.behaviors.IBehavior;
	import reflex.behaviors.IBehavioral;
	import reflex.collections.SimpleCollection;
	import reflex.display.Display;
	import reflex.injection.HardCodedInjector;
	import reflex.injection.IReflexInjector;
	import reflex.invalidation.IReflexInvalidation;
	import reflex.invalidation.LifeCycle;
	import reflex.measurement.resolveHeight;
	import reflex.measurement.resolveWidth;
	import reflex.measurement.setSize;
	import reflex.metadata.resolveCommitProperties;
	import reflex.skins.ISkin;
	import reflex.skins.ISkinnable;
	import reflex.templating.addItem;
	
	[Style(name="left")]
	[Style(name="right")]
	[Style(name="top")]
	[Style(name="bottom")]
	[Style(name="horizontalCenter")]
	[Style(name="verticalCenter")]
	[Style(name="dock")]
	[Style(name="align")]
	
	/**
	 * @alpha
	 */
	public class Component extends Display implements IBehavioral, ISkinnable
	{
		
		//static public const MEASURE:String = "measure";
		//Invalidation.registerPhase(MEASURE, 200, false);
		
		private var _skin:Object;
		private var _behaviors:SimpleCollection;
		
		private var _states:Array;
		private var _currentState:String;
		
		private var _enabled:Boolean = true;
		
		private var _injector:IReflexInjector;// = new HardCodedInjector();
		
		public function get injector():IReflexInjector { return _injector; }
		public function set injector(value:IReflexInjector):void {
			_injector = value;
			if(_injector && _skin) {
				_injector.injectInto(_skin);
			}
		}
		
		public function Component()
		{
			super();
			_behaviors = new SimpleCollection();
			_behaviors.addEventListener(CollectionEvent.COLLECTION_CHANGE, behaviorsCollectionChangeHandler, false, 0, true);
			reflex.metadata.resolveCommitProperties(this);
			addEventListener(LifeCycle.MEASURE, onMeasure, false, 0, true);
		}
		
		[Bindable]
		public var owner:Object; // Reflex Container
		
		[ArrayElementType("reflex.behaviors.IBehavior")]
		[Bindable(event="behaviorsChange")]
		[Inspectable(name="Behaviors", type=Array)]
		/**
		 * A collection of behavior objects.
		 * 
		 * To set behaviors in MXML:
		 * &lt;Component...&gt;
		 *   &lt;behaviors&gt;
		 *     &lt;SelectBehavior/&gt;
		 *     &lt;ButtonBehavior/&gt;
		 *   &lt;/behaviors&gt;
		 * &lt;/Component&gt;
		 */
		public function get behaviors():IList { return _behaviors; }
		public function set behaviors(value:*):void
		{
			if (value is Array) {
				var valueArray:Array = value as Array;
				var length:int = valueArray.length;
				for(var i:int = 0; i < length; i++) {
					var behavior:IBehavior = valueArray[i];
					_behaviors.addItem(behavior);
				}
				//_behaviors.source = value;
			} else if (value is IBehavior) {
				_behaviors.addItem(value);
				//_behaviors.source = [value];
			}
			dispatchEvent(new Event("behaviorsChange"));
		}
		
		[Bindable(event="skinChange")]
		[Inspectable(name="Skin", type=Class)]
		public function get skin():Object { return _skin; }
		public function set skin(value:Object):void
		{
			if (_skin == value) {
				return;
			}
			
			graphics.clear();
			
			if (_skin is ISkin) {
				(_skin as ISkin).target = null;
			}
			var oldSkin:Object = _skin;
			_skin = value;
			
			if (_skin is ISkin) {
				(_skin as ISkin).target = this;
			}
			if(injector) {
				injector.injectInto(_skin);
			}
			/*
			if (_skin is DisplayObject) {
				reflex.templating.addItem(this, _skin);
			}
			*/
			//skin.addEventListener("widthChange", item_measureHandler, false, true);
			invalidate(LifeCycle.MEASURE);
			//invalidate(LifeCycle.LAYOUT);
			dispatchEvent(new Event("skinChange"));
		}
		
		// temporary?
		/*
		private function item_measureHandler(event:Event):void {
			//var child:IEventDispatcher = event.currentTarget;
			Invalidation.invalidate(this, MEASURE);
			//Invalidation.invalidate(this, LAYOUT);
		}
		*/
		[Bindable(event="enabledChange")]
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			mouseEnabled = mouseChildren = value;
			notify("enabled", _enabled, _enabled = value);
		}
		
		[Bindable(event="currentStateChange")]
		public function get currentState():String { return _currentState; }
		public function set currentState(value:String):void
		{
			notify("currentState", _currentState, _currentState = value);
		}
		
		private function behaviorsCollectionChangeHandler(event:CollectionEvent):void {
			switch(event.kind) {
				case CollectionEventKind.ADD:
					for each(var item:IBehavior in event.items) {
						item.target = this;
					}
					break;
				
			}
		}
		
		// needs more thought
		
		override public function set width(value:Number):void {
			super.width = value;
			//reflex.measurement.setSize(skin, value, height);
			skin.width = value;
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			//reflex.measurement.setSize(skin, width, value);
			skin.height = value;
		}
		
		override public function setSize(width:Number, height:Number):void {
			super.setSize(width, height);
			reflex.measurement.setSize(skin, width, height);
		}
		
		private function onMeasure(event:Event):void {
			if(skin) {
				if (isNaN(explicit.width)) {
					var w:Number = reflex.measurement.resolveWidth(skin);
					measured.width = w; // explicit width of skin becomes measured width of component
				}
				if(isNaN(explicit.height)) {
					var h:Number = reflex.measurement.resolveHeight(skin);
					measured.height = h; // explicit height of skin becomes measured height of component
				}
			}
		}
		
	}
}
