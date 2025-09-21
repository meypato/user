import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../themes/app_colour.dart';

class MapWidget extends StatefulWidget {
  final String? googleMapsLink;
  final String buildingName;
  final bool showFullscreen;

  const MapWidget({
    super.key,
    required this.googleMapsLink,
    required this.buildingName,
    this.showFullscreen = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  WebViewController? _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.googleMapsLink != null && widget.googleMapsLink!.isNotEmpty) {
      _initializeWebView();
    }
  }

  /// Extract coordinates from Google Maps link
  Map<String, double>? _extractCoordinatesFromLink(String googleMapsLink) {
    try {
      final RegExp coordRegex = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)');
      final match = coordRegex.firstMatch(googleMapsLink);

      if (match != null) {
        final lat = double.tryParse(match.group(1) ?? '');
        final lng = double.tryParse(match.group(2) ?? '');

        if (lat != null && lng != null) {
          return {'lat': lat, 'lng': lng};
        }
      }
    } catch (e) {
      print('Error extracting coordinates: $e');
    }
    return null;
  }

  /// Create HTML with embedded Google Maps iframe
  String _createMapHtml(String originalLink) {
    final coords = _extractCoordinatesFromLink(originalLink);

    String iframeSrc;
    if (coords != null) {
      final lat = coords['lat']!;
      final lng = coords['lng']!;
      iframeSrc = 'https://maps.google.com/maps?q=$lat,$lng&z=15&output=embed';
    } else {
      iframeSrc = 'https://maps.google.com/maps?q=${Uri.encodeComponent(originalLink)}&output=embed';
    }

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                margin: 0;
                padding: 0;
                width: 100%;
                height: 100vh;
                overflow: hidden;
            }
            iframe {
                width: 100%;
                height: 100%;
                border: none;
                display: block;
            }
        </style>
    </head>
    <body>
        <iframe src="$iframeSrc"
                allowfullscreen=""
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
        </iframe>
    </body>
    </html>
    ''';
  }

  /// Initialize WebView controller
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    final htmlContent = _createMapHtml(widget.googleMapsLink!);
    _webViewController!.loadHtmlString(htmlContent);
  }

  /// Open Google Maps in external app
  Future<void> _openInGoogleMaps() async {
    if (widget.googleMapsLink == null || widget.googleMapsLink!.isEmpty) return;

    try {
      final uri = Uri.parse(widget.googleMapsLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show map in fullscreen dialog
  void _showMapPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.map,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.buildingName,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.primaryBlue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Map content
                Expanded(
                  child: _buildMapContent(isFullscreen: true),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openInGoogleMaps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapContent({bool isFullscreen = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show "no map" if no Google Maps link available
    if (widget.googleMapsLink == null || widget.googleMapsLink!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
                size: isFullscreen ? 48 : 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Map not available',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: isFullscreen ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading or WebView
    if (_webViewController == null || _isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: isFullscreen ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: isFullscreen
          ? BorderRadius.zero
          : BorderRadius.circular(12),
      child: WebViewWidget(controller: _webViewController!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showFullscreen) {
      return _buildMapContent(isFullscreen: true);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildMapContent(),

            // Action buttons overlay
            if (widget.googleMapsLink != null && widget.googleMapsLink!.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show Map button
                    GestureDetector(
                      onTap: () => _showMapPopup(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Show Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Open in Google Maps button
                    GestureDetector(
                      onTap: _openInGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Google Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}