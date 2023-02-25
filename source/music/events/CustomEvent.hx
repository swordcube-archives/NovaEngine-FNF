package music.events;

class CustomEvent extends SongEvent {
    public function new(name:String, parameters:Array<Dynamic>) {
        super(name);
        this.parameters = parameters;
    }
}