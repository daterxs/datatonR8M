library(R6)
library(jsonlite)


#' Json Paged Scraper class
#' @export
JsonPagedScraper.class <- R6Class("JsonPagedScraper",
   public = list(
     #parameters
     max.csv.rows = NA,
     max.tweets   = NA,
     out.filename = NA,
     scraping.strategy = NA,
     #state
     row.counter    = NA,
     tweet.counter  = NA,
     filenames.counter = 0,
     processed.data = NA,
     saved.filenames = NA,
     initialize = function(scraping.strategy,
                           max.csv.rows = 10000,
                           out.filename = file.path(dataton.home.dir, "processed"),
                           max.tweets = 0
     ){
       self$processed.data    <- NULL
       self$scraping.strategy <- scraping.strategy
       self$max.csv.rows      <- max.csv.rows
       self$max.tweets        <- max.tweets
       self$out.filename      <- out.filename
       self$saved.filenames   <- NULL
       #state
       self$tweet.counter <- 0
       self
     },
     initProcessedData = function(){
       self$processed.data <- NULL
       self$row.counter   <- 0
       self
     },
     processPage = function(json, max.rows=0){
       n <- nrow(json)

       time.begin <- Sys.time()
       phase.begin <- Sys.time()
       if (max.rows >0){
         n <- min(n, max.rows)
       }
       tenperc <- max(round(n*.1), 1)

       print(paste("rows",n))
       for (i in seq_len(n)){
         current.tweet <- json[i,]
         #current.tweet <<- current.tweet

         ret.current <- self$scraping.strategy$process(current.tweet)
         self$processed.data <- rbind(self$processed.data, ret.current)
         #ret <- rbind(ret, ret.current)
         #self$processed.data[nrow(self$processed.data)+1,] <- ret.current


         if (i  %% tenperc ==0){
           current.time <- round(difftime(Sys.time(), phase.begin, units = "sec"))
           total.time   <- round(difftime(Sys.time(), time.begin, units = "sec"))
           print(paste("Processed ",round(i/n*100), "% ", i,"/",n," in ", current.time,
                       " secs", ". Total time ", total.time,sep=""))
           print(paste(nrow(self$processed.data), "rows included in output"))
           phase.begin <- Sys.time()
         }

         if (nrow(self$processed.data) >= self$max.csv.rows){
           current.file <- paste(self$out.filename,"_",self$filenames.counter,".csv", sep = "")
           print(paste("Saving csv", self$filenames.counter, current.file))
           write.csv(self$processed.data,
                     file = current.file,
                     row.names = FALSE)
           self$filenames.counter <- self$filenames.counter + 1
           self$initProcessedData()
         }
         self$tweet.counter <- self$tweet.counter + 1
         if (self$tweet.counter > self$max.tweets & self$max.tweets >0){
           stop(paste("Max tweets reached:", self$max.tweets))
         }
       }
       self$processed.data
     }
   ))


#' Json Scraper Strategy abstract class
#' @import tibble
#' @export
JsonScraperStrategy.class <- R6Class("JsonScraperStrategy",
  public = list(
    initialize = function(){

    },
    process = function(json){
      stop("Abstract class")
    },
    extractField = function(json, field){
      extraction.tree <- strsplit(field, split = "\\$")[[1]]
      ret <- json
      for (node in extraction.tree){
        ret <- ret[[node]]
      }
      if (is.null(ret)){
        futile.logger::flog.info(paste("Field", field, "not found in json"))
      }
      ret
    },
    extractFields = function(json, fields){
      ret <- tibble(dummy="")
      for (field in fields){
        ret[,field] <- self$extractField(json, field)
      }
      ret[,"dummy"] <- NULL
      ret
    }
    ))


JsonScraperMinimalStrategy.class <- R6Class("JsonScraperMinimalStrategy",
  inherit = JsonScraperStrategy.class,
  public = list(
    min.interactions.count = NA,
    initialize = function(min.interactions.count = 10){
      super$initialize()
      self$min.interactions.count <- min.interactions.count
      self
    },
    process = function(json){
      ret <- self$extractFields(json,
              fields = c("id_str", "text",
                  "user$name", "user$screen_name", "user$location",
                  "user$verified", "user$followers_count", "user$friends_count",
                  "user$favourites_count", "user$statuses_count", "user$created_at",
                  "quote_count", "reply_count", "retweet_count", "favorite_count",
                  "retweeted"
                  ))
      ret$interactions_count <- sum(ret[,c("quote_count", "reply_count", "retweet_count", "favorite_count")])
      #debug
      #print(names(json))

      #ret <- ret[ret$interactions_count >= self$min.interactions.count,]
      ret <- ret[ret[,"user$followers_count"] >= 1000,]
      ret
    }))
