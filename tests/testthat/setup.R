# Test setup
#
# Disable API throttling during tests. The throttle normally delays requests
# by 2 seconds to avoid overwhelming the live API, but tests use httptest2
# fixtures (mocked responses) so no actual API calls are made. The throttle
# runs before httptest2 intercepts the request, so without this setting,
# tests would still incur the delay even though no network calls occur.

options(swadlr.throttle_interval = 0)
