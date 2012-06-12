package services
{
    import flash.events.Event;


    /**
     * A do-nothing operation, useful in cases where some Operation
     * is expected by a caller but the callee has none to supply.
     */
    public class NullOperation extends Operation
    {
        override public function execute():void
        {
            dispatchEvent(new Event(Event.COMPLETE));
        }
   }
}