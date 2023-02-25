package backend.scripting.events;

class InputSystemEvent extends CancellableEvent {
    /**
     * The note direction pressed/released.
     * Ranges from 0 to 3.
     */
    public var direction:Int;

    public function new(direction:Int) {
        super();
        this.direction = direction;
    }
}