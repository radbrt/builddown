#install.packages("drake")
library(tidyverse)
library(drake)

make_plot_data <- function(infile, dsname) {
  load('wfh.RData')
  
  wfh %>% 
    mutate(aar = as.numeric(substr(statistikk_aar_mnd, 1, 4)),
           antall_stillinger = as.numeric(antall_stillinger),
           wfh = as.numeric(wfh)) %>% 
    group_by(aar) %>% 
    summarize(antall_stillinger = sum(antall_stillinger, na.rm=T), antall_remote = sum(wfh, na.rm=T)) %>%
    mutate(andel_stillinger = 100*(antall_remote/antall_stillinger))
}


plan <- drake_plan(
  wfh_plot_data = make_plot_data('wfh.RData', 'wfh'),
  report = rmarkdown::render(
    knitr_in("new_sources.Rmd"),
    output_file = file_out("new_sources.pdf"),
    quiet = TRUE
  )
)

make(plan)
