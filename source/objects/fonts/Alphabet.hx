package objects.fonts;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

@:dox(hide) @:enum abstract AlphabetFont(String) from String to String {
    var Bold = "Bold";
    var Default = "Default";
}

/**
 * A class for displaying text in a funky style.
 */
class Alphabet extends FlxTypedSpriteGroup<AlphabetChar> {
    public var font:AlphabetFont = Bold;
    public var size:Float = 1.0;
    /**
     * The text to display.
     */
    public var text(default, set):String;

    function set_text(v:String) {
        text = v;
        refreshText();
        return text = v;
    }

    /**
     * Controls if this text should lerp to the center of the screen or not.
     */
    public var isMenuItem:Bool = false;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

    public function new(x:Float, y:Float, font:AlphabetFont, text:String, size:Float = 1.0) {
        super(x, y);
        this.font = font;
        this.size = size;
        this.text = text;
    }

    override function update(elapsed:Float) {
        if (isMenuItem) {
            var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
            var lerpVal:Float = 0.1;
            y = MathUtil.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
            if(forceX != Math.NEGATIVE_INFINITY)
                x = forceX;
            else
                x = MathUtil.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
        }
        super.update(elapsed);
    }    

    /**
     * Removes the currently displaying text and displays new text.
     */
    public function refreshText() {
		var i:Int = members.length;
		while (i > 0) {
			--i;
			var letter:AlphabetChar = members[i];
			if(letter != null) {
				letter.kill();
				members.remove(letter);
				letter.destroy();
			}
		}
        clear();
        var splitChars:Array<String> = text.split("");
        var xPos:Float = 0.0;
        var yPos:Float = 0.0;

        for(char in splitChars) {
            if(!AlphabetChar.supportedChars.contains(char)) continue;

            var alphaChar:AlphabetChar = new AlphabetChar(xPos, yPos, font, char, size);
            alphaChar.color = color;
            if(char != "\n") add(alphaChar);

            if(char == "\n") {
                xPos = 0;
                yPos += 85;
            }
            if(char == " ") xPos += 30 * size;
            else xPos += alphaChar.width;
        }
    }
}

@:dox(hide)
class AlphabetChar extends FNFSprite {
    public static var supportedChars:Array<String> = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789[]←↓↑→-_~!@#$%^&*()?,.<>“”'\\/\n ".split("");

    public var char:String = "";
    public var font:AlphabetFont = Bold;
    public var size:Float = 1.0;

    public var useOutline:Bool = false;

    public function new(x:Float, y:Float, font:AlphabetFont, char:String, size:Float = 1.0) {
        super(x, y);

        this.font = font;
        this.char = char;
        loadFont();
    }

    override function draw() {
        if (font == Bold && !useOutline) {
            colorTransform.redMultiplier = color.redFloat;
            colorTransform.greenMultiplier = color.greenFloat;
            colorTransform.blueMultiplier = color.blueFloat;
            colorTransform.redOffset = 0;
            colorTransform.greenOffset = 0;
            colorTransform.blueOffset = 0;
        } else {
            colorTransform.redMultiplier = 0;
            colorTransform.greenMultiplier = 0;
            colorTransform.blueMultiplier = 0;
            colorTransform.redOffset = color.red;
            colorTransform.greenOffset = color.green;
            colorTransform.blueOffset = color.blue;
        }

        if (useOutline) {
            shader = new shaders.OutlineShader();
            var fr = frame.frame;
            cast(shader, shaders.OutlineShader).setClip(fr.x / pixels.width, fr.y / pixels.height, fr.width / pixels.width, fr.height / pixels.height);
            scale.set(size * 1.5, size * 1.5);
            updateHitbox();
            if(animation.curAnim != null && animOffsets.exists(animation.curAnim.name))
                offset.add(animOffsets[animation.curAnim.name].x, animOffsets[animation.curAnim.name].y);
            offset.add(15, 10);
        } else {
            shader = null;
        }

        super.draw();
    }

    public function convertChar(char:String) {
        switch(char) {
            case "😠" | "😡": return "-angry faic-";
            case "'": return "-apostraphie-";
            case "\\": return "-back slash-";
            case "/": return "-forward slash-";
            case "“": return "-start quote-";
            case "”": return "-end quote-";
            case "?": return "-question mark-";
            case "!": return "-exclamation point-";
            case ".": return "-period-";
            case ",": return "-comma-";
            case "-": return "-dash-";
            case "_": return "_";
            case "←": return "-left arrow-";
            case "↓": return "-down arrow-";
            case "↑": return "-up arrow-";
            case "→": return "-right arrow-";
        }
        return char;
    }

    public function loadFont() {
        switch(font) {
            case Bold:
                loadAtlas(Paths.getSparrowAtlas("UI/base/fonts/bold"));
                scale.set(1, 1);
                updateHitbox();
                var offsets:FlxPoint = new FlxPoint(0, 0);
                var anim:String = convertChar(char.toUpperCase());
                switch(char.toUpperCase()) {
                    case " ":
                        visible = false;
                        alpha = 0;
                    case ".": offsets.y += 42 * size;
                    case ",": offsets.y += 42 * size;
                    case "-": offsets.y += 14 * size;
                }
                addAnim("idle", anim+"0", 24, true, offsets);
                if(animation.exists("idle")) playAnim("idle");

                scale.set(size, size);
                updateHitbox();

                rotOffset.set(0, 0);
                offset.subtract(offsets.x, offsets.y); 

                if(!animation.exists("idle")) {
                    this.font = Default;
                    useOutline = true;
                    x += 10 * size;
                    loadFont();
                }

            case Default:
                loadAtlas(Paths.getSparrowAtlas("UI/base/fonts/default"));
                scale.set(1, 1);
                updateHitbox();
                var offsets:FlxPoint = new FlxPoint(0, 0);
                var anim:String = convertChar(char);
                switch(char) {
                    case " ":
                        visible = false;
                        alpha = 0;
                    case ".": offsets.y += 42 * size;
                    case ",": offsets.y += 42 * size;
                    case "-": offsets.y += 14 * size;
                    case "_": offsets.y += 34 * size;
                    case "←": offsets.y += 16 * size;
                    case "↓": offsets.y += 12 * size;
                    case "↑": offsets.y += 12 * size;
                    case "→": offsets.y += 16 * size;

                    // letter offsets
                    case "a": offsets.y += 15 * size;
                    case "b", "f": offsets.y += 3 * size;
                    case "c": offsets.y += 20 * size;
                    case "t", "h", "i", "j", "k", "l": offsets.y += 5 * size;
                    case "e", "g": offsets.y += 16 * size;
                    case "m", "n", "o", "p", "q", "r", "s", "u", "v", "w", "x", "y", "z": offsets.y += 20 * size;

                    // Symbol Offsets
                    case ":", ";", "*": offsets.y += 5 * size;
                }
                addAnim("idle", anim+"0", 24, true, offsets);
                if(animation.exists("idle")) playAnim("idle");

                scale.set(size, size);
                updateHitbox();

                rotOffset.set(0, 0);
                offset.subtract(offsets.x, offsets.y);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(char == " ") {
            visible = false;
            alpha = 0;
        }
    }
}