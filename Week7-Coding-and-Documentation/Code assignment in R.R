

# Sets the path to the parent directory of RR classes
# setwd("C://Users/ramishar/OneDrive - Capgemini/Desktop/Poland IRK/Reproducible Research/RRcourse2026/")

#Defining the relative path instread of absolute path of setwd()
data_dir <- "Data"
figure_dir <- "Figures"
if (!dir.exists(data_dir)) {
  dir.create(data_dir) 
}
if (!dir.exists(figure_dir)) {
  dir.create(figure_dir) 
}

# now we can configure variables to avoid hard-coded values in the code
COUNTRIES <- c("Belgium", "Spain", "Poland")
TASKS <- c("t_4A2a4", "t_4A2b2", "t_4A4a1")

# installing all required libraries
library(readxl)                     
library(stringr)
library(dplyr)
library(Hmisc)

# required functions
wtd_std <- function(series, weights) {
  mu <- wtd.mean(series, weights, na.rm = TRUE)
  sd <- sqrt(wtd.var(series, weights, na.rm = TRUE))
  return((series - mu) / sd)  
}

#   Import data from the O*NET database, at ISCO-08 occupation level.
# The original data uses a version of SOC classification, but the data we load here
# are already cross-walked to ISCO-08 using: https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-onet-soc-to-isco/
# The O*NET database contains information for occupations in the USA, including
# the tasks and activities typically associated with a specific occupation.
task_data = read.csv(file.path(data_dir, "onet_tasks.csv"))

# reading and combining the Eurostat employment data using a loop, which will replace hardocded 9 separate read_excel calls
eurostat_file <- file.path(data_dir, "Eurostat_employment_isco.xlsx")
isco_list <- lapply(1:9, function(i) {
  df<- read_excel(eurostat_file, sheet = paste0("ISCO", i))
  df$ISCO <- i
  return (df)
})
all_data <- bind_rows(isco_list)

# now calculatng totals & shares per country per time period using dplyr
all_data <- all_data %>%
  group_by(TIME) %>%
  mutate(across(all_of(COUNTRIES), ~ .x / sum(.x), .names = "share_{.col}")) %>%  
  ungroup()

# extracting 1-digit ISCO codes from task data and calculating mean task values at 1-digit level
task_data$isco08_1dig <- as.numeric(str_sub(task_data$isco08, 1, 1))

aggdata <- aggregate(task_data[, TASKS],
                     by = list(isco08_1dig = task_data$isco08_1dig),
                     FUN = mean, na.rm = TRUE)

# Merging datasets now
combined <- left_join(all_data, aggdata, by = c("ISCO" = "isco08_1dig"))

# Now standardising & calculating using loops
for (country in COUNTRIES) {
  share_col <- paste0("share_", country)
  #stnadardising individual tasks
  for (task in TASKS) {
    std_colname <- paste0("std_", country, "_", task)
    combined[[std_colname]] <- wtd_std(combined[[task]], combined[[share_col]]) 
  }
  
  # calculating the classic task content intensity - NRCA
  nrca_col <- paste0(country, "_NRCA")
  std_task_cols <- paste0("std_", country, "_", TASKS)
  combined[[nrca_col]] <- rowSums(combined[, std_task_cols], na.rm = TRUE)
  
  #standardising NRCA score
  std_nrca_col <- paste0("std_", country, "_NRCA")
  combined[[std_nrca_col]] <- wtd_std(combined[[nrca_col]], combined[[share_col]])
  
  #multiplying bu shgare for final aggrefgation
  multip_nrca_col <- paste0("multip_", country, "_NRCA")
  combined[[multip_nrca_col]] <- combined[[std_nrca_col]] * combined[[share_col]]  
}

#aggregating finally and exporting the outputs
for (country in COUNTRIES) {
  multip_col <- paste0("multip_", country, "_NRCA")
  # aggregating byy time
  agg_data <- aggregate(combined[[multip_col]],
                        by = list(TIME = combined$TIME),                      
                        FUN = sum, na.rm = TRUE)
  
  # Saving the plot to local rather just displaying it
  plot_path <- file.path(figure_dir, paste0("NRCA_Trend_", country, ".png"))
  png(plot_path, width = 800, height = 600, res = 120)
  plot(agg_data$x, xaxt = "n", type = "b", pch = 16,
       main = paste("Non-Routine cognitive analytical tasks:", country),
       ylab = "Intensity", xlab = "Time Period", col = "blue")
  axis(1, at = seq(1, nrow(agg_data), 3), labels = agg_data$TIME[seq(1, nrow(agg_data), 3)])
  dev.off() # closing the graphics device
}


print("Completd processing, and the plots are saved to the Figures directory.")

