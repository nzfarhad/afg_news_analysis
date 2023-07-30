#Loading package
library(rvest)
library(readxl)
library(tidyverse)
library(stringr)
library(xml2)
library(DBI)
library(RSQLite)
`%notin%` <- Negate(`%in%`)


conn <- dbConnect(RSQLite::SQLite(), "output/tolo_news_db.sqlite")

dbExecute(conn, 'CREATE TABLE IF NOT EXISTS article_body (
    href TEXT,
    ar_body TEXT,
    author_name TEXT
);')


links <- dbGetQuery(conn, "SELECT * FROM article_title") 

# run if the download was interrupted
body_author_df <- readRDS("output/article_body.RDS")
links <- links %>% filter(href %notin% body_author_df$href)  

dbDisconnect(conn)

# get article body

counter <- 1
all_links <- nrow(links)
body_author_df <- data.frame(row.names = 1)

for (link in links$href) {
  
  url <- paste0('https://tolonews.com',link)
  webpage <- read_html(url)
  
  # Get Article body
  ar_body <- html_nodes(webpage,'.full-html-text')[1]
  if(length(ar_body) != 0){
    ar_body <- html_text(ar_body, trim = T)
  } else {
    ar_body <- "NA"
  }
  
  # Get Article author
  author_name <- html_nodes(webpage,'.author_name')[2]
  if (length(author_name) != 0) {
    author_name <- html_text(author_name, trim = T)
  } else {
    author_name <- "NA"
  }
  
  body_author <- data.frame(ar_body, author_name, href = link)
  body_author_df <- rbind(body_author_df, body_author)
  
  # write in SQLite database
  # dbWriteTable(conn, "article_body", body_author, row.names = FALSE, append = TRUE)
  
  cat("\014")
  print(paste0("Article ",counter, " of ", all_links, " Scraped!"))
  print(paste0("Progress: ",  round(counter/all_links * 100, 1 ), "%"))
  counter <- counter + 1
}


# Insert the data into the SQLite database
# conn <- dbConnect(RSQLite::SQLite(), "output/tolo_news_db.sqlite")
# dbWriteTable(conn, "article_body", body_author_df, row.names = FALSE, append = FALSE)
# dbDisconnect(conn)

saveRDS(body_author_df, "output/article_body.RDS")
