import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxG;

typedef Mod = {
    var folderName:String;
    var card:ModCard;
}

class ModMenuState extends MusicBeatState {
    public var cards:Array<Mod> = [];
    public var selectedIndex:Int = 0;
    public override function new() {
        super();
        var bg = CoolUtil.addBG(this);
        bg.scrollFactor.set(0, 0);

        for (k=>m in ModSupport.modConfig) {
            var card = new ModCard(k, m);
            card.y = 250 * cards.length;
            cards.push({
                folderName: k,
                card: card
            });
            add(card);
        }

        var fancyHUDTopBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 100, 0x88000000);
        fancyHUDTopBar.scrollFactor.set(0, 0);
        add(fancyHUDTopBar);
        
    }

    public override function update(elapsed) {
        super.update(elapsed);

        FlxG.camera.scroll.set(
            FlxMath.lerp(FlxG.camera.scroll.x, cards[selectedIndex].card.x + (cards[selectedIndex].card.width / 2) - (FlxG.width / 2), 0.30 * 30 * elapsed),
            FlxMath.lerp(FlxG.camera.scroll.y, cards[selectedIndex].card.y + (cards[selectedIndex].card.height / 2) - (FlxG.height / 2), 0.30 * 30 * elapsed));

        for (k=>c in cards) {
            if (k == selectedIndex) {
                // c.card.scale.set(FlxMath.lerp(c.card.scale.x, 1, 0.25 * elapsed), FlxMath.lerp(c.card.scale.y, 1, 0.25 * elapsed));
                c.card.alpha = FlxMath.lerp(c.card.alpha, 1, 0.30 * 30 * elapsed);
                c.card.active = false;
            } else {
                // c.card.scale.set(FlxMath.lerp(c.card.scale.x, 0.5, 0.25 * elapsed), FlxMath.lerp(c.card.scale.y, 0.5, 0.25 * elapsed));
                c.card.alpha = FlxMath.lerp(c.card.alpha, 0.35, 0.30 * 30 * elapsed);
                c.card.active = true;
            }
        }
        if (controls.UP_P) {
            changeSelection(-1);
        }
        if (controls.DOWN_P) {
            changeSelection(1);
        }
        if (controls.BACK) {
            FlxG.switchState(new MainMenuState());
        }
    }

    function changeSelection(v:Int) {
        selectedIndex += v;
        if (selectedIndex < 0) {
            selectedIndex = cards.length - 1;
        } else if (selectedIndex >= cards.length) {
            selectedIndex = 0;
        }
        CoolUtil.playMenuSFX(0);
    }
}