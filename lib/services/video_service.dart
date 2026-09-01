import '../models/video.dart';
import '../data/video_assets.dart';

class VideoService {
  /// Resolve a video ID to a `Video` model using the static asset map.
  Video? getVideoById(String id) {
    final path = videoAssets[id];
    if (path == null) return null;
    return Video(id: id, assetPath: path);
  }
}
