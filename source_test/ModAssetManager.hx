import animateAtlasPlayer.assets.AssetReference;
import animateAtlasPlayer.assets.AssetManager;

class ModAssetManager extends AssetManager {
    private override function loadSingle() {
        if (index >= _queue.length) {
			onSingleProgress(100, 100);
			onLoadComplete();
		}
		else{
			var assetReference : AssetReference = _queue[index]; 
            trace(assetReference.url);
			if (assetReference.extension == "zip") {
				onSingleComplete(Paths.getBytesOutsideAssets(assetReference.url));
			}
			else if (assetReference.extension == "json")  onSingleComplete(Paths.getTextOutsideAssets(assetReference.url));
			else onSingleComplete(Paths.getBitmapOutsideAssets(assetReference.url));
		};
    }
}