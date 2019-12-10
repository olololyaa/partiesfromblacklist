#packages
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

#data from http://www.st-petersburg.vybory.izbirkom.ru/region/st-petersburg/?action=ik, parsed on Sep, 13
#df <- read_csv("data/uiks.csv")
 
#data from blacklist, downloaded from https://blacklist.spbelect.org/ on Dec, 8.
#blacklist <- read_csv("data/blacklist.csv")

# filtering only 2019
blacklist %>% filter(year==2019)  -> only2019
  
#merging strings with names
only2019 %>%  unite(name, surname, nam, father, sep = " ", remove = FALSE, na.rm = FALSE) -> only2019
only2019 %>% select(name, uik, tik, year) -> short2019

#remove duplicated rows, because one person can do more than one law violation
short2019%>% distinct() -> short2019nodup
short2019nodup$uik <- as.numeric(short2019nodup$uik)

#merging dataframes by name and uik number
common_table <- full_join(df, short2019nodup, by = c("name", 'uik'))

#counting 
common_table %>% filter(year==2019) %>% group_by(party) %>% count() %>% mutate (percent = n/196*100) %>% arrange(desc(n)) -> stat
stat$percent<- round(stat$percent,2)

#writing doc
library(officer) 
my_doc <- read_docx() 
my_doc <- my_doc %>%  body_add_par("От кого назначали членов комиссий в реестре", style = "Normal") %>% body_add_table(stat, header=TRUE, style = "table_template")
print(my_doc, target = "table.docx")
