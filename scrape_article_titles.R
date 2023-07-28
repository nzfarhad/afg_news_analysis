#Loading package
library(rvest)
library(readxl)
library(tidyverse)
library(stringr)
library(xml2)


# Scrape article title, date and link -------------------------------------

# Create empty vectors
all_tittles <- vector()
page_id <- vector()
page_id_all <- vector()

# Create empty dataframes
titles_df <- data.frame(row.names = 1)
dates_data <- data.frame(row.names = 1)
links_data <- data.frame(row.names = 1)

# Iterate over all pages in Tolo News website and get the article title, date, and links
total_pages <- 2749
for (i in 1:total_pages - 1) {
  #English link
  url <- paste0('https://tolonews.com/afghanistan/all?page=',i)
  #Dari link
  # url <- paste0('https://tolonews.com/index.php/fa/afghanistan/all?page=',i)
  webpage <- read_html(url)
  ar_title <- html_nodes(webpage,'.title-article')
  ar_date <- html_nodes(webpage,'span.post-date.grey-light3.uppercase-txt')
  get_title <- html_text(ar_title, trim = T)
  get_title <- get_title[1:10]
  page_id[1:10] <- i
  
  ar_title2 <- html_nodes(webpage,'.hidden-onmobile')
  get_title2 <- html_text(ar_title2, trim = T)
  get_title2 <- get_title2[4:13]
  # page_id_all <- append(page_id_all, page_id, after = length(page_id_all))
  # get_date <- html_text(ar_date)
  # all_tittles <- append(all_tittles, get_title, after = length(all_tittles))
  all_tittles_df <- data.frame(get_title, get_title2, page_id)
  titles_df <- rbind(titles_df,all_tittles_df )
  
  ## dates
  date1 <- xml_children(ar_date)
  date2 <- as_list(date1)
  date_list <- lapply(date2, attributes)
  dates_d_frame <- do.call(rbind, date_list)
  dates_frame <- as.data.frame(dates_d_frame)
  dates_frame$page_id <- page_id
  dates_data <- rbind(dates_data, dates_frame)
  
  
  ## links
  link1 <- xml_children(ar_title)
  link2 <- as_list(link1)
  link3 <- lapply(link2, attributes)
  link_list <- do.call(rbind, link3)
  links <- as.data.frame(link_list)
  links$page_id <- page_id
  links_data <- rbind(links_data, links)
  
  cat("\014")  
  print(paste0("Page ",i, " of ", total_pages, " Scraped!"))
  print(paste0("Progress: ",  round(i/total_pages * 100, 1 ), "%"))
 
}

# merge data
merged_new_data <- cbind(titles_df, dates_data, links_data)

# export data

openxlsx::write.xlsx(dates_data, paste0("output/dari_data/dates", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(links_data, paste0("output/dari_data/links", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(titles_df, paste0("output/dari_data/titles", Sys.Date(), ".xlsx"))
openxlsx::write.xlsx(merged_new_data, paste0("output/dari_data/all_data", Sys.Date(), ".xlsx"))
write_rds(merged_new_data, paste0("output/dari_data/all_data", Sys.Date(), ".rds"))


