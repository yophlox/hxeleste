package game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
#if desktop
import flixel.input.gamepad.FlxGamepad;
#end
import backend.OldPaths;
import flixel.graphics.frames.FlxAtlasFrames;
import game.Chars;
import flixel.math.FlxPoint;

class Madeline extends Chars
{
	public static inline var SPEED:Float = 90;
	static inline var GRAVITY:Float = 900;
	static inline var JUMP_POWER:Float = 100;
	public var canMove:Bool = true;
	var jumping:Bool = false;
	var jumpTimer:Float = 0;
	var touch1_X:Float;
	var touch2_X:Float;
	#if desktop
	public var gamepad:FlxGamepad;
	#end
	// Dash variables
    var canDash:Bool = true;
    var dashCooldown:Float = 0.5;
    var dashTimer:Float = 0;
	public static inline var DASH_POWER:Float = 240;

	public function new(x:Float = 0, y:Float = 0, kinematic:Bool = false)
	{
		super(x, y);
		canMove = !kinematic;
		offset.set(2, 6);
		scale.set(0.05, 0.05);
		updateHitbox();

		if (canMove)
		{
			this.drag.x = SPEED * 10;
			this.acceleration.y = GRAVITY;
		}
	}

	override function setPosition(X:Float = 0, Y:Float = 0)
	{
		x = X + offset.x;
		y = Y + offset.y;
	}

    function dash()
    {
        if (canDash && FlxG.keys.justPressed.X)
        {
            canDash = false;
            dashTimer = 0;
            
            var dashDirection:FlxPoint = new FlxPoint();

            if (FlxG.keys.pressed.LEFT) dashDirection.x = -1;
            if (FlxG.keys.pressed.RIGHT) dashDirection.x = 1;
            if (FlxG.keys.pressed.UP) dashDirection.y = -1;
            if (FlxG.keys.pressed.DOWN) dashDirection.y = 1;

            // Manually normalize the dash direction to ensure consistent speed in diagonal dashes
            var magnitude:Float = Math.sqrt(dashDirection.x * dashDirection.x + dashDirection.y * dashDirection.y);
            if (magnitude != 0)
            {
                dashDirection.x /= magnitude;
                dashDirection.y /= magnitude;
            }

            velocity.x = dashDirection.x * DASH_POWER;
            velocity.y = dashDirection.y * DASH_POWER;
        }
    }

    function updateDashCooldown(elapsed:Float)
    {
        if (!canDash)
        {
            dashTimer += elapsed;
            if (dashTimer >= dashCooldown)
            {
                canDash = true;
            }
        }
    }

	function movement(elapsed:Float)
	{
		if (FlxG.keys.pressed.LEFT && !FlxG.keys.pressed.RIGHT)
		{
			velocity.x = -SPEED;
			facing = FlxObject.LEFT;
			scale.x = -0.05;
		}

		if (FlxG.keys.pressed.RIGHT && !FlxG.keys.pressed.LEFT)
		{
			velocity.x = SPEED;
			facing = FlxObject.RIGHT;
			scale.x = 0.05;
		}

		if (jumping && !FlxG.keys.pressed.Z)
			jumping = false;

		if (FlxG.keys.pressed.Z && jumpTimer == -1 && isTouching(FlxObject.DOWN))

		if (isTouching(FlxObject.DOWN) && !jumping)
			jumpTimer = 0;

		if (jumpTimer >= 0 && FlxG.keys.pressed.Z)
		{
			jumping = true;
			jumpTimer += elapsed;
		}
		else
			jumpTimer = -1;

		if (jumpTimer > 0 && jumpTimer < .25)
			velocity.y = -JUMP_POWER;

        dash();
        updateDashCooldown(elapsed);			
	}

	override function update(elapsed:Float)
	{
		if (canMove)
		{
			movement(elapsed);
		}

		super.update(elapsed);
	}
}
