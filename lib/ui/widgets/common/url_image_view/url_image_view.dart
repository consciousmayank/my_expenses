import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'url_image_view_model.dart';

class UrlImageView extends StackedView<UrlImageViewModel> {
  final String? imageUrl;
  const UrlImageView({super.key, required this.imageUrl});

  @override
  Widget builder(
    BuildContext context,
    UrlImageViewModel viewModel,
    Widget? child,
  ) {
    if (imageUrl == null || imageUrl!.isEmpty == true) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 50,
        backgroundImage: imageProvider,
        backgroundColor: Colors.grey[300],
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.red),
      ),
      // Add caching options
      cacheManager: CustomCacheManager.instance,
      maxHeightDiskCache: 200,
      maxWidthDiskCache: 200,
    );
  }

  @override
  UrlImageViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      UrlImageViewModel();
}

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager? _instance;

  static CacheManager get instance {
    _instance ??= CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 100,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(
          httpClient: RateLimitedClient(),
        ),
      ),
    );
    return _instance!;
  }
}

class RateLimitedClient extends http.BaseClient {
  final http.Client _client = http.Client();
  final RateLimiter _rateLimiter = RateLimiter();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await _rateLimiter.waitForNext();
    return _client.send(request);
  }
}

class RateLimiter {
  final Duration interval;
  DateTime? _lastRequest;

  RateLimiter({this.interval = const Duration(milliseconds: 500)});

  Future<void> waitForNext() async {
    if (_lastRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequest!);
      if (timeSinceLastRequest < interval) {
        await Future.delayed(interval - timeSinceLastRequest);
      }
    }
    _lastRequest = DateTime.now();
  }
}
