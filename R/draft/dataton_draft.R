dataton.home.dir <- file.path("~", "dataton8m")
dir.create(dataton.home.dir, recursive = TRUE, showWarnings = FALSE)

filename.data.tweets.8m <- "~/git/data_9m_twitter/data/tweets_all.jsonl"

paged.scraper <- JsonPagedScraper.class$new(max.csv.rows = 1)
paged.scraper$initProcessedData()
self <- paged.scraper
self$processed.data
head(self$processed.data)

get_tweets <- stream_in(file(filename.data.tweets.8m),
                        handler  = paged.scraper$processPage,
                        pagesize = 1)
