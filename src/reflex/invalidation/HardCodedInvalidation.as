package reflex.invalidation
{
	import flash.display.DisplayObject;

	public class HardCodedInvalidation implements IReflexInvalidation
	{
		
		Invalidation.registerPhase(LifeCycle.CREATE, 0, true);
		Invalidation.registerPhase(LifeCycle.INITIALIZE, 100, true);
		Invalidation.registerPhase(LifeCycle.INVALIDATE, 200, true);
		Invalidation.registerPhase(LifeCycle.MEASURE, 300, false);
		Invalidation.registerPhase(LifeCycle.LAYOUT, 400, true);
		
		public function HardCodedInvalidation()
		{
			
		}
		
		public function invalidate(instance:DisplayObject, phase:String):void
		{
			Invalidation.invalidate(instance, phase);
		}
		
	}
}