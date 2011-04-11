We've been plugging away on Mirage for the last few months, and things are starting to take shape. A bunch of the older blog entries were out-of-date, and so we have shifted them over to the new [wiki](/wiki) instead. What else has been happening?

* The Xen microkernel backend is fully event-driven (no interrupts) and very stable under stress testing now. The TCP stack is also complete enough to self-host this website!
* Richard Mortier has put together a performance testing framework that lets us compare the performance of Mirage applications on different backends (e.g. UNIX vs Xen), and other conventional applications written in C (e.g. BIND for DNS serving). Read more...
* Thomas Gazagnaire has also integrated experimental Node.JS support to fill in our buzzword quota for the year (and more seriously, to explore alternative VM backends for Mirage applications). 
* Thomas has also rewritten the website to use the COW syntax extensions.
* The build system (often a bugbear of such OS projects) now fully uses [ocamlbuild]() for all OCaml and C dependencies.

There are some exciting developments coming up this year too!

* Raphael Proust will be joining the Mirage team in Cambridge over the summer in an internship.
* Anil Madhavapeddy will be several tech talks on Mirage: at the OCaml User's Group in Paris in April, at Citrix in May, and at Acunu in London in June. If you are interested, please do drop by and say hi.
* Verisign has supported the project with an Internet Infrastructure Grant to celebrate 25 Years of Dot Com.
* David Scott (chief architect of the Xen Cloud Platform) and Anil Madhavapeddy will give a tutorial on constructing functional operating systems at the Commercial Users of Functional Programming workshop in Japan in September.

