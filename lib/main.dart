import 'package:flutter/material.dart';

void main() {
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatelessWidget {
  const WallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallpapers',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final FavoritesStore _favoritesStore = FavoritesStore();

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(favoritesStore: _favoritesStore),
      FavoritesScreen(favoritesStore: _favoritesStore),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wallpaper_outlined),
            selectedIcon: Icon(Icons.wallpaper),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.favoritesStore});

  final FavoritesStore favoritesStore;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WallpaperRepository _repository = WallpaperRepository();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Trending';
  List<Wallpaper> _items = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
    _searchController.addListener(() {
      _loadWallpapers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _repository.fetchWallpapers(
      category: _selectedCategory,
      query: _searchController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _items = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover Wallpapers',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SearchBar(
              controller: _searchController,
              hintText: 'Search superhero, anime, abstract...',
              leading: const Icon(Icons.search),
            ),
            const SizedBox(height: 12),
            CategoryChips(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _loadWallpapers();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(child: Text('No wallpapers found.'))
                      : GridView.builder(
                          itemCount: _items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return WallpaperCard(
                              wallpaper: item,
                              favoritesStore: widget.favoritesStore,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.favoritesStore});

  final FavoritesStore favoritesStore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: favoritesStore.favorites,
          builder: (context, favoriteIds, _) {
            final wallpapers = WallpaperRepository.items
                .where((item) => favoriteIds.contains(item.id))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Favorites',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: wallpapers.isEmpty
                      ? const Center(
                          child: Text('No favorites yet. Tap heart icons to save.'),
                        )
                      : GridView.builder(
                          itemCount: wallpapers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            return WallpaperCard(
                              wallpaper: wallpapers[index],
                              favoritesStore: favoritesStore,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  static const categories = [
    'Trending',
    'Superheroes',
    'Anime',
    'Cars',
    'Nature',
    'Abstract',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (_) => onCategoryChanged(category),
          );
        },
      ),
    );
  }
}

class WallpaperCard extends StatelessWidget {
  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.favoritesStore,
  });

  final Wallpaper wallpaper;
  final FavoritesStore favoritesStore;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WallpaperDetailScreen(
              wallpaper: wallpaper,
              favoritesStore: favoritesStore,
            ),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Hero(
              tag: wallpaper.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    wallpaper.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: favoritesStore.favorites,
                builder: (context, favorites, _) {
                  final isFavorite = favorites.contains(wallpaper.id);
                  return CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.45),
                    child: IconButton(
                      onPressed: () => favoritesStore.toggle(wallpaper.id),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WallpaperDetailScreen extends StatelessWidget {
  const WallpaperDetailScreen({
    super.key,
    required this.wallpaper,
    required this.favoritesStore,
  });

  final Wallpaper wallpaper;
  final FavoritesStore favoritesStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: wallpaper.id,
            child: Image.network(wallpaper.imageUrl, fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Text(
                    wallpaper.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wallpaper.category,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Download action goes here.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: favoritesStore.favorites,
                        builder: (context, favorites, _) {
                          final isFavorite = favorites.contains(wallpaper.id);
                          return IconButton.filled(
                            onPressed: () => favoritesStore.toggle(wallpaper.id),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final String imageUrl;
}

class WallpaperRepository {
  static const items = [
    Wallpaper(
      id: '1',
      title: 'Crimson Hero',
      category: 'Superheroes',
      imageUrl: 'https://picsum.photos/id/1011/800/1400',
    ),
    Wallpaper(
      id: '2',
      title: 'Skyline Defender',
      category: 'Superheroes',
      imageUrl: 'https://picsum.photos/id/1012/800/1400',
    ),
    Wallpaper(
      id: '3',
      title: 'Neo Drift',
      category: 'Cars',
      imageUrl: 'https://picsum.photos/id/1018/800/1400',
    ),
    Wallpaper(
      id: '4',
      title: 'Forest Breath',
      category: 'Nature',
      imageUrl: 'https://picsum.photos/id/1020/800/1400',
    ),
    Wallpaper(
      id: '5',
      title: 'Silent Samurai',
      category: 'Anime',
      imageUrl: 'https://picsum.photos/id/1024/800/1400',
    ),
    Wallpaper(
      id: '6',
      title: 'Cosmic Pulse',
      category: 'Abstract',
      imageUrl: 'https://picsum.photos/id/1031/800/1400',
    ),
    Wallpaper(
      id: '7',
      title: 'Urban Titan',
      category: 'Trending',
      imageUrl: 'https://picsum.photos/id/1043/800/1400',
    ),
    Wallpaper(
      id: '8',
      title: 'Night Racer',
      category: 'Cars',
      imageUrl: 'https://picsum.photos/id/1050/800/1400',
    ),
    Wallpaper(
      id: '9',
      title: 'Arc Lightning',
      category: 'Trending',
      imageUrl: 'https://picsum.photos/id/1062/800/1400',
    ),
  ];

  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    required String query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return items.where((item) {
      final inCategory = category == 'Trending' || item.category == category;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase());
      return inCategory && matchesQuery;
    }).toList();
  }
}

class FavoritesStore {
  final ValueNotifier<Set<String>> favorites = ValueNotifier(<String>{});

  void toggle(String wallpaperId) {
    final next = Set<String>.from(favorites.value);
    if (next.contains(wallpaperId)) {
      next.remove(wallpaperId);
    } else {
      next.add(wallpaperId);
    }
    favorites.value = next;
  }
}
