# List available topics

Returns a data frame of available topics in the SWADL API. Topics are
broad categories that group related indicators.

## Usage

``` r
swadlr_topics()
```

## Value

A data frame with columns:

- id:

  Topic identifier (used for filtering indicators)

- name:

  Human-readable topic name

## Examples

``` r
if (FALSE) { # \dontrun{
swadlr_topics()
} # }
```
