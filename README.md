# filmbot

### setup

```
$ bundle install
```

- Note: installing nokogiri on OSX might take some finagling because some of its dependencies (`libiconv`) also come with Xcode. Try `gem install nokogiri --use-system-libraries=true`

### generating html

```
// to iterate on a single scraper:
// generate nyc, with the scraper matching 'metrograph'
$ ./compose.rb -c nyc -m metrograph

// to iterate on multi-scraper output:
// generate nyc, with up to 3 scrapers
$ ./compose.rb -c nyc -l 3
```
