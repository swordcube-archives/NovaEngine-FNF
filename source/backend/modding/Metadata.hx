package backend.modding;

typedef Contributor = {
    var name:String;
    var role:String;
}

typedef Metadata = {
    var name:String;
    @:optional var description:String;
    var contributors:Array<Contributor>;

    var api_version:String;
    var mod_version:String;
}