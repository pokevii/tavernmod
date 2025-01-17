package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;
	
	private var isCredits:Bool = true; 
	private var isNote:Bool = false;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		['Vs. Tavern Team'],
		['Saki',				'saki',			'Lead Programmer and Charter',					'https://twitter.com/VsTheTavern',				0xFFC4C4C4],
		['Luggi',				'luggi',		'Lead Musician, Coder, Background & Key Art Artist','https://twitter.com/LuigiGoesHard69',		0xFFC4C4C4],
		['Jayce',				'jayce',		'Lead Musician',				'https://www.youtube.com/channel/UCKpBWqM_jiXJyum5YcsWlyg',		0xFFC4C4C4],
		['Adz', 				'adz',			'Character Animator/Artist, Background & Panel Arist',		'https://twitter.com/AdzDuffRain',	0xFFC4C4C4],
		['DeadFromHeaven',		'dead',			'Week 3 Artist & Musician',							'https://www.youtube.com/@DeadFromHeaven',		0xFFC4C4C4],
		['Sleepycap',			'zoey',			'Week 4 Musician',		'https://pbs.twimg.com/media/FA4Jy8YXMAMfeQj?format=png&name=small',	0xFFC4C4C4],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	0xFFC4C4C4],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		0xFFC4C4C4],
		[''],
		['Engine Contributors'],
		['shubs',				'shubs',			'New Input System Programmer',						'https://twitter.com/yoshubs',			0xFFC4C4C4],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',	0xFFC4C4C4],
		['gedehari',			'gedehari',			'Chart Editor\'s Sound Waveform base',				'https://twitter.com/gedehari',			0xFFC4C4C4],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			0xFFC4C4C4],
		['SandPlanet',			'sandplanet',		'Mascot\'s Owner\nMain Supporter of the Engine',		'https://twitter.com/SandPlanetNG',	0xFFC4C4C4],
		['bubba',				'bubba',		'Guest Composer for "Hot Dilf"',	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw',	0xFFC4C4C4],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFC4C4C4],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFC4C4C4],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFFC4C4C4],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFFC4C4C4]
	];

	var note:String; //which note was clickedon

	//bg is irrelevant but removing it will break some of the colour tween code
	var bg:FlxSprite;

	var creditsGrp:FlxTypedSpriteGroup<FlxSprite>;

	var freshHover:FlxSprite;
	var madmanHover:FlxSprite;
	var letsPubHover:FlxSprite;
	var timRainHover:FlxSprite;

	var creditsFrame:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var spong:Int;
	var colorTween:FlxTween;
	var bgTween:FlxTween;
	var bgFrameTween:FlxTween;

	var up:Bool;
	var down:Bool;
	var position:Int;
	
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		spong = FlxG.random.int(1, 99);
		trace(spong);

		position = 0;

		creditsGrp = new FlxTypedSpriteGroup(0, 0, 20);

		bg = new FlxSprite().loadGraphic(Paths.image('creditsBg'));

		creditsFrame = new FlxSprite(0, 0).loadGraphic(Paths.image('creditsFrame'));
		creditsFrame.antialiasing = ClientPrefs.globalAntialiasing;

		freshHover = new FlxSprite(1067, 388).loadGraphic(Paths.image('freshHover'));
		freshHover.antialiasing = ClientPrefs.globalAntialiasing;

		madmanHover = new FlxSprite(319, 3777).loadGraphic(Paths.image('madmanHover'));
		madmanHover.antialiasing = ClientPrefs.globalAntialiasing;

		letsPubHover = new FlxSprite(613, 499).loadGraphic(Paths.image('letsPubHover'));
		letsPubHover.antialiasing = ClientPrefs.globalAntialiasing;

		timRainHover = new FlxSprite(440, 1115).loadGraphic(Paths.image('timRainHover'));
		timRainHover.antialiasing = ClientPrefs.globalAntialiasing;

		freshHover.alpha = 0;
		madmanHover.alpha = 0;
		letsPubHover.alpha = 0;
		timRainHover.alpha = 0;

		creditsGrp.add(creditsFrame);
		creditsGrp.add(letsPubHover);
		creditsGrp.add(freshHover);
		creditsGrp.add(madmanHover);
		creditsGrp.add(timRainHover);

		add(creditsGrp);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false, 'whiteAlphabet');
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		FlxG.mouse.visible = true;

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);


		//doesnt matter but idk what will happen if i remove this LOL
		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			up = true;
			down = false;
			//bgNonHover.y += 210;
			// freshHover.y += 210;
			// madmanHover.y += 210;
			// letsPubHover.y += 210;
			// timRainHover.y += 210;
			//creditsFrame.y += 210;
			tweenTest(up, down);
			up = false;
			down = true;
			changeSelection(-1);
		}
		if (downP)
		{
			up = false;
			down = true;
			//bgNonHover.y -= 210;
			// freshHover.y -= 210;
			// madmanHover.y -= 210;
			// letsPubHover.y -= 210;
			// timRainHover.y -= 210;
			//creditsFrame.y -= 210;
			tweenTest(up, down);
			up = true;
			down = false;
			changeSelection(1);
		}
		
		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		
		//remember to add boolean to use in mouse click
		if (FlxG.mouse.overlaps(freshHover)) {
			freshHover.alpha = 1;
			note = "fresh";
			if (FlxG.mouse.pressed && isNote == false) {
				isNote = true;
				openSubState(new StickyNoteSubState(note, spong));
				FlxG.sound.play(Paths.sound('stickyNote'), 1);
				if (spong == 8) {
					FlxG.sound.play(Paths.sound('vine'), 0.7);
				}
			}
		} else {
			isNote = false;
			freshHover.alpha = 0;
		}
		if (FlxG.mouse.overlaps(madmanHover)) {
			madmanHover.alpha = 1;
			note = "madMan";
			if (FlxG.mouse.pressed && isNote == false) {
				openSubState(new StickyNoteSubState(note, spong));
				FlxG.sound.play(Paths.sound('stickyNote'), 1);
				if (spong == 4) {
					FlxG.sound.play(Paths.sound('vine'), 0.7);
				}
				isNote = true;
			}
		} else {
			madmanHover.alpha = 0;
			isNote = false;
		}
		if (FlxG.mouse.overlaps(letsPubHover)) {
			letsPubHover.alpha = 1;
			note = "letsPub";
			if (FlxG.mouse.pressed && isNote == false) {
				openSubState(new StickyNoteSubState(note, spong));
				FlxG.sound.play(Paths.sound('stickyNote'), 1);
				if (spong == 3) {
					FlxG.sound.play(Paths.sound('vine'), 0.7);
				}
				isNote = true;
			}
		} else {
			letsPubHover.alpha = 0;
			isNote = false;
		}
		if (FlxG.mouse.overlaps(timRainHover)) {
			timRainHover.alpha = 1;
			note = "timRain";
			if (FlxG.mouse.pressed && isNote == false) {
				openSubState(new StickyNoteSubState(note, spong));
				FlxG.sound.play(Paths.sound('stickyNote'), 1);
				if (spong == 1) {
					FlxG.sound.play(Paths.sound('vine'), 0.7);
				}
				isNote = true;
			}
		} else {
			timRainHover.alpha = 0;
			isNote = false;
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0) {
				curSelected = creditsStuff.length - 1;
				//bgNonHover.y = 0;
				// freshHover.y = -3182;
				// letsPubHover.y = -3071;
				// timRainHover.y = -2455;
				// madmanHover.y = 207;
				//creditsFrame.y = 0;

				position = -3570;
				bgFrameTween = FlxTween.tween(creditsGrp, { x: 0, y: -3570 }, 1);
				}
			if (curSelected >= creditsStuff.length) {
				curSelected = 0;
				//bgNonHover.y = 3600;
				// freshHover.y = 388;
				// letsPubHover.y = 499;
				// timRainHover.y = 1115;
				// madmanHover.y = 3777;
				//creditsFrame.y = 3570;

				position = 0;
				bgFrameTween = FlxTween.tween(creditsGrp, { x: 0, y: 0 }, 1);
				}
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}

	function tweenTest(up:Bool, down:Bool) {
		if(bgFrameTween != null){
			if(bgFrameTween.finished == false){
				bgFrameTween.cancel();
			}
		}

		if (up && !down) { // up
			bgFrameTween = FlxTween.tween(creditsGrp, { x:0, y: position += 210 }, 1);
		} 
		
		if (!up && down) { // down
			bgFrameTween = FlxTween.tween(creditsGrp, { x:0, y: position -= 210 }, 1);
		}
	}
}