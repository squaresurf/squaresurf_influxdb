squaresurf_influxdb CHANGELOG
============================

This file is used to list changes made in each version of the
squaresurf_influxdb cookbook.

v1.1.0
------
- [squaresurf] Updates database creation to allow setting options such as the
  retention policy.

v1.0.0
------
- [squaresurf] Updates the default config attributes for InfluxDB version
  0.8.6.

v0.1.4
------
- [squaresurf] Updates the configure recipe to be more efficient and ensures
  that the config files have the correct user and group.
- [squaresurf] Simplifies the SquaresurfInfluxDB::ClusterAdmin.client.

v0.1.3
------
- [squaresurf] Removes unnecessary files.
- [squaresurf] Adds documentation about the client_retries attribute.
- [squaresurf] Fixes issue where we incorrectly get a cluster admin client.
- [squaresurf] Ensure that we don't incorrectly delete the root cluster admin.
- [squaresurf] Up the number of default client retries to 20.

v0.1.2
------
- [squaresurf] Adds supported platform to the metadata.

v0.1.1
------
- [squaresurf] Fix typos in README.md.

v0.1.0
-----
- [squaresurf] Initial version for the squaresurf_influxdb cookbook.
