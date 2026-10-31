# Compare one library service with Victoria

Compares a library service's visits per resident with the Victorian
statewide rate for each financial year from 2022-23 to 2024-25. It also
calculates the difference and the service's rank each year.

## Usage

``` r
compare_visits(service)
```

## Arguments

- service:

  Name of a library service in `library_visits`, for example `"Yarra"`.

## Value

A data frame with one row per financial year and the columns
`library_service`, `financial_year`, `visits_per_person`,
`vic_visits_per_person` (statewide rate), `difference` (service minus
Victoria), `rank` (1 = highest visits per resident), `n_services`
(number of ranked services) and `reported`.

## Details

The statewide rate is total Victorian visits divided by total
population, not the average of individual service rates.

Only services that reported data are ranked. Missing years have `NA` for
visits per resident, difference and rank.

## Examples

``` r
compare_visits("Yarra")
#> # A tibble: 3 × 8
#>   library_service financial_year visits_per_person vic_visits_per_person
#>   <chr>           <chr>                      <dbl>                 <dbl>
#> 1 Yarra           2022-23                     5.74                  3.05
#> 2 Yarra           2023-24                     6.13                  3.37
#> 3 Yarra           2024-25                     6.21                  3.48
#> # ℹ 4 more variables: difference <dbl>, rank <int>, n_services <int>,
#> #   reported <lgl>

# Towong did not report in 2022-23 or 2023-24
compare_visits("Towong")
#> # A tibble: 3 × 8
#>   library_service financial_year visits_per_person vic_visits_per_person
#>   <chr>           <chr>                      <dbl>                 <dbl>
#> 1 Towong          2022-23                    NA                     3.05
#> 2 Towong          2023-24                    NA                     3.37
#> 3 Towong          2024-25                     1.91                  3.48
#> # ℹ 4 more variables: difference <dbl>, rank <int>, n_services <int>,
#> #   reported <lgl>
```
