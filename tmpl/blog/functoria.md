
For the last two month, I have been at OCamllabs for « holidays » with the grand task
of « fixing the mirage tool ».

I'm happy to present [Functoria](https://github.com/Drup/Functoria), a library to create arbitrary mirage-like DSLs. Functoria is independent from Mirage and will replace all the core engine that was bolted on the mirage tool until now.

The bad news is that it's going to break some (little) things. To see the breaking changes and how to fix them, consult [the breaking changes page](../docs/breaking-changes).

The good news is that it will be much more simple to use and much more flexible.
And it produces pretty pictures.

## Keys

A [much][] [demanded][] [feature][] is the ability to define so-called bootvars.
Bootvars are variables which value would be set either at configure time or at
startup time.

[much]: https://github.com/mirage/mirage/issues/229
[demanded]: https://github.com/mirage/mirage/issues/228
[feature]: https://github.com/mirage/mirage/issues/231


A good example is the ip address of the http stack, you want to be able to:

- Set a good default directly in the `config.ml`
- Provide a value at configure time, if you are already aware of deployment conditions.
- Provide a value at startup time, for last minute changes.

All of this is now possible using **keys**. A key is composed of :
- _name_ : The name of the value in the program.
- _description_ : How it should be displayed/serialized.
- _stage_ : Is the key available only at runtime, at configure time or both ?
- _documentation_ : It is not optional so you should really write it.

Imagine we are building a multilingual unikernel and we want to pass the
default language as a parameter. We will use a simple string, so we can use the
predefined description `Key.Desc.string`. We want to be able to define it both
at configure and run time, so we use the stage `` `Both``. This gives us the following code:

```
let lang_key =
  let doc = Key.Doc.create
      ~doc:"The default language for the unikernel." [ "l" ; "lang" ]
  in
  Key.create ~doc ~stage:`Both ~default:"en" "language" Key.Desc.string
```

Here, We defined both a long option `--lang` and a short one `-l` (the format is similar to the one used by [Cmdliner][cmdliner]).
In the unikernel, the value is retrieved with `Bootvar_gen.language ()`.

The option is also documented in the `--help` option for both `mirage configure` (at configure time) and `./my_unikernel` (at startup time).

```
       -l VAL, --lang=VAL (absent=en)
           The default language for the unikernel.
```

[cmdliner]: http://erratique.ch/software/cmdliner

A simple example of a unikernel with a key is available in [mirage-skeleton][] in the `hello` directory.

### Switching implementation

We can do much more with keys: we can use them to switch implementation at configure time.
To illustrate, let us take the example of a dynamic storage: We want to choose between a block device and a crunch device with a command line option.
In order to do that, we must first define a boolean key:

```
let fat_key =
  let doc = Key.Doc.create
      ~doc:"Use a fat device if true, crunch otherwise." [ "fat" ]
  in
  Key.create ~doc ~stage:`Configure ~default:false "fat" Key.Desc.bool
```

We can use the `if_impl` combinator to choose between two devices depending on the value of the key.

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

It is also possible to compute on keys before giving them to `if_impl`, combining multiple keys in order to compute a value, and so on. The documentation for the API is located in the `Mirage.Key` module and various examples are available in [mirage][] and [mirage-skeleton][].

Switching keys opens various possibilities, for example a `generic_stack` combinator is now implemented in mirage that will switch between socket stack, direct stack with dhcp and direct stack with static ip, depending on command line arguments.

## Drawing unikernels

All these keys and dynamic implementations make for complicated unikernels. In order to still be able to understand what is going on and how to configure our unikernels, we have a new command: `describe`.

Let us consider the `console` example in [mirage-skeleton][]:

```
open Mirage

let main = foreign "Unikernel.Main" (console @-> job)
let () = register "console" [main $ default_console]
```

This is fairly straightforward, we define a `Unikernel.Main` functor using a console and we
instantiate it with the default console. If we execute `mirage describe --dot` in this directory, we will get the following output.

[![A console unikernel](../graphics/dot/console.svg "My little unikernel")](../graphics/dot/console.svg)

As you can see, there is already quite a few things going on!
Squares are the various devices.
The `default_console` is actually two consoles: the one on unix and the one on xen. We use the `if_impl` construction - represented as a circle node - to choose dynamically between the two.

The `bootvar` device handles the runtime key handling. It relies on an `argv` device, which is similar to `console`. Those devices are present in all unikernels.

The `mirage` device is the device that brings all the jobs together (and on the hypervisor binds them).

## Data dependencies

You may have noticed dashed lines in the previous drawing, in particular from `mirage` to `Unikernel.Main`. Those lines are data dependencies. For example, the `bootvar` device has a dependency on the `argv` device. It means that `argv` is configured and run first, returns some data - an array of string - then `bootvar` is configured and run.

If your unikernel has a data dependency - such as, for example, initializing the entropy - you can use the `~dependencies` argument on `Mirage.foreign`. The `start` function of the unikernel will receive one extra argument for each dependency.

TODO Add a *simple* example (tls is too complicated ...)

## Sharing

Since we have a way to draw unikernels, we can now observe the sharing between various pieces. For example, the direct stack with static ip yields this diagram:

[![A stack unikernel](../graphics/dot/stack.svg "My stack unikernel")](../graphics/dot/stack.svg)

You can see that all the sub-parts of the stack have been properly shared. To be merged, two devices must have the same name, keys, dependencies and functor arguments.
To force non-sharing of two devices, is is enough to give them different names.

This sharing also works up to switching keys. The dynamic stack gives us this diagram:

[![A dynamic stack unikernel](../graphics/dot/dynamic.svg "My dynamic unikernel")](../graphics/dot/dynamic.svg)

There is actually three stacks in this example: the socket stack, the direct stack with dhcp and the direct stack with ip, all controlled by switching keys.

## All your functors are belong to us

There is more to be said about the new capabilities offered by functoria, in particular on how to define new devices. You can discover them by looking at the [mirage][] implementation.

However, to wrap up this blog post, I offer you a visualization of the mirage website itself. [Enjoy](../graphics/dot/www.svg).


[mirage]: https://github.com/mirage/mirage
[mirage-skeleton]: https://github.com/mirage/mirage-skeleton
