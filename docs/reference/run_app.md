# Launch the library visits app

Opens a Shiny app for comparing Victorian public library services with
the statewide visits per resident benchmark.

## Usage

``` r
run_app()
```

## Value

No return value. Called to start the app.

## Details

The app uses the
[library_visits](https://etc5523-2026.github.io/etc5523-assignment-4-scho0107/reference/library_visits.md)
and
[vic_visits](https://etc5523-2026.github.io/etc5523-assignment-4-scho0107/reference/vic_visits.md)
datasets included in the package, so no separate data download is
needed.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
