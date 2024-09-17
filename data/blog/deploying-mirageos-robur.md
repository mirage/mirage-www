---
updated: 2022-03-08
authors:
- name: Rand
  uri: https://r7p5.earth
- name: Reynir Björnsson
  uri: https://reynir.dk
- name: Hannes Mehnert
  uri: https://hannes.robur.coop
subject: Deploying MirageOS unikernels using binaries
permalink: deploying-mirageos-robur
---

We are pleased to announce that the EU [NGI Pointer](https://pointer.ngi.eu) funding received by [robur](https://robur.coop) in 2021 lead to improved operations for MirageOS unikernels.

Our main achievement are [reproducible binary builds](https://builds.robur.coop) of opam packages, including MirageOS unikernels and system packages. The infrastructure behind it, [orb](https://github.com/robur-coop/orb), [builder](https://github.com/robur-coop/builder), [builder-web](https://github.com/robur-coop/builder-web) is itself reproducible and delivered as packages by [builds.robur.coop](https://builds.robur.coop).

The documentation how to get started [installing MirageOS unikernels and albatross from packages](https://robur.coop/Projects/Reproducible_builds) is available online, further documentation on [monitoring](https://hannes.robur.coop/Posts/Monitoring) is available as well.

The funding proposal covered the parts (as outlined in [an earlier post from 2020](https://hannes.robur.coop/Posts/NGI)):
* reproducible binary releases of MirageOS unikernels,
* monitoring (and other devops features: profiling) and integration into existing infrastructure,
* and further documentation and advertisement.

We [announced the web interface earlier](https://discuss.ocaml.org/t/ann-robur-reproducible-builds/8827) and also [posted about deployment](https://hannes.robur.coop/Posts/Deploy) possibilities.

At the heart of our infrastructure is [builder-web](https://github.com/robur-coop/builder-web), a database that receives binary builds and provides a web interface and binary package repositories ([apt.robur.coop](https://apt.robur.coop) and [pkg.robur.coop](https://pkg.robur.coop)). Reynir discusses the design and implementation of [builder-web](https://github.com/robur-coop/builder-web) in [his blogpost](https://reyn.ir/posts/2022-03-08-builder-web.html).

There we [visualize](https://builds.robur.coop/job/tlstunnel/build/7f0afdeb-0a52-4de1-b96f-00f654ce9249/) the opam dependencies of an opam package:

<iframe src="../graphics/tlstunnel-deps.html" title="Opam dependencies" style="
      width: 45em;
      height: 45.4em;
      max-width: 100%;
      max-height: 49vw;
      min-width: 38em;
      min-height: 40em;
     "></iframe>

We also visualize the contributing modules and their sizes to the binary:

<iframe src="../graphics/tlstunnel-treemap.html" title="Binary dissection" style="
      width: 46em;
      height: 48.4em;
      max-width: 100%;
      max-height: 52vw;
      min-width: 38em;
      min-height: 43em;
    "></iframe>

Rand wrote a more in-depth explanation about the [visualizations](https://builds.robur.coop/job/tlstunnel/build/7f0afdeb-0a52-4de1-b96f-00f654ce9249/) [on his blog](https://r7p5.earth/blog/2022-3-7/Builder-web%20visualizations%20at%20Robur).

If you've comments or are interested in deploying MirageOS unikernels at your organization, [get in touch with us](https://robur.coop/Contact).
