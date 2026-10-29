# Source: Public Libraries Victoria, 2022-23 to 2024-25
# Visits per person = (branch visits + mobile visits) / population

library(readxl)
library(dplyr)

plv_url <- paste0(
  "https://www.plv.org.au/wp-content/uploads/2025/11/",
  "06.-2024-25-PLV-Annual-Statistical-Survey-Final-Datasets-2022-23-to-2024-25.xlsx"
)
plv_file <- "data-raw/plv_final_datasets.xlsx"

if (!file.exists(plv_file)) {
  download.file(plv_url, plv_file, mode = "wb")
}

# Column names differ between years
visits_2022 <- read_excel(plv_file, sheet = "2022-23", skip = 3, na = c("", "-")) |>
  select(
    library_service = Name,
    population = contains("Municipal population"),
    branch_visits = contains("branch library visits"),
    mobile_visits = contains("mobile library visits")
  ) |>
  filter(!is.na(library_service), library_service != "Note") |>
  mutate(
    population = as.numeric(population),
    branch_visits = as.numeric(branch_visits),
    mobile_visits = as.numeric(mobile_visits),
    financial_year = "2022-23"
  )

visits_2023 <- read_excel(plv_file, sheet = "2023-24", skip = 3, na = c("", "-")) |>
  select(
    library_service = Name,
    population = contains("Municipal population"),
    branch_visits = contains("branch library visits"),
    mobile_visits = contains("mobile library visits")
  ) |>
  filter(!is.na(library_service), library_service != "Note") |>
  mutate(
    population = as.numeric(population),
    branch_visits = as.numeric(branch_visits),
    mobile_visits = as.numeric(mobile_visits),
    financial_year = "2023-24"
  )

visits_2024 <- read_excel(plv_file, sheet = "2024-25", skip = 3, na = c("", "-")) |>
  select(
    library_service = Name,
    population = contains("Municipal population"),
    branch_visits = contains("branch library visits"),
    mobile_visits = contains("mobile library visits")
  ) |>
  filter(!is.na(library_service), library_service != "Note") |>
  mutate(
    population = as.numeric(population),
    branch_visits = as.numeric(branch_visits),
    mobile_visits = as.numeric(mobile_visits),
    financial_year = "2024-25"
  )

all_visits <- bind_rows(visits_2022, visits_2023, visits_2024) |>
  mutate(
    # Blank mobile visits are treated as zero
    mobile_visits = coalesce(mobile_visits, 0),
    visits = branch_visits + mobile_visits
  )

vic_visits <- all_visits |>
  filter(library_service == "Victoria (Total)") |>
  mutate(visits_per_person = visits / population) |>
  select(financial_year, visits_per_person)

library_visits <- all_visits |>
  filter(
    library_service != "Victoria (Total)",
    library_service != "Vision Australia"
  ) |>
  mutate(
    # Keep service names consistent across years
    library_service = case_when(
      library_service == "Connected Libraries (Casey)" ~ "Connected Libraries",
      library_service == "Your Library (Eastern)" ~ "Your Library",
      library_service == "Wodonga" ~ "Hyphen",
      .default = library_service
    ),
    
    # Indigo and Towong did not report data in these years (PLV Report, Note 2)
    reported = !(
      (library_service == "Indigo" & financial_year == "2022-23") |
        (library_service == "Towong" & financial_year %in% c("2022-23", "2023-24"))
    ),
    branch_visits = if_else(reported, branch_visits, NA),
    mobile_visits = if_else(reported, mobile_visits, NA),
    visits = if_else(reported, visits, NA),
    visits_per_person = visits / population
  ) |>
  arrange(library_service, financial_year)

# Keep only the summary variables, not the original counts
# PLV data cannot be redistributed, including cleaned data
library_visits <- library_visits |>
  select(library_service, financial_year, visits_per_person, reported)

usethis::use_data(library_visits, vic_visits, overwrite = TRUE)
