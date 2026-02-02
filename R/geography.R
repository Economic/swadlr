# Geography resolution utilities

# Resolve a user-supplied geography input to an API ID
#
# @param geography A geography specification (name, abbreviation, or API ID)
# @return The API ID for the geography
# @examples
# resolve_geography("California")    # "state06"
# resolve_geography("CA")            # "state06"
# resolve_geography("state06")       # "state06"
# resolve_geography("Midwest")       # "regionMidwest"
# resolve_geography("Pacific")       # "division09"
# resolve_geography("national")      # "national"
# resolve_geography("US")            # "national"
resolve_geography <- function(geography) {
  if (
    !is.character(geography) || length(geography) != 1 || nchar(geography) == 0
  ) {
    stop("`geography` must be a non-empty character string.", call. = FALSE)
  }

  lookup <- swadlr_geography_lookup
  geo_lower <- tolower(geography)

  # Try exact match on id (case-insensitive)
  id_match <- lookup$id[tolower(lookup$id) == geo_lower]
  if (length(id_match) == 1) {
    return(id_match)
  }

  # Try exact match on name (case-insensitive)
  name_match <- lookup$id[tolower(lookup$name) == geo_lower]
  if (length(name_match) == 1) {
    return(name_match)
  }

  # Try exact match on abbreviation (case-insensitive)
  abbr_match <- lookup$id[
    !is.na(lookup$abbr) & tolower(lookup$abbr) == geo_lower
  ]
  if (length(abbr_match) == 1) {
    return(abbr_match)
  }

  # No match found - provide helpful error message
  suggest_geography_error(geography, lookup)
}

# Generate a helpful error message with suggestions for invalid geography
suggest_geography_error <- function(geography, lookup) {
  geo_lower <- tolower(geography)

  # Find similar matches using agrep (approximate string matching)
  name_indices <- agrep(geo_lower, tolower(lookup$name), max.distance = 0.3)
  name_suggestions <- lookup$name[name_indices]

  # For abbreviations, filter to non-NA first
  abbr_lookup <- lookup[!is.na(lookup$abbr), ]
  abbr_indices <- agrep(
    geo_lower,
    tolower(abbr_lookup$abbr),
    max.distance = 0.3
  )
  abbr_suggestions <- abbr_lookup$abbr[abbr_indices]

  suggestions <- unique(c(name_suggestions, abbr_suggestions))
  suggestions <- suggestions[!is.na(suggestions)]

  if (length(suggestions) > 0) {
    suggestions <- suggestions[seq_len(min(5, length(suggestions)))]
    stop(
      "Unknown geography: \"",
      geography,
      "\"\n",
      "Did you mean: ",
      paste(suggestions, collapse = ", "),
      "?",
      call. = FALSE
    )
  } else {
    stop(
      "Unknown geography: \"",
      geography,
      "\"\n",
      'Use swadl_id_names("geographies") to see available geographies.',
      call. = FALSE
    )
  }
}
