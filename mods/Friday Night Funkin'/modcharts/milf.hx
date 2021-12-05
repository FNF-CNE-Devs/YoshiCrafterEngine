function getCameraZoom(curBeat) {
    var hud = 0;
    var game = 0;
    if (curBeat % 4 == 0) {
        hud += 0.03;
        game += 0.015;
    }
    if (curBeat >= 168 && curBeat < 200)
    {
        game += 0.015;
        hud += 0.03;
    }
    return {
        game : game,
        hud : hud
    };
}