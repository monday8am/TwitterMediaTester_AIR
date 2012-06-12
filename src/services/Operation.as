package services

{
    import flash.events.Event;
    import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
    

    /**
     * Abstract class representing an operation of some sort,
     * probably but not necessarily asynchronous.  Its execute() method
     * initiates it, after which its contract requires that it
     * dispatch either Event.COMPLETE or ErrorEvent.ERROR.
     * 
     */
    public class Operation extends EventDispatcher
    {
        /**
         * A name for this operation to be shown by the Controller to be shown
         * to indicate its progress or status.
         */
        public var displayName:String;
        
        /**
         * Initiate this Operation.  An event may be dispatched during
         * the execution of this function, or at any point afterwards.
         */
        public function execute():void
        {
        }

        /**
         * Subclasses may override to determine the disposition
         * of an error-related event.
         */
        protected function handleFault(e:Event ):void
        {
            if (e is ErrorEvent)
            {
				trace( "error!" ); 
                dispatchEvent(e);
            }
        }

        /**
         * Subclasses may override to determine disposition of a success event. 
         */
        protected function handleComplete(e:Object):void
        {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}