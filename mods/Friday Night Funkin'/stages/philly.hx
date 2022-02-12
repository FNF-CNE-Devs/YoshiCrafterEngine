var curLight:Int = 0;
var phillyTrain:FlxSprite = null;
var bg:FlxSprite = null;
var city:FlxSprite = null;
var street:FlxSprite = null;
var streetBehind:FlxSprite = null;
var trainSound:FlxSound = null;
var light:FlxSprite = null;
var phillyCityLights:Array<Int> = [
    0xFF31A2FD,
    0xFF31FD8C,
    0xFFFB33F5,
    0xFFFD4531,
    0xFFFBA633,
];

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;

var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var startedMoving:Bool = false;
var triggeredAlready:Bool = false;

function beatHit(curBeat) {
    if (curBeat % 4 == 0)
    {
        var c = phillyCityLights[FlxG.random.int(0, phillyCityLights.length - 1)];
        light.color = c;
        light.alpha = 1;
    }

    if (!trainMoving)
        trainCooldown += 1;

    if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
    {
        trainCooldown = FlxG.random.int(-4, 0);
        trainStart();
    }
}
function create()
{
    bg = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
    bg.scrollFactor.set(0.1, 0.1);
    PlayState.add(bg);
    global["bg"] = bg;

    city = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
    city.scrollFactor.set(0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    PlayState.add(city);
    global["city"] = city;

    light = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win'));
    light.scrollFactor.set(0.3, 0.3);
    light.setGraphicSize(Std.int(light.width * 0.85));
    light.updateHitbox();
    light.antialiasing = true;
    light.alpha = 0;
    global["light"] = light;
    PlayState.add(light);

    streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
    PlayState.add(streetBehind);
    global["streetBehind"] = streetBehind;

    phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
    PlayState.add(phillyTrain);
    global["phillyTrain"] = phillyTrain;

    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
    FlxG.sound.list.add(trainSound);
    // trainSound.play();

    // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0);

    street = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
    global["street"] = street;
    PlayState.add(street);
}

function update(elapsed) {
    if (trainMoving)
    {
        trainFrameTiming += elapsed;

        if (trainFrameTiming >= 1 / 24)
        {
            updateTrainPos();
            trainFrameTiming = 0;
        }
    }

    light.alpha = light.alpha - (elapsed /   (Conductor.crochet / 1000 * 4));

    // General duration of the song
    if (PlayState.curBeat < 250)
    {
        // Beats to skip or to stop GF from cheering
        if (PlayState.curBeat != 184 && PlayState.curBeat != 216)
        {
            if (PlayState.curBeat % 16 == 8)
            {
                // Just a garantee that it'll trigger just once
                if (!triggeredAlready)
                {
                    PlayState.gf.playAnim('cheer');
                    triggeredAlready = true;
                }
            }
            else
                triggeredAlready = false;
        }
    }
}

function trainStart()
{
    trace(trainSound);
    trainMoving = true;
    if (!trainSound.playing)
        trainSound.play(true);
}

function updateTrainPos()
{
    if (trainSound.time >= 4700)
    {
        startedMoving = true;
        PlayState.gf.playAnim('hairBlow');
    }

    if (startedMoving)
    {
        phillyTrain.x -= 400;

        if (phillyTrain.x < -2000 && !trainFinishing)
        {
            phillyTrain.x = -1150;
            trainCars -= 1;

            if (trainCars <= 0)
                trainFinishing = true;
        }

        if (phillyTrain.x < -4000 && trainFinishing)
            trainReset();
    }
}

function trainReset()
{
    PlayState.gf.playAnim('hairFall');
    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    // trainSound.stop();
    // trainSound.time = 0;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
}