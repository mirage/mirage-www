## Introducing Irmin

> This is the first post in a series which will describe Irmin, the
  new storage layer of Mirage 2.0. In this post, I will give an
  high-level description on the project and its overall
  architecture. Later posts will detail how to use Irmin in
  real systems.

[Irmin][irmin] is a library to persist and synchronize distributed
data structures both on disk and in memory. It enables a style of
programming very similar to the [Git](git) workflow, where
distributed *agents* fork, fetch, merge and push data between
each-other. The general idea is that you want every active "agent" to
get a local (partial) copy of a global database and always be very
explicit about how and when data are shared and migrated.

Irmin is *not*, stricly speaking, a proper database engine. Indeed, it
is, as all others components of the Mirage OS, a collection of
libraries designed to solve different flavors of the challenges raised
by the [CAP][cap] theorem. Each application can then pick the right
combination of libraries to solve its specific use-case. More
precisely, Irmin consists of a core of well-defined low-level
constructs and design principles, which specify how data might persist
and be shared. It also define algorithms to synchronize efficiently
those distributed low-level constructs. And finally, it offers a
collection of useful higher-level data structures that can be used
transparently by developers, i.e., without having to know precisely
how Irmin works underneath.

Irmin does not make strong assumptions on how the low-level constructs
are implemented. This makes the system very portable: what I explain
below holds for in-memory databases and for fancy disk serialization
like disk browser local-storage or the Git format.

### Persistent Data Structures

Persistent data structures are well known and used pervasively in many
different areas. The *Programming Languages* community has
investigated the concepts [widely][okasaki] -- and this is [not
limited][shallow] to functional programming folks -- in the meantime,
the *Systems* community experimented with various persistent
strategies for memory and storage, such and [copy-on-write][cow]
filesystems. In all of these systems, the main concern is to optimize
the space complexity by maximizing the sharing of immutable
sub-structures.

Irmin design ideas share roots with previous works on persistent data
structures, as it provides an efficient way to *fork* data structures,
but it also explores new strategies and mechanisms to be able to
efficiently *merge* back these forked structures. This offers
programming constructs very similar to the Git workflow.
 Irmin focuses on two main aspects:
(i) *Semantics*, what properties the resulting merged objects should
verify; and (ii) *Complexity*, how to design efficient merge and
synchronization primitives, taking advantage of the immutable nature
of the underlying objects.

Although it is pervasively used, *data persistence* has a very broad and
fuzzy meaning. In this blog post, I will refer to data persistence as
a way:

- For a single process, to lazily populate a process memory on startup --
  you need this when you want the process to be able to resume while
  holding part of its previous state if it crashes

- For concurrent processes, to share references between objects living in
  a global pool of data. Sharing references, as opposed to sharing
  value, leads to better performance and allow different processes to
  concurrently update a shared store.

In both cases, you need a global pool of data (the Irmin *block store*)
and a way to name values in that pool (the Irmin *tag store*).

### The Block Store: a Virtual Heap

Even high-level data structures need to be allocated in memory, and it
is the purpose of the runtime to map such high-level constructs into
low-level memory graph blocks. One of the strength of [OCaml][ocaml]
is the very simple and deterministic mapping from high-level data
structures to low-level block representations (the *heap*): see for
instance, the excellent series of blog posts on [OCaml
internals][runtime] by Richard W. Jones. An Irmin *block store* can be
seen as a virtual OCaml heap, using a more abstract way of relating
heap blocks together. Instead of using the concrete physical memory
addresses of these, Irmin uses the hash of the block contents as an
address. As for any [content-addressable storage][cas], this gives to
Irmin block-stores a lot of nice properties and greatly simplify the
way distributed stores can be synchronized.

*Persistent* data structures are immutable: once a block is created in
the block store, its contents will never change again. In that
context, updating a data structure means returning a completely new
structure, while trying to share common sub-parts to avoid the cost of
making new allocations as much as possible. For instance, modifying a
value in a persistent tree means creating a chain of new blocks, from
the root of the tree to the modified leaf. For convenience (and also
because it is hard, in a non-lazy pure language to generate complex
cyclic value), Irmin only considers acyclic block graphs.

Conceptually, an Irmin block store has the following signature:

```ocaml
type t
(** The type for Irmin block store. *)

type key
(** The type for Irmin pointers *)

type value = ...
(** The type for Irmin blocks *)

val read: t -> key -> value option
(** [read t k] is the block stored at the location [k] of the
store. It is [None] if no block is available at that location. *)

val add: t -> key -> value -> t
(** [add t k v] is the *new* store storing the block [v] at the
location [k]. *)
```

Persistent data structure are very efficient to store in memory and on
disk as you do not need [write barriers][barriers] and writes
can be done [sequentially][seq-writes], easing the interaction with
filesystem caches.

### The Tag Store: Controlled Mutability and Concurrency

So far, we have only discussed a purely functional data structure,
where updating a structure means returning a pointer to a new
structure in the heap, sharing most of its contents with the previous
one. This style of programming is appealing when implementing complex
[protocols][tls] as it leads to better compositional properties.

However, in that context, sharing information between processes is
difficult: you need a way to "inject" the state of one structure in an
other process memory. In order to do so, Irmin borrows the concept of
*branches* from Git: in practice every operation is related to a given
branch name, and it can modify the tip of the branch if it has
side-effects. The *tag store*, in Irmin, is the only mutable part of
the whole system and it is responsible to map some global (branch)
names to blocks in the block store -- these names can then be used to
pass block references between different processes.

It is then possible to combine a block store and a tag store to build
a higher-level store (the Irmin store) with fine concurrency control
and atomicity guarantees. As mutation happens only in the tag store,
we can ensure that as long a given tag is not updated, no change done
in the block store will be visible by anyone. This also gives a nice
story for concurrency: as in Git, creating a concurrent view of the
store is straightforward: it is simply a matter of creating a new tag,
denoting a new branch. All concurrent operations can then happen on
different branches:

```ocaml
type t
(** The type for Irmin store. *)

type tag
(** Mutable tags *)

type key = ...
(** The type for user-defined keys (for instance a list of strings) *)

type value = ...
(** The type for user-defined values *)

val read: t -> ?branch:tag -> key -> value option
(** [read t ?branch k] reads the contents of the key [k] in the branch
[branch] of the store [t]. If no branch is specified, then use the
["HEAD"] one. *)

val update: t -> ?branch:tag -> key -> value -> unit
(** [update t ?branch k v] *updates* the branch [branch] of the store
[t] the association of the key [key] to the value [value]. *)
```

Interactions between concurrent processes are completely explicit and
need to happen via synchronization points and merge events (more on
this below). It is also possible to emulate the behavior of
transactions by recording the sequence of operations (`read`s and
`update`s) on a given branch -- that sequence is used before a merge
to check that all the operations are valid (i.e. that all reads in the
transaction still return the same result on the current tip of the
store) and it can be discarded after the merge takes place.

### Merging Data Structures

To merge two data structures in a consistent way, one has to compute
the sequence of operations which leads, from an initial common state, to two
diverging states (the ones that you want to merge). Once these two
sequences of operations have been found, they must be combined (if
possible) in a sensible way and then applied again back on the initial
state, in order to get the new merged state. This mechanism sounds
nice, but in practice it has two major drawbacks:

1. It does not say how we find the initial state from two diverging
   states -- this is generally not possible (think of diverging
   counters); and
2. It means we need to compute the sequence of `update`s which leads
   from one state to an other -- which is easier than 1. but it is
   generally not very efficient.

In Irmin, we solve these problems using two mechanisms.

First of all, an interesting observation is that that we can model the
sequence of store tips as a purely functional data-structure. We model
the partial order of tips as a directed acyclic graph where nodes are
the tips and there is an edge between two tips if either (i) one is
the result of applying a sequence of `update`s to the other, or (ii)
one is the result of a merge operation between the other and some
other tips. Practically speaking, that means that every tip should
contains the list of its predecessors as well as the actual data it
associated to. As it is purely functional, we can (and we do) store
that graph in an Irmin block store.

Having a persistent and immutable history is good for various obvious
reasons, such as access to a nice forensic tool if an error occurs or
snapshot and rollback features for free. But an other less obvious
nice property is the fact that we can now find the greatest common
ancestors of two data structures. This solves the first point above.

The second mechanism is that we require the data structures used in
Irmin to be equipped with a well-defined 3-way merge operation, which
takes two diverging states, the corresponding initial state (computed
using the previous mechanism) and that return either a new state or a
conflict (similar to the `EAGAIN` exception that you get when you try
to commit a conflicting transaction in more traditional transactional
databases). Having access to the common ancestors makes a great
difference when designing new merge functions, as usually no
modification is required to the data-structure itself. At the
opposite, the usual approach is more invasive as it requires to
enrich the data-structure itself to carry more information about the
operation history, see for instance the [conflict-free replicated
datatypes][crdt], which relies on unbounded vector clocks.

We started to design interesting data structure equipped with a 3-way merge, as
counters, [queues][merge-queues] and ropes.

This is what the implementation of distributed and mergeable counters
looks like:

```ocaml
type t = int
(** distributed counters are just normal integers! *)

let merge ~old t1 t2 = old + (t1-old) + (t2-old)
(** Merging counters means:
   - computing the increments of the two states [t1] and [t2]
     relatively to the initial state [old]; and
   - and add these two increments to [old]. *)
```

### Conclusion

From a designer point-of-view, having access to the history means it
is easier to design complex data structure with good compositional
properties, to use in an application using Mirage and Irmin. Moreover,
as we made little assumptions on how the substrate of the low-level
constructs needs to be implemented, we hope to see the Irmin
engine to be ported to a lot of different backends: this is just a
matter of implementing a rather trivial [signature][irmin-AO].

From an end-user point of view, this means that the full history of
operations is available to inspect, and that the history model is very
similar to the Git workflow. So similar, in fact, that we've developed
a bi-directional mapping between Irmin data structure and the Git
format! See for instance what [Dave Scott][dave] did with the new version of
[xenstore][xenstore], booting a Xen VM, where the internal database is
stored in a prefix-tree Irmin data-structure and exposed as
a Git repository which is live-updated:

<center>
<iframe width="480" height="360" src="//www.youtube-nocookie.com/embed/DSzvFwIVm5s" frameborder="0" allowfullscreen="1"> &nbsp; </iframe>
</center>

[irmin-AO]: https://github.com/mirage/irmin/blob/4b06467ddee1e20c35bad64812769587fb9fa8a4/lib/core/irminStore.mli#L61
[dave]: http://dave.recoil.org/
[shallow]: http://en.wikipedia.org/wiki/Object_copy
[cap]: http://en.wikipedia.org/wiki/CAP_theorem
[irmin]: https://github.com/mirage/irmin
[ocaml]: http://ocaml.org
[okasaki]: https://www.cs.cmu.edu/~rwh/theses/okasaki.pdf
[cow]: http://en.wikipedia.org/wiki/Copy-on-write
[git]: http://git-scm.com/
[runtime]: http://rwmj.wordpress.com/2009/08/04/ocaml-internals/
[crdt]: http://hal.upmc.fr/docs/00/55/55/88/PDF/techreport.pdf
[merge-queues]: https://github.com/mirage/merge-queues
[barriers]: http://en.wikipedia.org/wiki/Write_barrier
[seq-writes]: http://en.wikipedia.org/wiki/Write_amplification#Sequential_writes
[tls]: http://openmirage.org/blog/ocaml-tls-api-internals-attacks-mitigation
[xirminstore]: https://www.youtube.com/watch?v=DSzvFwIVm5s
[xenstore]: http://wiki.xen.org/wiki/XenStoreReference
