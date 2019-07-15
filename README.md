# filmbot

https://filmbot.info/

![filmbot](http://benguo.info/img/filmbot.png)

Filmbot scrapes independent movie theater listings in a city, and generates a digest of movies playing in the next week. 

Adding a new theater is pretty easy - each one takes me less than 20 minutes. I'd love to see contributions adding new cities, or new event categories. 

It's pretty easy to scrape any site with either:

1. links to an external ticketing provider (easier)
2. a consistent format for events (might take a bit longer)

The project is designed to be "as primitive as possible", optimized for quick skimming, fast iteration, and low maintenance. 

The static site (just a few html pages) is auto-deployed by pushes to GitHub. A nightly cron (1am PST) runs the crawler and pushes updated html files.


### setup

```
$ bundle install
```

- Note: installing nokogiri on OSX might take some fiddling. Try `gem install nokogiri --use-system-libraries=true`

### generating html

```
// to run a single scraper:
// generate nyc, with the scraper matching 'metrograph'
$ ./generate.rb -c nyc -m metrograph; open nyc.html

// to run a few scrapers:
// generate nyc, with up to 3 scrapers
$ ./generate.rb -c nyc -l 3; open nyc.html
```
