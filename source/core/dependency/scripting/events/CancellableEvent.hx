package core.dependency.scripting.events;

class CancellableEvent {
    /**
     * Whether or not this event has been cancelled.
     */
    public var cancelled:Bool = false;

    public function new() {}

    /**
     * Cancels this event.
     */
    public function cancel() {
        cancelled = true;
    }
}