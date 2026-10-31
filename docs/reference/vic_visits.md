# Statewide library visits per resident in Victoria

Annual library visits per resident for Victoria from 2022-23 to 2024-25.
These figures provide the statewide benchmark for comparing library
services.

## Usage

``` r
vic_visits
```

## Format

A data frame with 3 rows and 2 columns:

- financial_year:

  Financial year, from 2022-23 to 2024-25.

- visits_per_person:

  Total Victorian library visits divided by the Victorian population.

## Source

Public Libraries Victoria, 2024-25 Annual Statistical Survey, Final
Datasets 2022-23 to 2024-25.
<https://www.plv.org.au/resources/earlier-reports-and-surveys/> Data ©
Public Libraries Victoria.

## Details

The statewide rate uses total Victorian library visits divided by total
population, rather than the average of individual service rates. PLV's
statewide totals include estimates for services that did not report.

## Examples

``` r
vic_visits
#> # A tibble: 3 × 2
#>   financial_year visits_per_person
#>   <chr>                      <dbl>
#> 1 2022-23                     3.05
#> 2 2023-24                     3.37
#> 3 2024-25                     3.48
```
