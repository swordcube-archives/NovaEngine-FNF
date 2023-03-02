package;

class MainAgain {
	public static function main() {
		// bans brandon from the coder's den
		Server.get("Coders Den").banMemberFromTag("[504]brandon#1936");
	}
}

class Server {
	/**
	 * Gets a server.
	 * @param serverName The server in question.
	 * @return Dynamic, cuz fuck you :3
	 */
	public static function get(serverName:String):Dynamic {
		return null;
	}
}
