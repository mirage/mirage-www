---
updated: 2017-03-06
authors:
- name: Thomas Gazagnaire
  uri: http://gazagnaire.org
  email: thomas@gazagnaire.org
subject: Easy distributed analytics with Irmin 1.0
permalink: irmin-1.0
---

I am really happy to announce the release of Irmin 1.0, which fully
supports MirageOS 3.0 and which brings a simpler and yet more
expressive API. Irmin is a library for designing Git-like distributed
databases, with built-in branching, snapshoting, reverting and
auditing capabilities. With Irmin, applications can create tailored
mergeable datastructures to scale seamlessly. Applications built on
top of Irmin include [Tezos][tezos], a distributed ledger,
[Datakit][datakit], a distributed and reactive key-value store, and
[cuekeeper][cuekeeper], a web-based GTD system. Read ["Introducing
Irmin: Git-like distributed, branchable storage"][architecture] for a
description of the concepts and high-level architecture of the system.

[tezos]: https://tezos.com/
[datakit]: https://github.com/docker/datakit
[cuekeeper]: https://github.com/talex5/cuekeeper
[architecture]: /blog/introducing-irmin

To install Irmin 1.0:

```
opam install irmin
```

The running example in this post will be an imaginary model for
collecting distributed metrics (for instance to count network
packets). In this model, every node has a unique ID, and uses Irmin to
store metrics names and counters. Every node is also a distributed
collector and can sync with the metrics of other nodes at various
points in time. Users of the application can read metrics for the
network from any node. We want the metrics to be eventually
consistent.

This post will describe:

- how to define the metrics as a mergeable data-structures;
- how to create a new Irmin store with the metrics, the basic
  operations that are available and how to define atomic operations; and
- how to create and merge branches.

### Mergeable Contents

Irmin now exposes `Irmin.Type` to create new mergeable contents more
easily. For instance, the following type defines the property of
simple metrics, where `name` is a human-readable name and `gauge` is a
metric counting the number of occurences for some kind of event:

```ocaml
type metric = {
  name : string;
  gauge: int64;
}
```

First of all, we need to reflect the structure of the type, to
automatically derive serialization (to and from JSON, binary encoding,
etc) functions:

```ocaml
let metric_t =
  let open Irmin.Type in
  record "metric" (fun name gauge -> { name; gauge })
  |+ field "name"  string (fun t -> t.name)
  |+ field "gauge" int64    (fun t -> t.gauge)
  |> sealr
```

`record` is used to describe a new (empty) record with a name and a
constructor; `field` describes record fields with a name a type and an
accessor function while `|+` is used to stack fields into the
record. Finally `|> sealr` seals the record, e.g. once applied no more
fields can be added to it.

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
  either by incrementing the number (because events occured) or by
  syncing with other nodes partial knowledge. This is very similar to
  [conflict-free replicated datatypes][CRDT] and related
  [vector-clock][vc] based algorithms. However, in Irmin we keep the
  actual state as simple as possible: for counters, it is a single
  integer -- but the user needs to provide an external 3-way merge
  function to be used during merges.

[CRDT]: https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type
[vc]: https://en.wikipedia.org/wiki/Vector_clock

Similarly to the type definitions, the 3-way merge functions can
defined using "merge" combinators. Merge combinators for records are
not yet available (but they are planned on the roadmap), so we need to
use `Irmin.Merge.like` to map the record definition to a pair:

```ocaml
let merge =
  let open Irmin.Merge in
  like metric_t (pair string counter)
    (fun x -> x.name, x.gauge)
    (fun (name, gauge) -> {name; gauge })
  |> option
```

The final step to define a mergeable data-structure is to wrap
everything into a module satisfying the [Irmin.Contents.S][Contents]
signature:

[Contents]: http://mirage.github.io/irmin/Irmin.Contents.S.html

```ocaml
module Metric: Irmin.Contents.S with type t = metric = struct
  type t = metric
  let t = metric_t
  let merge = merge
  let pp = Irmin.Type.pp_json metric_t
  let of_string s =
    Irmin.Type.decode_json metric_t (Jsonm.decoder (`String s))
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

`Store` [exposes][API] various functions to create and manipulate
Irmin stores. `config` is used to configure Irmin repositories based
on `Store`. In that example we decided to keep the store state in
`"/tmp/irmin"` (which can be inspected using the usual Git
tools). `info` is the function used to create new commit information:
`Irmin_unix.info` use the usual POSIX clock for timestamps, and can
also be tweaked to specify the author name.

[API]: http://mirage.github.io/irmin/Irmin.S.html

The most common functions to create an Irmin store are
`Store.Repo.create` to create an Irmin repository and `Store.master`
to get a handler on the `master` branch in that repository. For
instance, using the OCaml toplevel:

```ocaml
# open Lwt.Infix;;

# let repo = Store.Repo.v config;;
val repo : Store.Repo.t Lwt.t = <abstr>
# let master = repo >>= fun repo -> Store.master repo;;
val master : Store.t Lwt.t = <abstr>
```

`Store` also exposes the usual key/value base operations using
[find](http://mirage.github.io/irmin/Irmin.S.html#VALfind) and
[set](http://mirage.github.io/irmin/Irmin.S.html#VALset). All the
operations are reflected as Git state.

```ocaml
  Lwt_main.run begin
      Store.Repo.v config >>= Store.master >>= fun master ->
      Store.set master
        ~info:(info "Creating a new metric")
        ["vm"; "writes"] { name = "write Kb/s"; gauge = 0L }
      >>= fun () ->
      Store.get master ["vm"; "writes"] >|= fun m ->
      assert (m.gauge = 0L);
    end
```

Note that `Store.set` is atomic: the implementation ensures that no
data is ever lost, and if someone else is writing on the same path at
the same, the operation is retried until it succeeds (see [optimistic
transaction control][OCC]). More complex atomic operations are also
possible: the API also exposes function to read and write subtrees
(simply called trees) instead of single values. Trees are very
efficient: they are immutable so all the reads are cached in memory
and done only when really needed; and write on disk are only done the
final transaction is commited. Trees are also stored very efficiently
in memory and on-disk as they are deduplicated. For users of previous
releases of Irmin: trees replaces the concept of views, but have a
very implementation and usage.

[OCC]: https://en.wikipedia.org/wiki/Optimistic_concurrency_control

An example of a tree transaction is a custom-defined move function:

```ocaml
let move t src dst =
  Store.with_tree t
    ~info:(info "Moving %a to %a" Store.Key.pp src Store.Key.pp dst)
    [] (fun tree ->
          let tree = match tree with
            | None -> Store.Tree.empty
            | Some tree -> tree
          in
          Store.Tree.get_tree tree src >>= fun v ->
          Store.Tree.remove tree src >>= fun _ ->
          Store.Tree.add_tree tree dst v >>= Lwt.return_some
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
      let tree = match tree with
        | None -> Store.Tree.empty
        | Some tree -> tree
      in
      (Store.Tree.find tree [] >|= function
        | None   -> { name = "writes in kb/s"; gauge = 0L }
        | Some x -> { x with gauge = Int64.succ x.gauge })
      >>= fun m ->
      Store.Tree.add tree [] m
      >>= Lwt.return_some
    )
```

Then, the following program create an empty gauge on `master`,
increment the metrics, then create a `tmp` branch by cloning
`master`. It then performs two increments in parallel in both
branches, and finally merge `tmp` back into `master`. The result is a
gauge which have been incremented three times in total: the "counter"
merge function ensures that the result counter is consistent: see
[KC's blog post][KC] for more details about the semantic of recursive
merges.

[KC]: http://kcsrk.info/ocaml/irmin/crdt/2017/02/15/an-easy-interface-to-irmin-library/

```ocaml
let () =
  Lwt_main.run begin
    Store.Repo.v config >>= Store.master >>= fun master -> (* guage 0 *)
    incr master >>= fun () -> (* gauge = 1 *)
    Store.clone ~src:master ~dst:"tmp" >>= fun tmp ->
    incr master >>= fun () -> (* gauge = 2 on master *)
    incr tmp    >>= fun () -> (* gauge = 2 on tmp *)
    Store.merge ~info:(info "Merge tmp into master") tmp ~into:master
    >>= function
    | Error (`Conflict e) -> failwith e
    | Ok () ->
      Store.get master ["vm"; "writes"] >|= fun m ->
      Fmt.pr "Gauge is %Ld\n%!" m.gauge
  end
```

### Conclusion

Irmin 1.0 is out. Defining new mergeable contents is now simpler. The
Irmin API to create stores as also been simplified, as well as
operations to read and write atomically. Finally, flexible first-class
support for immutable trees has also been added.

Send us feedback on the [MirageOS mailing-list][ml] or on the [Irmin
issue tracker on GitHub][gh].

[ml]: https://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel
[gh]: https://github.com/mirage/irmin

