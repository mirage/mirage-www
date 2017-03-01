I am really happy to announce the release of Irmin 1.0, which fully
supports MirageOS 3.0 and which brings a simpler and yet more
expressive API. Irmin is a library for designing Git-like distributed
databases, with built-in branching, snapshoting, reverting and
auditing capabilities. With Irmin, applications can create tailored
mergeable datastructures to scale seamlessly. Applications built on
top of Irmin include [Tezos][tezos], a distributed ledger,
[Datakit][datakit], a distributed and reactive key-value store, and
[cuekeeper][cuekeeper], a web-based GTD system.

[tezos]:
[datakit]:
[cuekeeper]:

The running example in this post will be an imaginary model for
collecting distributed metrics (for instance to count network
packets). In this model, every node has a unique ID, and uses Irmin to
store its name and counters. Every node is also a distributed
collector and can sync with the metrics of other nodes at various
points in time. Clients can collect metrics for the network from any
node. We want the metrics to be eventually consistent.
This post will describe:

- how to define the metrics as a mergeable data-structures;
- how to create a new Irmin store with the metrics, the basic
  operations that are available and how to define atomic operations;
- how to create and merge branches; and
- how to sync with remote stores.

### Mergeable Contents

Irmin now exposes `Irmin.Type` to create new mergeable contents more
easily. For instance, the following type defines the property of simple
metrics, where `name` is a human-readable name and `gauge` is a metric counting
the number of occurences for some kind of event:

```ocaml
type metric = {
  name : string;
  gauge: int;
}
```

First of all, we need to reflect the structure of the type, to
automatically derive serialization (to and from JSON) functions:

```ocaml
let metric_t =
  let open Irmin.Type in
  record "metric" (fun name gauge -> { name; gauge })
  |+ field "name"  string (fun t -> t.name)
  |+ field "gauge" int    (fun t -> t.gauge)
  |> sealr
```

(* TODO: describe what |+ does? *)

All of the types in Irmin have such a description, so they can be
easily and efficiently serialized (to disk and/or over the
network). For instance, to print a value of type `metric` as a JSON object,
one can do:

```ocaml
let print m = Fmt.pr "%a\n%!" (Irmin.Type.pp_json metric_t) m
```

Once this is defined, we now need to write the merge function. The
consistency model that we want to define is the following:

- `name` : can change if there is no conflicts between branches.
- `gauge`: the number of events seen on a branch. Can be updated
  either by incrementing the number (because events occured) or
  by syncing with other nodes partial knowledge. This is very
  similar to [CRDT counters][TODO link] (and related [vector clock based
  datatypes][TODO link]). The main difference in Irmin is that we keep the
  state as simple as possible: `int`, but we attach a
  3-way merge function for updates to it.

(* MCP: I got lost here, maybe -- the function (fun t -> t.gauge) is a merge
function for int, and it's also required so that we can define a larger merge
function for the record at large, right?  So we define that and get merge functions
for the record type, and then we're going to use the record type merge function
to derive one for pairs? *)

Similarly to the type definitions, the 3-way merge functions can
defined using "merge" combinators. Merge combinators for records are
not yet available, so we need to use `Irmin.Merge.like` to map the
record definition to a pair:

```ocaml
let merge =
  let open Irmin.Merge in
  like metric_t (pair string counter)
    (fun x -> x.name, x.gauge)
    (fun (name, gauge) -> {name; gauge })
  |> option
```

The final step to define a mergeable data-structure is to wrap
everything into a module satisfying the [Irmin.Contents.S](TODO)
signature:

```ocaml
module Metric: Irmin.Contents.S with type t = metric = struct
  type t = metric
  let t = metric_t
  let merge = merge
  let pp = Irmin.Type.pp_json metric_t
  let of_string s = Irmin.Type.decode_json metric_t (Jsonm.decoder (`String s))
end
```

### Creating an Irmin Store

To create a key/value store to store metrics, using the on-disk Git
format:

```ocaml
module Store = Irmin_unix.Git.FS.KV(Metric)
let config = Irmin_git.config "/tmp/irmin"
let info fmt = Irmin_unix.info ~author:"Thomas" fmt
```

`config` is used to configure Irmin repositories based on `Store`. In
that example we decided to keep the store state in `/tmp/irmin` (which
can be inspected using the usual Git tools). `info` is the function
used to create new commit information: `Irmin_unix.info` use the usual
POSIX clock for timestamps, and can also be tweaked to specify the
author name.

(* MCP: I think "a manipulated Irmin store" below should probably be just
"an Irmin store", although perhaps I misunderstand something?  If there are some
special properties of a Store being referred to, which other Irmin repositories
might not have, it would be useful to mention that more? *)

`Store` [exposes](TODO) various functions to create a manipulated
Irmin store. The most common ones are `Store.Repo.create` to create an
Irmin repository and `Store.master` to get a handler on the `master`
branch in that repository. For instance, using the OCaml toplevel:

```ocaml
# open Lwt.Infix

# let repo = Store.Repo.v config;;
val repo : Store.Repo.t Lwt.t = <abstr>
# let master = repo >>= fun repo -> Store.master repo;;
val master : Store.t Lwt.t = <abstr>
```

`Store` exposes the usual [key/value operations](TODO) using `find`
and `update`. All the operations are reflected as Git state.

```ocaml
  Lwt_main.run begin
      master >>= fun master ->
      Store.set master
        ~info:(info "Creating a new metric")
        ["vm"; "writes"] { name = "write Kb/s"; gauge = 0 }
      >>= fun () ->
      Store.get master ["vm"; "writes"] >|= fun m ->
      assert (m.gauge = 0);
    end

```

`Store.set` is atomic: the implementation ensures that no data is ever
lost, and if someone else is writing on the same path at the same, the
operation is retried until it succeeds (see
[optimistic transaction control](TODO)). More complex atomic
operations are also possible, using trees. Trees are very efficient:
all the reads are cached in memory, and write on disk are only done
when needed (e.g. where the transaction is commited). Trees are also
stored very efficiently in memory and on-disk as they are immutable
and deduplicated. An example of a transaction is a custom-defined
move function:

(* MCP: I didn't understand the relationship between the keys/values and the
tree operations :( *)

```ocaml
let move t src dst =
  Store.with_tree t
    ~info:(info "Moving %a to %a" Store.Key.pp src Store.Key.pp dst)
    [] (fun tree ->
          Store.Tree.find_tree tree src >>= fun v ->
          Store.Tree.remove tree src >>= fun tree ->
          Store.Tree.add_tree tree dst v
    )
```

### Creating and Merging Branches

They are two kinds of stores in Irmin: permanent and temporary
ones. In Git-speak, these are "branches" and "detached
heads". Permanent stores are created from branch names using
`Store.of_branch` (`Store.master` being an alias to `Store.of_branch
Store.Branch.master`) while temporary stores are created from commit
using `Store.of_commit`.

The following example show how to clone the master branch, how to make
concurrent update to both branches, and how to merge them back.

First, let's define an helper function to increment the `/vm/writes`
gauge in a store `t`, using a transaction:

```ocaml
let incr t =
  let path = ["vm"; "writes"] in
  Store.with_tree ~info:(info "New write event") t path (fun tree ->
      (Store.Tree.find tree [] >|= function
        | None   -> { name = "writes in kb/s"; gauge = 0 }
        | Some x -> { x with gauge = x.gauge + 1 })
      >>= fun m ->
      Store.Tree.add tree [] m
    )
```

Then, the following program create an empty gauge on `master`,
increment the metrics, then create a `tmp` branch by cloning
`master`. It then performs two increments in parallel in both
branches, and finally merge `tmp` back into `master`. The result is a
gauge which have been incremented three times in total: the "counter" merge
function ensures that the result counter is consistent: (TODO add link
to KC's blog post.)


```ocaml
let () =
  Lwt_main.run begin
    master >>= fun master ->  (* gauge = 0 *)
    incr master >>= fun () -> (* gauge = 1 *)
    Store.clone ~src:master ~dst:"tmp" >>= fun tmp ->
    incr master >>= fun () -> (* gauge = 2 on master *)
    incr tmp    >>= fun () -> (* gauge = 2 on tmp *)
    Store.merge ~info:(info "Merge tmp into master") tmp ~into:master
    >>= function
    | Error (`Conflict e) -> failwith e
    | Ok () ->
      Store.get master ["vm"; "writes"] >|= fun m ->
      Fmt.pr "Gauge is %d\n%!" m.gauge
  end
```

### Node Sync

So far we have seen only local operations. The Irmin API also have
function to perform explicit remote syncs.

TODO
