# Library visits per resident for Victorian public library services

Annual visits per resident for 50 Victorian public library services from
2022-23 to 2024-25, with one row per service and financial year.

## Usage

``` r
library_visits
```

## Format

A data frame with 150 rows and 4 columns:

- library_service:

  Name of the library service.

- financial_year:

  Financial year, from 2022-23 to 2024-25.

- visits_per_person:

  Library visits divided by municipal population.

- reported:

  Whether the library service submitted data for that year.

## Source

Public Libraries Victoria, 2024-25 Annual Statistical Survey, Final
Datasets 2022-23 to 2024-25.
<https://www.plv.org.au/resources/earlier-reports-and-surveys/> Data ©
Public Libraries Victoria.

## Details

Visits per resident are calculated as branch and mobile library visits
divided by the municipal population, following PLV definitions.

Indigo did not report in 2022-23, and Towong did not report in 2022-23
or 2023-24. These observations have `reported = FALSE` and
`visits_per_person = NA` rather than using PLV estimates.

Library service names use the 2024-25 names in all years: Connected
Libraries (formerly Connected Libraries (Casey)), Your Library (formerly
Your Library (Eastern)) and Hyphen (formerly Wodonga). Vision Australia
is excluded because no municipal population is available.

Only the calculated rates are stored, not the original visit counts or
population figures. See `data-raw/library_visits.R` for the preparation
steps.

## See also

[vic_visits](https://etc5523-2026.github.io/etc5523-assignment-4-scho0107/reference/vic_visits.md)

## Examples

``` r
head(library_visits)
#> # A tibble: 6 × 4
#>   library_service financial_year visits_per_person reported
#>   <chr>           <chr>                      <dbl> <lgl>   
#> 1 Bayside         2022-23                     3.59 TRUE    
#> 2 Bayside         2023-24                     3.99 TRUE    
#> 3 Bayside         2024-25                     4.27 TRUE    
#> 4 Boroondara      2022-23                     4.68 TRUE    
#> 5 Boroondara      2023-24                     5.28 TRUE    
#> 6 Boroondara      2024-25                     5.46 TRUE    
```
