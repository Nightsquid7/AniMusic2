# Anime Scraper

This is a command-line tool to scrape anime seasons and anime music from online sources and find the relevant tracks on Spotify and Apple Music.

## Local caching

As the scraping action is incredibly time consuming due to API rate limits, etc. Scraped data is automatically cached locally by season. By default, this cache is enabled. However, if you wish to scrape the season again, you can disable the cache using the `-cache=false` switch.

## Configuring Music Sources

### Enabling Spotify

Spotify search requires a working Spotify account. Follow the instructions [here](https://developer.spotify.com/documentation/general/guides/authorization-guide/) to create a working client id and client secret.

Supply the id and secret to the Anime Scraper using the `-sid` and `-ss` switches.

### Enabling Apple Music

TBD

## Configuring Output Writers

Anime scraper can be configured to output to a Firestore database and to a json file.

### Enabling Firestore Output Writer

Anime scraper uses the Firebase admin sdk to perform its writing actions. In order to initialize this, you need to create a Firebase service account and place the service account private key in the same directory as the executable or point Anime Scraper to the location of the private key using the `-firebaseCredPath` switch.

See [here](https://firebase.google.com/docs/admin/setup) for more details.

**Note** Firestore output writer only creates new anime entries when they do not exist in the database to prevent unintended merges and updates. To recreate anime entries from search data, delete the document or collection in Firestore before running Anime Scraper.

### Enabling Json output writer

To enable the json output writer, simply designate the name of the output file using the `-writePath` switch.
