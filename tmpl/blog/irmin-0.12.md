Development of the [Irmin](https://github.com/mirage/irmin) Git-like data store continues (see [here](/blog/introducing-irmin) for an introduction). We are releasing [Irmin 0.12.0](https://github.com/mirage/irmin/releases/tag/0.12.0) which brings support for native file-system watchers to greatly improve the performance of watches on the datastore.

Previously, an Irmin application that wanted to use watches would setup file-system scanning/polling by doing:

```
  let () = Irmin_unix.install_dir_polling_listener 1.0
```

which would scan the `.git/refs` directory every second. This worked in practise but was unpredictably latent (if unlucky you might wait for a full second for the watch callbacks to trigger), and disk/CPU intensive as we were scanning the full storage directory every second to detect file changes.  In the cases where the store had 1000s of tags, this could easily saturate the CPU. And in case you wonder, there are increasing number of applications (such as [DataKit](https://github.com/docker/datakit)) that do create thousands of tags regularly, and [Canopy](https://github.com/engil/Canopy) that need low latency for interactive development.

In the new 0.12.0 release, you need to use:

```
   let () = Irmin_unix.set_listen_dir_hook ()
```

and the Irmin storage will do "the right thing". If you are on Linux, and have the [inotify OPAM package](https://opam.ocaml.org/packages/inotify/) installed, it will use libinotify to get notified by the kernel on every change and re-scan the whole directory. On OSX, if you have the [osx-fsevents OPAM package](https://opam.ocaml.org/packages/osx-fsevents/) installed, it will do the same thing using the OSX [FSEvents.framework](https://en.wikipedia.org/wiki/FSEvents). The portable compatibility layer between inotify and fsevents comes via the new [irmin-watcher](https://github.com/samoht/irmin-watcher/releases/tag/0.2.0) package that has been released recently as well.  This may also come in useful for other tools that require portable OCaml access to filesystem hierarchies.

