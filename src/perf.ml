open Cow

let dns =
 <:xml<
   <p>This page describes some of the measurements we have done <i>during</i> development of MirageOS, and descriptions of some of the problems we encountered and how they were fixed. We use DNS serving performance as the first measure of I/O performance, for several reasons:</p>
    <ul>
     <li><p>UDP is more straightforward to implement than TCP and is stateless. This lets us test the performance of the event loop, Xen rings and the Ethernet/IPv4 stack without getting mixed up in the intricacies of TCP at the same time.</p></li>
     <li><p>The small size of most DNS packets is a pessimal test of Xen PV IO (grant tables require that a 4K page must be allocated per packet, most of which is unused), and any OCaml-related slowdowns in the data path will become rapidly obvious.  The intuition is that if DNS performs well, then "big data" manipulation should be good too.</p></li>
     <li><p>The size of the record set being looked up lets us smoothly move from being I/O bound (with a small number of records) to CPU-bound (with a large number of records to look up per request). We have spotted performance cliffs here related to garbage collection, and experimented with memoization techniques to smooth things out.</p></li>
     <li><p>The <a href="http://www.nominum.com/wp-content/uploads/2010/08/caching-performance.pdf">queryperf</a> test suite provides realistic test data that we can also run against other servers.</p></li>
     <li><p>BIND and NSD are widely used and critical servers that we can use as a benchmark, and aim to beat! BIND is an easy target, but NSD is supremely well tuned for high performance.</p></li>
  </ul>

  <h2>Experimental Setup</h2>

  <p>All of the DNS tests are in <a href="http://github.com/avsm/mirage-perf">mirage-perf.git/dns/</a> repository, and can be run on a Debian or Ubuntu Xen box. We have used Xen 3.4, 4.0 and 4.1. It should work with <tt>xm</tt>, but we mostly use the new <tt>xl</tt> command line tool.</p>

  <p>The tests currently perform the following tasks:</p>
  <ul>
    <li><p><a href="http://github.com/avsm/mirage-perf/tree/master/dns/bin/">bin/setup.sh</a> uses debootstrap to set up domU images of Linux. (and install NSD/BIND?)  </p></li>
    <li><p><a href="http://github.com/avsm/mirage-perf/tree/master/dns/bin/">bin/generate.sh</a> runs <tt>queryperf</tt> to create the test zone files, and compiles the MirageOS UNIX and kernel binaries for different result sizes</p></li>
    <li><p><a href="http://github.com/avsm/mirage-perf/tree/master/dns/bin/">bin/run.sh</a> reads some parameters (ranges of record sizes to test, which servers to run), and launches a series of client and server domains that run queryperf and responses respectively. The packets go across a dom0 bridge with all hardware checksumming disabled. Queries per second and response time variances are logged into <tt>dns/data/</tt></p></li>
  </ul>

  <p>If you do ever decide to run these tests and try to reproduce our results, please do archive up your <tt>dns/data/</tt> directory and send them to us too, along with a description of the hardware and Xen/Linux versions you used.</p>

  <h2>Results</h2>

  <p>Stay tuned, still working on publishing these...</p>

 >>
