package;

#if desktop
import Discord.DiscordClient;
#end
import WeekData;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var jukeText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var curIcon:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var arrowGroup:FlxGroup;

	var bgScroll:FlxBackdrop;
	var record:FlxSprite;
	var jukebox:FlxSprite;
	var jukeboxBack:FlxSprite;
	var arrowL:FlxSprite;
	var arrowR:FlxSprite;

	var intendedColor:Int;
	var colorTween:FlxTween;
	var bgColorTween:FlxTween;

	override function create()
	{
		#if MODS_ALLOWED
		//Paths.destroyLoadedImages();
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("usin the jukebox", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if (initSonglist[i] != null && initSonglist[i].length > 0)
			{
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS
		bgScroll = new FlxBackdrop(Paths.image('freeplayBG'), 0, 0, true, true);
		add(bgScroll);

		jukeboxBack = new FlxSprite(-320, -180).loadGraphic(Paths.image('freeplay/backJukebox'));
		jukeboxBack.antialiasing = ClientPrefs.globalAntialiasing;
		jukeboxBack.setGraphicSize(FlxG.width, FlxG.height);
		add(jukeboxBack);

		record = new FlxSprite(FlxG.width * (1 / 3), FlxG.height * 0.42).loadGraphic(Paths.image('freeplayRecordS'));
		record.antialiasing = ClientPrefs.globalAntialiasing;
		add(record);

		jukebox = new FlxSprite(-320, -180).loadGraphic(Paths.image('freeplay/frontJukebox'));
		jukebox.antialiasing = ClientPrefs.globalAntialiasing;
		jukebox.setGraphicSize(FlxG.width, FlxG.height);
		add(jukebox);

		jukeText = new FlxText(FlxG.width * 0.2, FlxG.height * 0.79, 0, "TEST", 32);
		jukeText.setFormat(Paths.font("lcd.ttf"), 80, FlxColor.LIME, LEFT);
		add(jukeText);

		arrowL = new FlxSprite(jukeText.x - 90, FlxG.height * 0.77);
		arrowL.frames = Paths.getSparrowAtlas('freeplayArrow');
		arrowL.antialiasing = ClientPrefs.globalAntialiasing;
		arrowL.animation.addByPrefix('press', 'arrow0', 24, false);
		arrowL.setGraphicSize(45, 80);
		add(arrowL);

		arrowR = new FlxSprite(FlxG.width * 0.81, arrowL.y);
		arrowR.frames = Paths.getSparrowAtlas('freeplayArrow');
		arrowR.flipX = true;
		arrowR.antialiasing = ClientPrefs.globalAntialiasing;
		arrowR.animation.addByPrefix('press', 'arrow0', 24, false);
		arrowR.setGraphicSize(45, 80);
		add(arrowR);
			
		/*var icon:HealthIcon = new HealthIcon(songs[curIcon].songCharacter);
		icon.sprTracker = jukeText;
		add(icon);*/

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		record.color = songs[curSelected].color;
		bgScroll.color = songs[curSelected].color;
		intendedColor = record.color;
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState()
	{
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;

				if (songCharacters.length != 1)
					num++;
			}
	}*/

	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		if (record.angle >= 360)
			record.angle = 0;
		record.angle += 0.2;

		bgScroll.x += 0.3;
		bgScroll.y += 0.3;

		jukeText.text = songs[curSelected].songName.toUpperCase();

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (controls.UI_LEFT_P)
		{
			arrowL.animation.stop();
			arrowL.animation.play('press');
			changeSelection(-shiftMult);
		}
		if (controls.UI_RIGHT_P)
		{
			arrowR.animation.stop();
			arrowR.animation.play('press');
			changeSelection(shiftMult);
		}

		if (upP)
			changeDiff(-1);
		if (downP)
			changeDiff(1);

		if (controls.BACK)
		{
			if (colorTween != null)
			{
				bgColorTween.cancel();
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if (space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else
		#end if (accepted)
	{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if (!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop))
				&& !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop)))
			{
			#else
			if (!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop)))
			{
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
		}
			trace(poop);//poop means the songname then difficulty (e.g. blammed-hard)

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);//im assuming poop here means the json itself while songLowercase is the folder name.
			PlayState.isStoryMode = false;
			PlayState.isFreeplay = true;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if (colorTween != null)
			{
				bgColorTween.cancel();
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
	else if (controls.RESET)
	{
		openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length - 1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				bgColorTween.cancel();
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(record, 1, record.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
			bgColorTween = FlxTween.color(bgScroll, 1, bgScroll.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					bgColorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		/*for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
	}*/

		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
} class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
