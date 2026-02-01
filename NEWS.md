# swadlr 0.0.0.9000 (development version)

* Initial development version of swadlr.

* `get_swadl_info()` returns detailed information about an indicator, including available measures, dimensions, date ranges, and geographic availability.

* `get_swadl_series()` fetches time series data for a specified indicator, measure, geography, and dimension combination. Supports flexible dimension syntax for filtering and cross-tabulating data.

* `swadlr_clear_cache()` clears the session cache of API metadata.

* `swadlr_dimensions()` lists available dimensions and their values, optionally filtered by indicator.

* `swadlr_geographies()` lists available geographic units (national, regions, divisions, and states).

* `swadlr_indicators()` lists available indicators, optionally filtered by topic.

* `swadlr_measures()` lists available measures, optionally filtered by indicator.

* `swadlr_topics()` lists available topics.
