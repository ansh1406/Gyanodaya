import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../services/video_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final VideoService _videoService = VideoService();
  VideoPlayerController? _controller;

  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isSeeking = false;
  double _dragPositionMs = 0.0;
  double _playbackSpeed = 1.0;

  bool _showLeftRipple = false;
  bool _showRightRipple = false;

  Timer? _controlsTimer;

  static const List<double> _availableSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final video = _videoService.getVideoById(widget.videoId);
    if (video == null) {
      setState(() {
        _error = 'Video not found (${widget.videoId})';
        _isLoading = false;
      });
      return;
    }

    try {
      _controller = VideoPlayerController.asset(video.assetPath);
      await _controller!.initialize();
      _controller!.addListener(_onControllerUpdate);

      setState(() {
        _isLoading = false;
      });

      await _controller!.play();
      _startControlsTimer();
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted &&
          _controller != null &&
          _controller!.value.isPlaying &&
          !_isSeeking) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    if (_showControls) {
      _controlsTimer?.cancel();
      setState(() => _showControls = false);
    } else {
      _startControlsTimer();
    }
  }

  bool get _isEnded {
    if (_controller == null || !_controller!.value.isInitialized) return false;
    final val = _controller!.value;
    return val.position >= val.duration && val.duration > Duration.zero;
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isEnded) {
      _replayVideo();
    } else if (_controller!.value.isPlaying) {
      _controller!.pause();
      _controlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      _controller!.play();
      _startControlsTimer();
    }
  }

  void _replayVideo() {
    if (_controller == null) return;
    _controller!.seekTo(Duration.zero);
    _controller!.play();
    _startControlsTimer();
  }

  void _seekRelative(Duration offset) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final current = _controller!.value.position;
    final target = current + offset;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _controller!.value.duration
            ? _controller!.value.duration
            : target);
    _controller!.seekTo(clamped);
    _startControlsTimer();
  }

  void _onDoubleTapLeft() {
    _seekRelative(const Duration(seconds: -5));
    setState(() => _showLeftRipple = true);
    Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _showLeftRipple = false);
    });
  }

  void _onDoubleTapRight() {
    _seekRelative(const Duration(seconds: 5));
    setState(() => _showRightRipple = true);
    Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _showRightRipple = false);
    });
  }

  void _toggleFullscreen() {
    final nextFullscreen = !_isFullscreen;
    setState(() {
      _isFullscreen = nextFullscreen;
    });

    if (nextFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    _startControlsTimer();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _controller?.setPlaybackSpeed(speed);
    _startControlsTimer();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();

    // Ensure system orientations & UI modes are restored
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !_isFullscreen,
          bottom: !_isFullscreen,
          left: false,
          right: false,
          child: _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _buildPlayerContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading video...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _error ?? 'An unexpected error occurred',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initPlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerContent() {
    final videoSize = _controller?.value.size ?? Size.zero;
    final hasValidSize = _controller != null &&
        _controller!.value.isInitialized &&
        videoSize.width > 0 &&
        videoSize.height > 0;
    final double aspectRatio = hasValidSize
        ? _controller!.value.aspectRatio
        : (16 / 9);

    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Layer: Scaled perfectly to player size and clipped to eliminate edge green line artifacts
            Positioned.fill(
              child: ClipRect(
                child: Transform.scale(
                  scale: 1.015,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: hasValidSize ? videoSize.width : 16,
                        height: hasValidSize ? videoSize.height : 9,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Double Tap Gesture Detection Layer
            Positioned.fill(
              child: Row(
                children: [
                  // Left half - Rewind 5s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControlsVisibility,
                      onDoubleTap: _onDoubleTapLeft,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Right half - Forward 5s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControlsVisibility,
                      onDoubleTap: _onDoubleTapRight,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),

            // Left Ripple Feedback Overlay (-5s)
            if (_showLeftRipple)
              Positioned(
                left: 30,
                child: _buildSeekFeedback(
                  icon: Icons.replay_5,
                  label: '-5 sec',
                ),
              ),

            // Right Ripple Feedback Overlay (+5s)
            if (_showRightRipple)
              Positioned(
                right: 30,
                child: _buildSeekFeedback(
                  icon: Icons.forward_5,
                  label: '+5 sec',
                ),
              ),

            // Animated Controls Overlay
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _buildControlsOverlay(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekFeedback({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(160),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
          stops: const [0.0, 0.25, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopControls(),
          _buildCenterControls(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Back',
          ),
          // Playback Speed Menu
          PopupMenuButton<double>(
            initialValue: _playbackSpeed,
            tooltip: 'Playback Speed',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_playbackSpeed}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            color: const Color(0xFF1E1E1E),
            onSelected: _changePlaybackSpeed,
            itemBuilder: (context) {
              final primaryColor = Theme.of(context).colorScheme.primary;
              return _availableSpeeds.map((speed) {
                final isSelected = speed == _playbackSpeed;
                return PopupMenuItem<double>(
                  value: speed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${speed}x',
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: primaryColor,
                          size: 18,
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isPlaying = _controller?.value.isPlaying ?? false;
    final isEnded = _isEnded;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 5s Rewind Button
        IconButton(
          iconSize: 36,
          color: Colors.white,
          tooltip: 'Rewind 5s',
          icon: const Icon(Icons.replay_5_rounded),
          onPressed: _onDoubleTapLeft,
        ),
        const SizedBox(width: 24),

        // Central Play / Pause / Replay Button
        Material(
          color: primaryColor.withAlpha(220),
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _togglePlayPause,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(
                isEnded
                    ? Icons.replay_rounded
                    : isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // 5s Forward Button
        IconButton(
          iconSize: 36,
          color: Colors.white,
          tooltip: 'Forward 5s',
          icon: const Icon(Icons.forward_5_rounded),
          onPressed: _onDoubleTapRight,
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    final totalMs = duration.inMilliseconds.toDouble();
    final currentMs = _isSeeking
        ? _dragPositionMs
        : position.inMilliseconds.toDouble().clamp(0.0, totalMs > 0 ? totalMs : 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrub Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              activeTrackColor: primaryColor,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: primaryColor.withAlpha(80),
            ),
            child: Slider(
              value: totalMs > 0 ? currentMs.clamp(0.0, totalMs) : 0.0,
              min: 0.0,
              max: totalMs > 0 ? totalMs : 1.0,
              onChangeStart: (value) {
                _controlsTimer?.cancel();
                setState(() {
                  _isSeeking = true;
                  _dragPositionMs = value;
                });
              },
              onChanged: (value) {
                setState(() {
                  _dragPositionMs = value;
                });
              },
              onChangeEnd: (value) {
                _controller
                    ?.seekTo(Duration(milliseconds: value.toInt()))
                    .then((_) {
                  if (mounted) {
                    setState(() {
                      _isSeeking = false;
                    });
                    _startControlsTimer();
                  }
                });
              },
            ),
          ),

          // Time label and Fullscreen Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDuration(_isSeeking ? Duration(milliseconds: _dragPositionMs.toInt()) : position)} / ${_formatDuration(duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.white,
                    tooltip: 'Replay',
                    icon: const Icon(Icons.replay),
                    onPressed: _replayVideo,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.white,
                    tooltip:
                        _isFullscreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
                    icon: Icon(
                      _isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                    ),
                    onPressed: _toggleFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


