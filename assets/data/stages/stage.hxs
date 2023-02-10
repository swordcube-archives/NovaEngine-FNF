function onCreate() {
    stage.dadPos.set(100, 100);
    stage.gfPos.set(400, 130);
    stage.bfPos.set(770, 100);

    defaultCamZoom = 0.9;

    var bg = new FNFSprite(-600, -200).loadGraphic(stageImage('stageback'));
    bg.scrollFactor.set(0.9, 0.9);
    add(bg);

    var stageFront = new FNFSprite(-650, 600).loadGraphic(stageImage('stagefront'));
    stageFront.scale.set(1.1, 1.1);
    stageFront.updateHitbox();
    stageFront.scrollFactor.set(0.9, 0.9);
    add(stageFront);

    var stageCurtains = new FNFSprite(-500, -300).loadGraphic(stageImage('stagecurtains'));
    stageCurtains.scale.set(0.9, 0.9);
    stageCurtains.updateHitbox();
    stageCurtains.scrollFactor.set(1.3, 1.3);
    add(stageCurtains, "fg"); // the "fg" at the end adds the sprite above the stage and all characters
}