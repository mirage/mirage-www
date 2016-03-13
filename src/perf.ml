(*
 * Copyright (c) 2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Cow.Html

let uri = Uri.of_string

let dns = list [
    p (string "This page describes some of the measurements we have done"
       ++ i (string "during")
       ++ string
         "development of MirageOS, and descriptions of some of the problems \
          we encountered and how they were fixed. We use DNS serving \
          performance as the first measure of I/O performance, for several \
          reasons:");
    ul [
      p (string
           "UDP is more straightforward to implement than TCP and is \
            stateless. This lets us test the performance of the event loop, \
            Xen rings and the Ethernet/IPv4 stack without getting mixed up in \
            the intricacies of TCP at the same time.");
      p (string
           "The small size of most DNS packets is a pessimal test of Xen PV \
            IO (grant tables require that a 4K page must be allocated per \
            packet, most of which is unused), and any OCaml-related slowdowns \
            in the data path will become rapidly obvious. The intuition is \
            that if DNS performs well, then \"big data\" manipulation should \
            be good too.");
      p (string
           "The size of the record set being looked up lets us smoothly move \
            from being I/O bound (with a small number of records) to \
            CPU-bound (with a large number of records to look up per \
            request). We have spotted performance cliffs here related to \
            garbage collection, and experimented with memoization techniques \
            to smooth things out.");
      p (string "The "
         ++ a ~href:(uri "http://www.nominum.com/wp-content/uploads/2010/08/\
                          caching-performance.pdf") (string "queryperf")
         ++ string
           " test suite provides realistic test data that we can also run \
            against other servers.");
      p (string
           "BIND and NSD are widely used and critical servers that we can \
            use as a benchmark, and aim to beat! BIND is an easy target, \
            but NSD is supremely well tuned for high performance.");
    ];

    h2 (string "Experimental Setup");

    p (string "All of the DNS tests are in "
       ++ a ~href:(uri "http://github.com/avsm/mirage-perf")
         (string "mirage-perf.git/dns")
       ++ string
         " repository, and can be run on a Debian or Ubuntu Xen box. We have \
          used Xen 3.4, 4.0 and 4.1. It should work with "
       ++ tt (string "xm")
       ++ string " but we mostly use the new "
       ++ tt (string "xl")
       ++ string " command line tool.");

    p (string "The tests currently perform the following tasks:");
    ul [
      p (a ~href:(uri "http://github.com/avsm/mirage-perf/tree/master/dns/bin/")
           (string "bin/setup.sh")
         ++ string "uses debootstrap to set up domU images of Linux. (and \
                    install NSD/BIND?)");
      p (a ~href:(uri "http://github.com/avsm/mirage-perf/tree/master/dns/bin/")
           (string "bin/generate.sh")
         ++ string " runs "
         ++ tt (string "queryperf")
         ++ string " to create the test zone files, and compiles the MirageOS \
                    UNIX and kernel binaries for different result sizes");
      p (a ~href:(uri "http://github.com/avsm/mirage-perf/tree/master/dns/bin/")
           (string "bin/run.sh")
         ++ string
           " reads some parameters (ranges of record sizes to test, \
            which servers to run), and launches a series of client \
            and server domains that run queryperf and responses \
            respectively. The packets go across a dom0 bridge with \
            all hardware checksumming disabled. Queries per second \
            and response time variances are logged into "
         ++ tt (string "dns/data/"));
    ];

    p (string
         "If you do ever decide to run these tests and try to reproduce our \
          results, please do archive up your "
       ++ tt (string "dns/data/")
       ++ string
         "directory and send them to us too, along with a description of the \
          hardware and Xen/Linux versions you used.");

    h2 (string "Results");

    p (string "Stay tuned, still working on publishing these...");
  ]
