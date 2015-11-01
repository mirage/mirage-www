For the last few months, I've been working with [Thomas][] on improving the `mirage` tool and
I'm happy to present [Functoria](https://github.com/mirage/functoria), a library to create arbitrary Mirage-like DSLs. Functoria is independent from `mirage` and will replace the core engine, which was somewhat bolted on to the tool until now.

This introduces a few breaking changes so please consult
[the breaking changes page](../docs/breaking-changes) to see what is different and how to fix things if needed.
The good news is that it will be much more simple to use, much more flexible,
and will even produce pretty pictures!

## Configuration

For people unfamiliar with mirage, the `mirage` tool handles configuration of mirage unikernel by reading an OCaml file describing the various pieces and dependencies of the project.
Based on this configuration it will use [opam][] to install the dependencies, handle various configuration tasks and emit a build script.

A very simple configuration file look like this:

```
open Mirage
let main = foreign "Unikernel.Main" (console @-> job)
let () = register "console" [main $ default_console]
```

It declares a new functor, `Unikernel.Main`, which take a console as argument and instantiate it on the `default_console`. For more details about unikernel configuration, please read the [hello-world](../wiki/hello-world) tutorial.

## Keys

A [much][] [demanded][] [feature][] has been the ability to define so-called bootvars.
Bootvars are variables whose value is set either at configure time or at
startup time.

[much]: https://github.com/mirage/mirage/issues/229
[demanded]: https://github.com/mirage/mirage/issues/228
[feature]: https://github.com/mirage/mirage/issues/231


A good example of a bootvar would be the IP address of the HTTP stack. For example, you may wish to:

- Set a good default directly in the `config.ml`
- Provide a value at configure time, if you are already aware of deployment conditions.
- Provide a value at startup time, for last minute changes.

All of this is now possible using **keys**. A key is composed of:
- _name_ — The name of the value in the program.
- _description_ — How it should be displayed/serialized.
- _stage_ — Is the key available only at runtime, at configure time, or both?
- _documentation_ — This is not optional, so you have to write it.

Imagine we are building a multilingual unikernel and we want to pass the
default language as a parameter. The language parameter is an optional string, so we use the [`opt`][API_arg_opt] and [`string`][API_arg_string] combinators. We want to be able to define it both
at configure and run time, so we use the stage `` `Both``. This gives us the following code:

[API_arg_opt]: http://mirage.github.io/functoria/Functoria_key.Arg.html#VALopt
[API_arg_string]: http://mirage.github.io/functoria/Functoria_key.Arg.html#VALstring

```
let lang_key =
  let doc = Key.Arg.info
      ~doc:"The default language for the unikernel." [ "l" ; "lang" ]
  in
  Key.(create "language" Arg.(opt ~stage:`Both string "en" doc))
```

Here, we defined both a long option `--lang` and a short one `-l` (the format is similar to the one used by [Cmdliner][cmdliner]).
In the unikernel, the value is retrieved with `Key_gen.language ()`.

The option is also documented in the `--help` option for both `mirage configure` (at configure time) and `./my_unikernel` (at startup time).

```
       -l VAL, --lang=VAL (absent=en)
           The default language for the unikernel.
```

[cmdliner]: http://erratique.ch/software/cmdliner

A simple example of a unikernel with a key is available in [mirage-skeleton][] in the [`hello` directory][mirage-skeleton-hello].

### Switching implementation

We can do much more with keys, for example we can use them to switch devices at configure time.
To illustrate, let us take the example of dynamic storage, where we want to choose between a block device and a crunch device with a command line option.
In order to do that, we must first define a boolean key:

```
let fat_key =
  let doc = Key.Arg.info
      ~doc:"Use a fat device if true, crunch otherwise." [ "fat" ]
  in
  Key.(create "fat" Arg.(opt ~stage:`Configure bool false doc))
```

We can use the [`if_impl`][API_if] combinator to choose between two devices depending on the value of the key.

[API_if]: http://mirage.github.io/functoria/Functoria.html#VALif_impl

```
let dynamic_storage =
  if_impl (Key.value fat_key)
    (kv_ro_of_fs my_fat_device)
    (my_crunch_device)
```

We can now use this device as a normal storage device of type `kv_ro impl`! The key is also documented in `mirage configure --help`:

```
       --fat=VAL (absent=false)
           Use a fat device if true, crunch otherwise.
```

It is also possible to compute on keys before giving them to `if_impl`, combining multiple keys in order to compute a value, and so on. For more details, see the [API][] and the various examples available in [mirage][] and [mirage-skeleton][].

Switching keys opens various possibilities, for example a `generic_stack` combinator is now implemented in `mirage` that will switch between socket stack, direct stack with DHCP and direct stack with static IP, depending on command line arguments.

## Drawing unikernels

All these keys and dynamic implementations make for complicated unikernels. In order to still be able to understand what is going on and how to configure our unikernels, we have a new command: `describe`.

Let us consider the `console` example in [mirage-skeleton][]:

```
open Mirage

let main = foreign "Unikernel.Main" (console @-> job)
let () = register "console" [main $ default_console]
```

This is fairly straightforward: we define a `Unikernel.Main` functor using a console and we
instantiate it with the default console. If we execute `mirage describe --dot` in this directory, we will get the following output.

[![A console unikernel](../graphics/dot/console.svg "My little unikernel")](../graphics/dot/console.svg)

As you can see, there are already quite a few things going on!
Rectangles are the various devices and you'll notice that
the `default_console` is actually two consoles: the one on Unix and the one on Xen. We use the `if_impl` construction — represented as a circular node — to choose between the two during configuration.

The `key` device handles the runtime key handling. It relies on an `argv` device, which is similar to `console`. Those devices are present in all unikernels.

The `mirage` device is the device that brings all the jobs together (and on the hypervisor binds them).

## Data dependencies

You may have noticed dashed lines in the previous diagram, in particular from `mirage` to `Unikernel.Main`. Those lines are data dependencies. For example, the `bootvar` device has a dependency on the `argv` device. It means that `argv` is configured and run first, returns some data — an array of string — then `bootvar` is configured and run.

If your unikernel has a data dependency — say, initializing the entropy — you can use the `~deps` argument on `Mirage.foreign`. The `start` function of the unikernel will receive one extra argument for each dependency.

As an example, let us look at the [`app_info`][API_app_info] device. This device makes the configuration information available at runtime. We can declare a dependency on it:

```
let main =
  foreign "Unikernel.Main" ~deps:[abstract app_info] (console @-> job)
```

[![A unikernel with info](../graphics/dot/info.svg "My informed unikernel")](../graphics/dot/info.svg)

The only difference with the previous unikernel is the data dependency — represented by a dashed arrow — going from `Unikernel.Main` to `Info_gen`. This means that `Unikernel.Main.start` will take an extra argument of type `Mirage_info.t` which we can, for example, print:

```
name: console
libraries: [functoria.runtime; lwt.syntax; mirage-console.unix;
            mirage-types.lwt; mirage.runtime; sexplib]
packages: [functoria.0.1; lwt.2.5.0; mirage-console.2.1.3; mirage-unix.2.3.1;
           sexplib.113.00.00]
```

The complete example is available in [mirage-skeleton][] in the [`app_info` directory][mirage-skeleton-info].


[Api_app_info]: http://mirage.github.io/functoria/Functoria_app.html#VALapp_info

## Sharing

Since we have a way to draw unikernels, we can now observe the sharing between various pieces. For example, the direct stack with static IP yields this diagram:

[![A stack unikernel](../graphics/dot/stack.svg "My stack unikernel")](../graphics/dot/stack.svg)

You can see that all the sub-parts of the stack have been properly shared. To be merged, two devices must have the same name, keys, dependencies and functor arguments.
To force non-sharing of two devices, it is enough to give them different names.

This sharing also works up to switching keys. The generic stack gives us this diagram:

[![A dynamic stack unikernel](../graphics/dot/dynamic.svg "My generic unikernel")](../graphics/dot/dynamic.svg)

If you look closely, you'll notice that there are actually _three_ stacks in the last example: the _socket_ stack, the _direct stack with DHCP_, and the _direct stack with IP_. All controlled by switching keys.

## All your functors are belong to us

There is more to be said about the new capabilities offered by functoria, in particular on how to define new devices. You can discover them by looking at the [mirage][] implementation.

However, to wrap up this blog post, I offer you a visualization of the MirageOS website itself (brace yourself). [Enjoy!](../graphics/dot/www.svg)

[opam]: http://opam.ocaml.org/
[API]: http://mirage.github.io/functoria/
[mirage]: https://github.com/mirage/mirage
[mirage-skeleton]: https://github.com/mirage/mirage-skeleton
[mirage-skeleton-hello]: https://github.com/mirage/mirage-skeleton/tree/master/hello
[mirage-skeleton-info]: https://github.com/mirage/mirage-skeleton/tree/master/app_info

*Thanks to [Mort][], [Mindy][], [Amir][] and [Jeremy][]
for their comments on earlier drafts.*

[Mort]: http://mort.io
[Mindy]: http://somerandomidiot.com
[Thomas]: http://www.gazagnaire.org
[Amir]: http://amirchaudhry.com
[Jeremy]: https://github.com/yallop
