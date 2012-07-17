package reflex.containers
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.IList;
	import mx.core.IStateClient;
	import mx.core.IStateClient2;
	
	import reflex.framework.IStateful;
	import reflex.injection.IReflexInjector;
	import reflex.invalidation.Invalidation;
	import reflex.invalidation.LifeCycle;
	import reflex.layouts.BasicLayout;
	
	
	//[Frame(factoryClass="reflex.tools.flashbuilder.ReflexApplicationLoader")]
	[SWF(widthPercent="100%", heightPercent="100%", frameRate="30")]
	[DefaultProperty("content")]
	/**
	 * @alpha
	 */
	public class Application extends Sprite implements IStateful
	{
		
		include "../framework/PropertyDispatcherImplementation.as";
		include "../framework/StatefulImplementation.as";
		
		public var injector:IReflexInjector;
		
		private var container:Group;
		public function get content():IList { return container ? container.content : null; }
		public function set content(value:*):void {
			if(container) {
				container.content = value;
				
			}
		}
		
		private var _backgroundColor:uint;
		[Bindable(event="backgroundColorChange")] // the compiler knows to look for this, so we don't really draw anything for it
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
			//notify("backgroundColor", _backgroundColor, _backgroundColor = value);
		}
		
		public var owner:Object = null;
		
		public function Application()
		{
			super();
			preinitialize();
		}
		
		protected function preinitialize():void {
			container = new Group();
			if (stage) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
			
		}
		
        protected function initialize(e:Event = null):void {
			// Application is the only Reflex thing not in a container
			
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			this.contextMenu = contextMenu;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			
			Invalidation.stage = this.stage;
			//var injector:IReflexInjector = new C(); // only instantiating in Application
			injector.injectInto(container);
			container.layout = new BasicLayout();
			stage.addChild(this);
			this.addChild(container.display as DisplayObject);
			onStageResize(null);
        }
		
		private function onStageResize(event:Event):void {
			container.width = stage.stageWidth;
			container.height = stage.stageHeight;
		}
		
		
	}
}