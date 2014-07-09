*This is the second in a series of posts that introduce new libraries for a pure OCaml implementation of TLS.
You might like to begin with the [introduction][tls-intro].*

### What is nocrypto? ###

[nocrypto][nocrypto] is the small cryptographic library behind the
[ocaml-tls][ocaml-tls] project. It is built to be straightforward to use, adhere to
functional programming principles and able to run in a Xen-based unikernel.
Its major use-case is `ocaml-tls`, which we [announced yesterday][tls-intro], but we do intend to provide
sufficient features for it to be more widely applicable.

"Wait, you mean you wrote your own *crypto library*?"

[nocrypto]: https://github.com/mirleft/ocaml-nocrypto
[ocaml-tls]: https://github.com/mirleft/ocaml-tls

### "Never write your own crypto" ###

Everybody seems to recognize that cryptography is horribly difficult. Building
cryptography, it is all too easy to fall off the deep end and end up needing to
make decisions only a few, select specialists can make. Worse, any mistake is
difficult to uncover but completely compromises the security of the system. Or
in Bruce Schneier's [words][schneier-pitfalls]:

> Building a secure cryptographic system is easy to do badly, and very difficult
> to do well. Unfortunately, most people can't tell the difference. In other
> areas of computer science, functionality serves to differentiate the good from
> the bad: a good compression algorithm will work better than a bad one; a bad
> compression program will look worse in feature-comparison charts. Cryptography
> is different. Just because an encryption program works doesn't mean it is
> secure.

Obviously, it would be far wiser not to attempt to do this and instead reuse
good, proven work done by others. And with the wealth of free cryptographic
libraries around, one gets to take their pick.

So to begin with, we turned to [cryptokit][cryptokit], the more-or-less
standard cryptographic library in the OCaml world. It has a decent coverage of
the basics: some stream ciphers (ARC4), some block ciphers (AES, 3DES and
Blowfish) the core hashes (MD5, SHA, the SHA2 family and RIPEMD) and the
public-key primitives (Diffie-Hellman and RSA). It is also designed with
composability in mind, exposing various elements as stream-transforming objects
that can be combined on top of one another.

Unfortunately, its API was a little difficult to use. Suppose you have a secret
key, an IV and want to use AES-128 in CBC mode to encrypt a bit of data. You do
it like this:

```OCaml
let key = "abcd1234abcd1234"
and iv  = "1234abcd1234abcd"
and msg = "fire the missile"

let aes     = new Cryptokit.Block.aes_encrypt key
let aes_cbc = new Cryptokit.Block.cbc_encrypt ~iv aes

let cip =
  let size =
    int_of_float (ceil (float String.(length msg) /. 16.) *. 16.) in
  String.create size

let () = aes_cbc#transform msg 0 cip 0
```

At this point, `cip` contains our secret message. This being CBC, both `msg` and
the string the output will be written into (`cip`) need to have a size that is a
multiple of the underlying block size. If they do not, bad things will
happen -- silently.

There is also the curious case of hashing-object states:

```OCaml
let md5 = Cryptokit.Hash.md5 ()

let s1 = Cryptokit.hash_string md5 "bacon"
let s2 = Cryptokit.hash_string md5 "bacon"
let s3 = Cryptokit.hash_string md5 "bacon"

(*
  s1 = "x\019%\142\248\198\1822\221\232\204\128\246\189\166/"
  s2 = "'\\F\017\234\172\196\024\142\255\161\145o\142\128\197"
  s3 = "'\\F\017\234\172\196\024\142\255\161\145o\142\128\197"
*)
```

The error here is to try and carry a single instantiated hashing object around,
while trying to get hashes of distinct strings. But with the convergence after
the second step, the semantics of the hashing object still remains unclear to
us.

One can fairly easily overcome the API style mismatches by making a few
specialized wrappers, of course, except for two major problems:

- Cryptokit is pervasively stateful. While this is almost certainly a result of
  performance considerations combined with its goals of ease of
  compositionality, it directly clashes with the fundamental design property of
  the TLS library we wanted to use it in: our `ocaml-tls` library is stateless. We need to
  be able to represent the state the encryption engine is in as a value.

- Cryptokit operates on strings. As a primary target of `ocaml-tls` was
  [Mirage][mirage], and Mirage uses separate, non-managed regions of memory to
  store network data in, we need to be able to handle foreign-allocated
  storage. This means `Bigarray` (as exposed by `Cstruct`), and it seems just
  plain wrong to negate all the careful zero-copy architecture of the stack
  below by copying everything into and out of strings.

There are further problems. For example, Cryptokit makes no attempts to combat
well-known timing vulnerabilities. It has no support for elliptic curves. And it
depends on the system-provided random number generator, which does not exist
when running in the context of a unikernel.

At this point, with the _de facto_ choice off the table, it's probably worth
thinking about writing OCaml bindings to a rock-solid cryptographic library
written in C.

[NaCl][nacl] is a modern, well-regarded crypto implementation, created by a
group of pretty famous and equally well-regarded cryptographers, and was the
first choice. Or at least its more approachable and packageable [fork][sodium]
was, which already had [OCaml bindings][ocaml-sodium]. Unfortunately, `NaCl`
provides a narrow selection of implementations of various cryptographic
primitives, the ones its authors thought were best-of-breed (for example, the
only symmetric ciphers it implements are (X-)Salsa and AES in CTR mode). And
they are probably right (in some aspects they are _certainly_ right), but NaCl
is best used for implementations of newly-designed security protocols. It is
simply too opinionated to support an old, standardized behemoth like TLS.

Then there is [crypto][libcrypto], the library OpenSSL is built on top of. It
is quite famous and provides optimized implementations of a wide range of
cryptographic algorithms. It also contains upwards of 200,000 lines of C and a
very large API footprint, and it's unclear whether it would be possible to run
it in the unikernel context. Recently, the parent project it is embedded in has
become highly suspect, with one high-profile vulnerability piling on top of
another and at least [two][libressl] [forks][boringssl] so far attempting to
clean the code base. It just didn't feel like a healthy code base to build
a new project on.

There are other free cryptographic libraries in C one could try to bind, but at
a certain point we faced the question: is the work required to become intimately
familiar with the nuances and the API of an existing code base, and create
bindings for it in OCaml, really that much smaller than writing one from
scratch? When using a full library one commits to its security decisions and
starts depending on its authors' time to keep it up to date -- maybe this
effort is better spent in writing one in the first place.

Tantalizingly, the length of the single OCaml source file in `Cryptokit` is
2260 lines.

Maybe if we made **zero** decisions ourselves, informed all our work by published
literature and research, and wrote the bare minimum of code needed, it might not
even be dead-wrong to do it ourselves?

And that is the basic design principle. Do nothing fancy. Do only documented
things. Don't write too much code. Keep up to date with security research. Open
up and ask people.

[schneier-pitfalls]: https://www.schneier.com/essays/archives/1998/01/security_pitfalls_in.html
[cryptokit]: https://forge.ocamlcore.org/projects/cryptokit/
[mirage]: http://openmirage.org/
[nacl]: http://nacl.cr.yp.to/
[sodium]: http://labs.opendns.com/2013/03/06/announcing-sodium-a-new-cryptographic-library/
[ocaml-sodium]: https://github.com/dsheets/ocaml-sodium
[libcrypto]: https://www.openssl.org/docs/crypto/crypto.html
[libressl]: http://www.libressl.org/
[boringssl]: https://boringssl.googlesource.com/boringssl/

### The anatomy of a simple crypto library ###

`nocrypto` uses bits of C, similarly to other cryptographic libraries written in
high-level languages.

This was actually less of a performance concern, and more of a security one: for
the low-level primitives which are tricky to implement and for which known,
compact and widely used code already exists, the implementation is probably
better reused. The major pitfall we hoped to avoid that way are side-channel
attacks.

We use public domain (or BSD licenced) [C sources][native-sources] for the
simple cores of AES, 3DES, MD5, SHA and SHA2. The impact of errors in this code
is constrained: they contain no recursion, and they perform no allocation,
simply filling in caller-supplied fixed-size buffer by appropriate bytes.

The block implementations in C have a simple API that requires us to provide the
input and output buffers and a key, writing the single encrypted (or decrypted)
block of data into the buffer. Like this:

```C
void rijndaelEncrypt(const unsigned long *rk, int nrounds,
  const unsigned char plaintext[16], unsigned char ciphertext[16]);

void rijndaelDecrypt(const unsigned long *rk, int nrounds,
  const unsigned char ciphertext[16], unsigned char plaintext[16]);
```

The hashes can initialize a provided buffer to serve as an empty accumulator,
hash a single chunk of data into that buffer and convert its contents into a
digest, which is written into a provided fixed buffer.

In other words, all the memory management happens exclusively in OCaml and all
the buffers passed into the C layer are tracked by the garbage collector (GC).

[native-sources]: https://github.com/mirleft/ocaml-nocrypto/tree/master/src/native

### Symmetric ciphers ###

So far, the only provided ciphers are AES, 3DES and ARC4, with ARC4 implemented
purely in OCaml (and provided only for TLS compatibility and for testing).

AES and 3DES are based on core C code, on top of which we built some standard
[modes of operation][block-modes] in OCaml. At the moment we support ECB, CBC
and CTR. There is also a nascent [GCM][gcm] implementation which is, at the time
of writing, known not to be optimal and possibly prone to timing attacks, and
which we are still working on.

The exposed API strives to be simple and value-oriented. Each mode of each
cipher is packaged up as a module with a similar signature, with a pair of
functions for encryption and decryption. Each of those essentially takes a key
and a byte buffer and yields the resulting byte buffer, minimising hassle.

This is how you encrypt a message:

```OCaml
open Nocrypto.Block

let key = AES.CBC.of_secret Cstruct.(of_string "abcd1234abcd1234")
and iv  = Cstruct.of_string "1234abcd1234abcd"
and msg = Cstruct.of_string "fire the missile"

let { AES.CBC.message ; iv } = AES.CBC.encrypt ~key ~iv msg
```

The hashes implemented are just MD5, SHA and the SHA2 family. Mirroring the
block ciphers, they are based on C cores, with the HMAC construction provided in
OCaml. The API is similarly simple: each hash is a separate module with the same
signature, providing a function that takes a byte buffer to its digest, together
with several stateful operations for incremental computation of digests.

Of special note is that our current set of C sources will probably soon be
replaced. AES uses code that is vulnerable to a [timing attack][djb-aes],
stemming from the fact that substitution tables are loaded into the CPU cache
as-needed. The code does not take advantage of the [AES-NI][aes-ni]
instructions present in modern CPUs that allow AES to be hardware-assisted. SHA
and SHA2 cores turned out to be (comparatively) ill-performing, and static
analysis already uncovered some potential memory issues, so we are looking for
better implementations.

[block-modes]: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation
[gcm]: https://en.wikipedia.org/wiki/Galois/Counter_Mode
[djb-aes]: http://cr.yp.to/antiforgery/cachetiming-20050414.pdf
[aes-ni]: https://en.wikipedia.org/wiki/AES_instruction_set

### Public-key cryptography ###

Bignum arithmetic is provided by the excellent [zarith][zarith] library, which
in turn uses [GMP][gmp]. This might create some portability problems later on,
but as GMP is widely used and well rounded code base which also includes some of
the needed auxiliary number-theoretical functions (its slightly extended
Miller-Rabin probabilistic primality test and the fast next-prime-scanning
function), it seemed like a much saner choice than redoing it from scratch.

The [RSA][rsa-mli] module provides the basics: raw encryption and decryption,
[PKCS1][pkcs1]-padded versions of the same operations, and PKCS1 signing and
signature verification. It can generate RSA keys, which it does simply by
finding two large primes, in line with [Rivest's][rivest-strong-primes] own
recommendation.

Notably, RSA implements the standard [blinding][] technique which can mitigate
some side-channel attacks, such as timing or [acoustic][rsa-acoustic]
cryptanalysis. It seems to foil even stronger, [cache eviction][flush-reload]
based attacks, but as of now, we are not yet completely sure.

The [Diffie-Hellman][dh-mli] module is also relatively basic. We implement some
[widely][dh-art-1] [recommended][dh-art-2] checks on the incoming public key to
mitigate some possible MITM attacks, the module can generate strong DH groups
(using safe primes) with guaranteed large prime-order subgroup, and we provide
a catalogue of published DH groups ready for use.

[zarith]: https://forge.ocamlcore.org/projects/zarith
[gmp]: https://gmplib.org/
[rsa-mli]: https://github.com/mirleft/ocaml-nocrypto/blob/a52bba2dcaf1c5fd45249588254dff2722e9f960/src/rsa.mli
[dh-mli]: https://github.com/mirleft/ocaml-nocrypto/blob/a52bba2dcaf1c5fd45249588254dff2722e9f960/src/dh.mli
[pkcs1]: https://en.wikipedia.org/wiki/PKCS_1
[rivest-strong-primes]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.310.4183
[blinding]: https://en.wikipedia.org/wiki/Blinding_(cryptography)
[rsa-acoustic]: http://www.cs.tau.ac.il/~tromer/acoustic/
[flush-reload]: http://eprint.iacr.org/2013/448.pdf
[dh-art-1]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.56.1921
[dh-art-2]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.21.639

### Randomness ###

Random number generation used to be a chronically overlooked part of
cryptographic libraries, so much so that nowadays one of the first questions
about a crypto library is, indeed, "Where does it get randomness from?"

It's an important question. A cryptographic system needs unpredictability in
many places, and violating this causes catastrophic [failures][debian-rng].

`nocrypto` contains its own implementation of [Fortuna][fortuna]. Like
[Yarrow][yarrow], Fortuna uses a strong block cipher in CTR mode (AES in our
case) to produce the pseudo-random stream, a technique that is considered as
unbreakable as the underlying cipher.

The stream is both self-rekeyed, and rekeyed with the entropy gathered into its
accumulator pool. Unlike the earlier designs, however, Fortuna is built without
entropy estimators, which usually help the PRNG decide when to actually convert
the contents of an entropy pool into the new internal state. Instead, Fortuna
uses a design where the pools are fed round-robin, but activated with an
exponential backoff. There is [recent research][eat-your-entropy] showing this
design is essentially sound: after a state compromise, Fortuna wastes no more
than a constant factor of incoming entropy -- whatever the amount of entropy is
-- before coming back to an unpredictable state. The resulting design is both
simple, and robust in terms of its usage of environmental entropy.

The above paper also suggests a slight improvement to the accumulator regime,
yielding a factor-of-2 improvement in entropy usage over the original. We still
haven't implemented this, but certainly intend to.

A PRNG needs to be fed with some actual entropy to be able to produce
unpredictable streams. The library itself contains no provisions for doing this
and its PRNG needs to be fed by the user before any output can be produced. We
are [working with the Mirage team][mirage-entropy] on exposing environmental
entropy sources and connecting them to our implementation of Fortuna.

[debian-rng]: https://www.debian.org/security/2008/dsa-1571
[fortuna]: https://www.schneier.com/fortuna.html
[yarrow]: https://www.schneier.com/yarrow.html
[eat-your-entropy]: https://eprint.iacr.org/2014/167
[mirage-entropy]: https://github.com/mirage/mirage-entropy

### Above & beyond ###

`nocrypto` is still very small, providing the bare minimum cryptographic
services to support TLS and related X.509 certificate operations. One of the
goals is to flesh it out a bit, adding some more widely deployed algorithms, in
hopes of making it more broadly usable.

There are several specific problems with the library at this stage:

**C code** - As mentioned, we are seeking to replace some of the C code we use. The hash
cores are underperforming by about a factor of 2 compared to some other
implementations. AES implementation is on one hand vulnerable to a timing attack
and, on the other hand, we'd like to make use of hardware acceleration for this
workhorse primitive -- without it we lose about an order of magnitude of
performance.

Several options were explored, ranging from looking into the murky waters of
OpenSSL and trying to exploit their heavily optimized primitives, to bringing
AES-NI into OCaml and redoing AES in OCaml. At this point, it is not clear which
path we'll take.

**ECC** - Looking further, the library still lacks support for elliptic curve cryptography
and we have several options for solving this. Since it is used by TLS, ECC is
probably the missing feature we will concentrate on first.

**Entropy on Xen** - The entropy gathering on Xen is incomplete. The current prototype uses current
time as the random seed and the effort to expose noisier sources like interrupt
timings and the RNG from dom0's kernel is still ongoing.  Dave Scott, for example, has
[submitted patches][rndpatches] to upstream Xen to make it easier to establish low-bandwidth
channels to supplies guest VMs with strong entropy from a privileged domain
that has access to physical devices and hence high-quality entropy sources.

**GC timing attacks?** - There is the question of GC and timing attacks: whether doing
cryptography in a high-level language opens up a completely new surface for
timing attacks, given that GC runs are very visible in the timing profile. The
basic approach is to leave the core routines which we know are potentially
timing-sensitive (like AES) and for which we don't have explicit timing
mitigations (like RSA) to C, and invoke them atomically from the perspective of
the GC. So far, it's an open question whether the constructions built on top
of them expose further side-channels.

Still, we believe that the whole package is a pleasant library to work with. Its
simplicity contributes to the comparative simplicity of the entire TLS library,
and we are actively seeking input on areas that need further improvement.
Although we are obviously biased, we believe it is the best cryptographic base
library available for this project, and it might be equally suited for your next
project too!

We are striving to be open about the current security status of our code. You
are free to check out our [issue tracker][issues] and invited to contribute
comments, ideas, and especially audits and code.

[issues]: https://github.com/mirleft/ocaml-nocrypto/issues?state=open
[rndpatches]: http://lists.xen.org/archives/html/xen-devel/2014-06/msg01492.html

****

Posts in this TLS series:
 
 - [Introducing transport layer security (TLS) in pure OCaml][tls-intro]
 - [Introducing the nocrypto library][nocrypto-intro]

[tls-intro]: http://openmirage.org/blog/introducing-ocaml-tls
[nocrypto-intro]: http://openmirage.org/blog/introducing-nocrypto
