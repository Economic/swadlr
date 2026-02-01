# List available geographies

Returns a data frame of available geographic units in the SWADL API.
This includes the national level, census regions, census divisions, and
all states plus the District of Columbia.

## Usage

``` r
swadlr_geographies()
```

## Value

A data frame with columns:

- id:

  Geography identifier (used in
  [`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md))

- level:

  Geographic level ("national", "region", "division", or "state")

- name:

  Human-readable geography name

- abbr:

  Abbreviation (state postal code, "US" for national, or NA for
  regions/divisions)

## Examples

``` r
swadlr_geographies()
#>                 id    level                 name abbr
#> 1         national national        United States   US
#> 2    regionMidwest   region              Midwest <NA>
#> 3  regionNortheast   region            Northeast <NA>
#> 4      regionSouth   region                South <NA>
#> 5       regionWest   region                 West <NA>
#> 6       division01 division          New England <NA>
#> 7       division02 division      Middle Atlantic <NA>
#> 8       division03 division   East North Central <NA>
#> 9       division04 division   West North Central <NA>
#> 10      division05 division       South Atlantic <NA>
#> 11      division06 division   East South Central <NA>
#> 12      division07 division   West South Central <NA>
#> 13      division08 division             Mountain <NA>
#> 14      division09 division              Pacific <NA>
#> 15         state01    state              Alabama   AL
#> 16         state02    state               Alaska   AK
#> 17         state04    state              Arizona   AZ
#> 18         state05    state             Arkansas   AR
#> 19         state06    state           California   CA
#> 20         state08    state             Colorado   CO
#> 21         state09    state          Connecticut   CT
#> 22         state10    state             Delaware   DE
#> 23         state11    state District of Columbia   DC
#> 24         state12    state              Florida   FL
#> 25         state13    state              Georgia   GA
#> 26         state15    state               Hawaii   HI
#> 27         state16    state                Idaho   ID
#> 28         state17    state             Illinois   IL
#> 29         state18    state              Indiana   IN
#> 30         state19    state                 Iowa   IA
#> 31         state20    state               Kansas   KS
#> 32         state21    state             Kentucky   KY
#> 33         state22    state            Louisiana   LA
#> 34         state23    state                Maine   ME
#> 35         state24    state             Maryland   MD
#> 36         state25    state        Massachusetts   MA
#> 37         state26    state             Michigan   MI
#> 38         state27    state            Minnesota   MN
#> 39         state28    state          Mississippi   MS
#> 40         state29    state             Missouri   MO
#> 41         state30    state              Montana   MT
#> 42         state31    state             Nebraska   NE
#> 43         state32    state               Nevada   NV
#> 44         state33    state        New Hampshire   NH
#> 45         state34    state           New Jersey   NJ
#> 46         state35    state           New Mexico   NM
#> 47         state36    state             New York   NY
#> 48         state37    state       North Carolina   NC
#> 49         state38    state         North Dakota   ND
#> 50         state39    state                 Ohio   OH
#> 51         state40    state             Oklahoma   OK
#> 52         state41    state               Oregon   OR
#> 53         state42    state         Pennsylvania   PA
#> 54         state44    state         Rhode Island   RI
#> 55         state45    state       South Carolina   SC
#> 56         state46    state         South Dakota   SD
#> 57         state47    state            Tennessee   TN
#> 58         state48    state                Texas   TX
#> 59         state49    state                 Utah   UT
#> 60         state50    state              Vermont   VT
#> 61         state51    state             Virginia   VA
#> 62         state53    state           Washington   WA
#> 63         state54    state        West Virginia   WV
#> 64         state55    state            Wisconsin   WI
#> 65         state56    state              Wyoming   WY

# Filter to just states
geographies <- swadlr_geographies()
geographies[geographies$level == "state", ]
#>         id level                 name abbr
#> 15 state01 state              Alabama   AL
#> 16 state02 state               Alaska   AK
#> 17 state04 state              Arizona   AZ
#> 18 state05 state             Arkansas   AR
#> 19 state06 state           California   CA
#> 20 state08 state             Colorado   CO
#> 21 state09 state          Connecticut   CT
#> 22 state10 state             Delaware   DE
#> 23 state11 state District of Columbia   DC
#> 24 state12 state              Florida   FL
#> 25 state13 state              Georgia   GA
#> 26 state15 state               Hawaii   HI
#> 27 state16 state                Idaho   ID
#> 28 state17 state             Illinois   IL
#> 29 state18 state              Indiana   IN
#> 30 state19 state                 Iowa   IA
#> 31 state20 state               Kansas   KS
#> 32 state21 state             Kentucky   KY
#> 33 state22 state            Louisiana   LA
#> 34 state23 state                Maine   ME
#> 35 state24 state             Maryland   MD
#> 36 state25 state        Massachusetts   MA
#> 37 state26 state             Michigan   MI
#> 38 state27 state            Minnesota   MN
#> 39 state28 state          Mississippi   MS
#> 40 state29 state             Missouri   MO
#> 41 state30 state              Montana   MT
#> 42 state31 state             Nebraska   NE
#> 43 state32 state               Nevada   NV
#> 44 state33 state        New Hampshire   NH
#> 45 state34 state           New Jersey   NJ
#> 46 state35 state           New Mexico   NM
#> 47 state36 state             New York   NY
#> 48 state37 state       North Carolina   NC
#> 49 state38 state         North Dakota   ND
#> 50 state39 state                 Ohio   OH
#> 51 state40 state             Oklahoma   OK
#> 52 state41 state               Oregon   OR
#> 53 state42 state         Pennsylvania   PA
#> 54 state44 state         Rhode Island   RI
#> 55 state45 state       South Carolina   SC
#> 56 state46 state         South Dakota   SD
#> 57 state47 state            Tennessee   TN
#> 58 state48 state                Texas   TX
#> 59 state49 state                 Utah   UT
#> 60 state50 state              Vermont   VT
#> 61 state51 state             Virginia   VA
#> 62 state53 state           Washington   WA
#> 63 state54 state        West Virginia   WV
#> 64 state55 state            Wisconsin   WI
#> 65 state56 state              Wyoming   WY
```
