package backend.scripting.lua;

class LuaUtil {
    public static inline final STRING_HELPER = "
	function string:split(string, delimiter)
		return StringHelper:split(string, delimiter)
	end

	function string:trim(string)
		return StringHelper:trim(string)
	end

	function string:startsWith(string, delimiter)
		return StringHelper:startsWith(string, delimiter)
	end

	function string:endsWith(string, delimiter)
		return StringHelper:endsWith(string, delimiter)
	end

	function string:contains(string, delimiter)
		return StringHelper:contains(string, delimiter)
	end

	function string:substr(string, pos, len)
		return StringHelper:substr(string, pos, len)
	end

	function string:substring(string, pos, len)
		return StringHelper:substring(string, pos, len)
	end

	function string:upper(string)
		return StringHelper:toUpperCase(string)
	end

    function string:lower(string)
		return StringHelper:toLowerCase(string)
	end

    function string:charAt(string, char)
		return StringHelper:charAt(string, char)
	end
	";
}
