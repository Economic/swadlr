# List ID-name mappings for SWADL metadata

Returns a tibble of ID-name mappings for SWADL metadata. Use this to
understand what each ID represents.

## Usage

``` r
swadl_id_names(
  what = c("topics", "indicators", "measures", "dimensions", "geographies"),
  topic = NULL,
  indicator = NULL
)
```

## Arguments

- what:

  The type of metadata to list. One of:

  `"topics"`

  :   Broad categories that group related indicators

  `"indicators"`

  :   Specific data series that can be retrieved with
      [`get_swadl()`](https://economic.github.io/swadlr/reference/get_swadl.md)

  `"measures"`

  :   Ways of presenting indicator data (e.g., nominal vs real wages)

  `"dimensions"`

  :   Demographic categories for subsetting data (e.g., gender, race)

  `"geographies"`

  :   Geographic units (national, regions, divisions, states)

- topic:

  For `what = "indicators"`, optionally filter to a specific topic ID.

- indicator:

  For `what = "measures"` or `what = "dimensions"`, optionally filter to
  those available for a specific indicator ID.

## Value

A tibble. The columns depend on `what`:

- topics:

  `id`, `name`

- indicators:

  `id`, `name`, `topic_id`, `updated_date`

- measures:

  `id`, `name`, `format`

- dimensions:

  `dimension_id`, `dimension_name`, `value_id`, `value_name`

- geographies:

  `id`, `level`, `name`, `abbr`

## See also

[`swadl_indicator()`](https://economic.github.io/swadlr/reference/swadl_indicator.md)
for detailed information about a single indicator,
[`get_swadl()`](https://economic.github.io/swadlr/reference/get_swadl.md)
for fetching time series data.

## Examples

``` r
# \donttest{
# List all topics
swadl_id_names("topics")
#> # A tibble: 9 × 2
#>   id           name            
#>   <chr>        <chr>           
#> 1 labor_force  Employment      
#> 2 minimum_wage Minimum wages   
#> 3 population   Population      
#> 4 poverty      Poverty         
#> 5 prices       Prices          
#> 6 productivity Productivity    
#> 7 unions       Unions          
#> 8 wage_gaps    Wage disparities
#> 9 wages        Wages           

# List all indicators
swadl_id_names("indicators")
#> # A tibble: 36 × 4
#>    id                             name                     topic_id updated_date
#>    <chr>                          <chr>                    <chr>    <chr>       
#>  1 annual_wage_ssa                Annual wages for select… wages    2026-01-23  
#>  2 ceo_pay_ratio                  CEO pay ratio            wage_ga… 2026-01-23  
#>  3 hourly_wage_mean               Hourly wage, average     wages    2026-01-23  
#>  4 hourly_wage_median             Hourly wage, median      wages    2026-01-23  
#>  5 hourly_wage_payroll            Hourly earnings by indu… wages    2026-01-23  
#>  6 hourly_wage_percentile_ratios  Hourly wage percentile … wages    2026-01-23  
#>  7 hourly_wage_percentiles        Hourly wage percentiles  wages    2026-01-23  
#>  8 hourly_wage_gap_black_white    Black-white wage gap     wage_ga… 2026-01-23  
#>  9 hourly_wage_gap_gender         Gender wage gap          wage_ga… 2026-01-23  
#> 10 hourly_wage_gap_hispanic_white Hispanic-white wage gap  wage_ga… 2026-01-23  
#> # ℹ 26 more rows

# List indicators for a specific topic
swadl_id_names("indicators", topic = "wages")
#> # A tibble: 6 × 4
#>   id                            name                       topic_id updated_date
#>   <chr>                         <chr>                      <chr>    <chr>       
#> 1 annual_wage_ssa               Annual wages for select w… wages    2026-01-23  
#> 2 hourly_wage_mean              Hourly wage, average       wages    2026-01-23  
#> 3 hourly_wage_median            Hourly wage, median        wages    2026-01-23  
#> 4 hourly_wage_payroll           Hourly earnings by indust… wages    2026-01-23  
#> 5 hourly_wage_percentile_ratios Hourly wage percentile ra… wages    2026-01-23  
#> 6 hourly_wage_percentiles       Hourly wage percentiles    wages    2026-01-23  

# List measures for a specific indicator
swadl_id_names("measures", indicator = "hourly_wage_percentiles")
#> # A tibble: 2 × 3
#>   id             name                     format
#>   <chr>          <chr>                    <chr> 
#> 1 real_wage_2025 Real hourly wage (2025$) dollar
#> 2 nominal_wage   Nominal hourly wage      dollar

# List dimensions
swadl_id_names("dimensions")
#> # A tibble: 85 × 4
#>    dimension_id   dimension_name value_id       value_name                      
#>    <chr>          <chr>          <chr>          <chr>                           
#>  1 age_group      Age            age_16_24      16–24 years                     
#>  2 age_group      Age            age_25_54      25–54 years                     
#>  3 age_group      Age            age_55_64      55–64 years                     
#>  4 age_group      Age            age_55_plus    55+ years                       
#>  5 ces_industry   All sectors    ces_nonfarm    Total nonfarm                   
#>  6 ces_government Government     ces_fed        Federal government              
#>  7 ces_government Government     ces_government Government                      
#>  8 ces_government Government     ces_local      Local government                
#>  9 ces_government Government     ces_local_ed   Local government educational se…
#> 10 ces_government Government     ces_local_noed Local government, excluding edu…
#> # ℹ 75 more rows

# List geographies
swadl_id_names("geographies")
#> # A tibble: 65 × 4
#>    id              level    name               abbr 
#>    <chr>           <chr>    <chr>              <chr>
#>  1 national        national United States      US   
#>  2 regionMidwest   region   Midwest            NA   
#>  3 regionNortheast region   Northeast          NA   
#>  4 regionSouth     region   South              NA   
#>  5 regionWest      region   West               NA   
#>  6 division01      division New England        NA   
#>  7 division02      division Middle Atlantic    NA   
#>  8 division03      division East North Central NA   
#>  9 division04      division West North Central NA   
#> 10 division05      division South Atlantic     NA   
#> # ℹ 55 more rows
# }
```
