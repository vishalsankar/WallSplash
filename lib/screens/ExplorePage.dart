import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:wallpaperapp/modals/WallpaperClass.dart';
import 'package:wallpaperapp/screens/LikedScreen.dart';
import 'package:wallpaperapp/services/Networking.dart';
import 'package:wallpaperapp/widgets/circulariconbutton.dart';
import 'package:wallpaperapp/widgets/WallpaperGridBuilder.dart';
import 'SearchPage.dart';

class ExplorePage extends StatefulWidget {
  static String id = 'Explore_Page';
  final List<WallPaper> preLoadedImages;
  final List<WallPaper> featuredImages;

  const ExplorePage(
      {Key? key, required this.preLoadedImages, required this.featuredImages})
      : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _controller = TextEditingController();
  List<CachedNetworkImage> featured = [];
  ScrollController _scrollController = ScrollController();
  late String searchText;
  var decodeddata;
  int floaded = 0;
  bool loadingNewImages = false;
  int loadedPages=1;

  @override
  void initState() {
    widget.featuredImages.forEach((element) {
      featured.add(CachedNetworkImage(
        imageUrl: element.regular,
        fit: BoxFit.fitWidth,
        placeholder: (_, __) {
          return AspectRatio(
            aspectRatio: 1.6,
            child: BlurHash(
              hash: element.blur,
            ),
          );
        },
      ));
    });

    super.initState();
  }

  getImages() async {
    String urlStandard =
        'https://api.unsplash.com/photos?per_page=30&page=${loadedPages++}&client_id=Hl8nP0CKgfQztU1Y8Wb62YgydLAQSOQCnbnfZ2ueSHI';

    var imagedata1 = await NetworkHelper().getWallpaper(urlStandard);

    for (var x in imagedata1) {
      widget.preLoadedImages.add(WallPaper(
        blur: x['blur_hash'],
        regular: x['urls']['regular'],
        full: x['urls']['full'],
      ));
      CachedNetworkImage(
        imageUrl: x['urls']['regular'],
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.addListener(() async {
      if ( _scrollController.position.pixels == _scrollController.position.maxScrollExtent && !loadingNewImages )
      {
        print("Calling new data");
        setState(() {
          loadingNewImages = true;
        });
        await getImages();
        setState(() {
          loadingNewImages = false;
        });
      }
    });
  }

  void clearText() {
    _controller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, LikedPage.id);
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.favorite,color: Colors.black,size: 28.0,),
        tooltip: 'Go to Liked Page',
      ),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Wallpapers'),
        titleTextStyle: TextStyle(
            fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w300),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        slivers: [
          SliverAppBar(
            title: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              backgroundColor: Colors.black,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) {
                        searchText = value;
                        clearText();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(searchItem: searchText),
                          ),
                        );
                      },
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        hintText: 'Search Eg. London, Food, etc',
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            clearText();
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            currentFocus.unfocus();
                          },
                          icon: Icon(
                            Icons.clear,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Colors.black,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  margin: EdgeInsets.only(bottom: size.height*0.01),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(color: Colors.white, width: 1.5)),
                    // borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ImageSlideshow(
                    height: size.height*0.4,
                    autoPlayInterval: 3000,
                    children: featured,
                    isLoop: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircularIconButton(
                        onpressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchPage(searchItem: 'Pets'),
                            ),
                          );
                        },
                        iconname: 'Pets',
                        icon: Icon(
                          Icons.pets,
                          color: Colors.white,
                        ),
                        color: Colors.purple,
                      ),
                      CircularIconButton(
                        onpressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchPage(searchItem: 'Dark'),
                            ),
                          );
                        },
                        iconname: 'Dark',
                        icon: Icon(
                          Icons.nights_stay_outlined,
                          color: Colors.white,
                        ),
                        color: Colors.red,
                      ),
                      CircularIconButton(
                        onpressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(searchItem: 'Nature'),
                            ),
                          );
                        },
                        iconname: 'Nature',
                        icon: Icon(
                          Icons.filter_vintage_outlined,
                          color: Colors.white,
                        ),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                TitleTile(
                  title: 'Best out of all',
                  subtitle: 'Special ones for you',
                ),
                SizedBox(height: size.height*0.01,),
                WallpaperGridBuilder(gridimagelist: widget.preLoadedImages, loading: loadingNewImages,),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TitleTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const TitleTile({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
