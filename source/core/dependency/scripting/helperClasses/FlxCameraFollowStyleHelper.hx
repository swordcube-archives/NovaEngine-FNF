package core.dependency.scripting.helperClasses;

class FlxCameraFollowStyleHelper {
	/**
	 * Camera has no deadzone, just tracks the focus object directly.
	 */
	public static var LOCKON = 0;

	/**
	 * Camera's deadzone is narrow but tall.
	 */
	public static var PLATFORMER = 1;

	/**
	 * Camera's deadzone is a medium-size square around the focus object.
	 */
	public static var TOPDOWN = 2;

	/**
	 * Camera's deadzone is a small square around the focus object.
	 */
	public static var TOPDOWN_TIGHT = 3;

	/**
	 * Camera will move screenwise.
	 */
	public static var SCREEN_BY_SCREEN = 4;

	/**
	 * Camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	public static var NO_DEAD_ZONE = 5;
}
