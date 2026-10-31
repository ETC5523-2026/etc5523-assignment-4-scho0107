# Plot one library service against Victoria over time

Draws a line chart of library visits per resident for the chosen library
service (blue) and for Victoria as a whole (grey, dashed) from 2022-23
to 2024-25. Years with no reported data are not drawn, so a service with
only one reported year appears as a single point.

## Usage

``` r
plot_visits(service)
```

## Arguments

- service:

  Name of a library service in `library_visits`, for example `"Yarra"`.

## Value

A ggplot object.

## Examples

``` r
plot_visits("Yarra")
```
