---
updated: 2013-12-25 22:00
author:
  name: Amir Chaudhry
  uri: http://amirchaudhry.com
  email: amirmc@gmail.com
subject: Deploying via Continuous Integration
permalink: deploying-via-ci
---

This live MirageOS website is written as a MirageOS application itself, with the
source code on [mirage/mirage-www](https://github.com/mirage/mirage-www) on
GitHub. Our workflow is such that we can send a
[pull request](https://github.com/mirage/mirage-www/pulls?direction=desc&page=1&sort=created&state=closed)
to update the website, and have a fully standalone unikernel
deployed at <https://mirage.io/>.

See <https://github.com/ocurrent/ocurrent-deployer> for the deployment pipeline.

