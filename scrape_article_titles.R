#Loading package
library(rvest)
library(readxl)
library(tidyverse)
library(stringr)
library(xml2)


# Scrape article title, date and link -------------------------------------

# Create empty vectors
page_id <- vector()


# Create empty dataframes
titles_df <- data.frame(row.names = 1)
dates_data <- data.frame(row.names = 1)
links_data <- data.frame(row.names = 1)

# Iterate over all pages in Tolo News website and get the article title, date, and links
total_pages <- 2749
for (i in 1:total_pages) {
  #English link
  url <- paste0('https://tolonews.com/afghanistan/all?page=',i)
  #Dari link
  # url <- paste0('https://tolonews.com/index.php/fa/afghanistan/all?page=',i)
  webpage <- read_html(url)
  
  # Short title
  ar_title <- html_nodes(webpage,'.title-article')
  ar_date <- html_nodes(webpage,'span.post-date.grey-light3.uppercase-txt')
  get_title <- html_text(ar_title, trim = T)
  get_title <- get_title[1:10]
  page_id[1:10] <- i
  
  # Long title
  ar_title2 <- html_nodes(webpage,'.hidden-onmobile')
  get_title2 <- html_text(ar_title2, trim = T)
  get_title2 <- get_title2[4:13]
 
  all_tittles_df <- data.frame(get_title, get_title2, page_id)
  titles_df <- rbind(titles_df,all_tittles_df )
  
  ## dates
  dates_frame <- xml_children(ar_date) %>% 
    as_list() %>% 
    lapply(attributes) %>% 
    do.call(rbind, .) %>% 
    as.data.frame() %>% 
    mutate(
      page_id = page_id
    )
  
  dates_data <- rbind(dates_data, dates_frame)
  
  
  ## links
  links <- xml_children(ar_title) %>% 
    as_list() %>% 
    lapply(attributes) %>% 
    do.call(rbind, .) %>% 
    as.data.frame() %>% 
    mutate(
      page_id = page_id
    )
    
  links_data <- rbind(links_data, links)
  
  # Progress
  cat("\014")  
  print(paste0("Page ",i, " of ", total_pages, " Scraped!"))
  print(paste0("Progress: ",  round(i/total_pages * 100, 1 ), "%"))
 
}

# merge data
merged_data <- cbind(
  titles_df, 
  select(dates_data, date_time = `data-time`),
  select(links_data, -c(page_id))) %>% 
  mutate_all(as.character)


# export data
openxlsx::write.xlsx(dates_data, paste0("output/dates", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(links_data, paste0("output/links", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(titles_df, paste0("output/titles", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(merged_data, paste0("output/all_data", Sys.Date(), ".xlsx"))
write_rds(merged_data, paste0("output/all_data", Sys.Date(), ".rds"))


