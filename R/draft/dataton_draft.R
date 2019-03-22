library(tibble)
library(jsonlite)
library(readr)
library(dplyr)
dir.create(dataton.home.dir, recursive = TRUE, showWarnings = FALSE)




minimal.scrape.strategy <- JsonScraperMinimalStrategy.class$new()
paged.scraper <- JsonPagedScraper.class$new(minimal.scrape.strategy,
                                            max.csv.rows = 10,
                                            max.tweets = 10)
paged.scraper$initProcessedData()
self <- paged.scraper
self$processed.data
head(self$processed.data)

get_tweets <- stream_in(file(filename.data.tweets.8m),
                        handler  = paged.scraper$processPage,
                        pagesize = 10)

names(json)
names(self$processed.data)



#Test
tweets.0 <- read_csv("/Users/kenarab/dataton8m/processed_0.csv")
names(tweets.0)
head(tweets.0)

as.data.frame(tweets.0[tweets.0$`user$screen_name`==tweets.0$`user$screen_name` [7],])

tweets.0 %>% group_by_("`user$screen_name`", "`user$followers_count`") %>%
                        summarize(interactions_count = sum(interactions_count),
                                  quote_count = sum(quote_count),
                                  reply_count = sum(reply_count),
                                  favorite_count = sum(favorite_count),
                                  retweet_count = sum(retweet_count),
                                  )




# Process a huge batch

minimal.scrape.strategy <- JsonScraperMinimalStrategy.class$new()
paged.scraper <- JsonPagedScraper.class$new(minimal.scrape.strategy,
                                            max.csv.rows = 10000,
                                            max.tweets = 0)
paged.scraper$initProcessedData()
self <- paged.scraper
self$processed.data
head(self$processed.data)

get_tweets <- stream_in(file(filename.data.tweets.8m),
                        handler  = paged.scraper$processPage,
                        pagesize = 1000)




#Test
tweets.0 <- read_csv("/Users/kenarab/dataton8m/processed_0.csv")
names(tweets.0)
head(tweets.0)

as.data.frame(tweets.0[tweets.0$`user$screen_name`==tweets.0$`user$screen_name` [7],])

tweets.0 %>% group_by_("`user$screen_name`", "`user$followers_count`") %>%
  summarize(interactions_count = sum(interactions_count),
            quote_count = sum(quote_count),
            reply_count = sum(reply_count),
            favorite_count = sum(favorite_count),
            retweet_count = sum(retweet_count),
  )

