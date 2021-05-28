## New release

To make and publish new docker images on docker hub, maintainers should create branch under `apisix-docker` repo with specific name.

For apisix and dashboard new version, the branch name should use prefix `release/apisix` and `release/dashboard` separately (e.g. `release/apisix-2.6`, `release/dashboard-2.6`). Remember to delete the release branch after the new images published, since the branch would got no use afterwards.
