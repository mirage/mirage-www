open Cow
open Printf

module People = struct
  let anil = {
    Atom.name = "Anil Madhavapeddy";
    uri       = Some "http://anil.recoil.org";
    email     = Some "anil@recoil.org";
  }

  let thomas = {
    Atom.name = "Thomas Gazagnaire";
    uri       = Some "http://gazagnaire.org";
    email     = Some "thomas@gazagnaire.org";
  }

  let raphael = {
    Atom.name = "Raphael Proust";
    uri       = Some "https://github.com/raphael-proust";
    email     = Some "raphlalou@gmail.com";
  }

  let dave = {
    Atom.name = "Dave Scott";
    uri       = Some "http://dave.recoil.org/";
    email     = Some "dave@recoil.org";
  }

  let balraj = {
    Atom.name = "Balraj Singh";
    uri       = None;
    email     = Some "balraj.singh@cl.cam.ac.uk";
  }

  let mort = {
    Atom.name = "Richard Mortier";
    uri       = Some "http://mort.io/";
    email     = Some "mort@cantab.net";
  }

  let vb = {
    Atom.name = "Vincent Bernardoff";
    uri       = Some "https://github.com/vbmithr";
    email     = Some "vb@luminar.eu.org";
  }

  let amir = {
    Atom.name = "Amir Chaudhry";
    uri       = Some "http://amirchaudhry.com";
    email     = Some "amirmc@gmail.com";
  }

  let ckoppelt = {
    Atom.name = "Christine Koppelt";
    uri       = Some "https://github.com/cko";
    email     = Some "ch.ko123@gmail.com";
  }

  let jonludlam = {
    Atom.name = "Jon Ludlam";
    uri       = Some "http://jon.recoil.org";
    email     = Some "jon@recoil.org";
  }

  let tal = {
    Atom.name = "Thomas Leonard";
    uri       = Some "http://roscidus.com/blog/";
    email     = Some "talex5@gmail.com";
  }

end

let rights = Some "All rights reserved by the author"

module Blog = struct
  open People
  let entries =
    let open Cowabloga.Date in
    let open Cowabloga.Blog.Entry in
    [
      { updated    = date (2010, 10, 11, 15, 0);
        author     = anil;
        subject    = "Self-hosting Mirage website";
        body       = "welcome.md";
        permalink  = "self-hosting-mirage-website";
      };
      { updated    = date (2011, 04, 11, 15, 0);
        author     = anil;
        subject    = "A Spring Wiki Cleaning";
        body       = "spring-cleaning.md";
        permalink  = "spring-cleaning";
      };
      { updated    = date (2011, 09, 29, 11, 10);
        author     = anil;
        subject    = "An Outing to CUFP 2011";
        body       = "an-outing-to-cufp.md";
        permalink  = "an-outing-to-cufp";
      };
      { updated    = date (2012, 02, 29, 11, 10);
        author     = mort;
        subject    = "Connected Cloud Control: OpenFlow in Mirage";
        body       = "announcing-mirage-openflow.md";
        permalink  = "announcing-mirage-openflow";
      };
      { updated    = date (2012, 9, 12, 0, 0);
        author     = dave;
        subject    = "Building a \"Xenstore stub domain\" with Mirage";
        body       = "xenstore-stub.md";
        permalink  = "xenstore-stub-domain";
      };
      { updated    = date (2012, 10, 17, 17, 30);
        author     = anil;
        subject    = "Breaking up is easy to do (with OPAM)";
        body       = "breaking-up-with-opam.md";
        permalink  = "breaking-up-is-easy-with-opam";
      };
      { updated    = date (2013, 05, 20, 16, 20);
        author     = anil;
        subject    = "The road to a developer preview at OSCON 2013";
        body       = "the-road-to-a-dev-release.md";
        permalink  = "the-road-to-a-dev-release";
      };
      { updated    = date (2013, 07, 18, 11, 20);
        author     = dave;
        subject    = "Creating Xen block devices with Mirage";
        body       = "xen-block-devices-with-mirage.md";
        permalink  = "xen-block-devices-with-mirage";
      };
      { updated    = date (2013, 08, 08, 16, 00);
        author     = mort;
        subject    = "Mirage travels to OSCON'13: a trip report";
        body       = "oscon13-trip-report.md";
        permalink  = "oscon13-trip-report";
      };
      { updated    = date (2013, 08, 23, 17, 43);
        author     = vb;
        subject    = "Introducing vchan";
        body       = "introducing-vchan.md";
        permalink  = "introducing-vchan";
      };
      { updated    = date (2013, 12, 09, 12, 0);
        author     = anil;
        subject    = "Mirage 1.0: not just a hallucination!";
        body       = "releasing-mirage.md";
        permalink  = "announcing-mirage10";
      };
      { updated    = date (2013, 12, 19, 23, 0);
        author     = anil;
        subject    = "Mirage 1.0.3 released; tutorial on building this website available";
        body       = "mirage-1.0.3-released.md";
        permalink  = "mirage-1.0.3-released";
      };
      { updated    = date (2014, 01, 03, 16, 0);
        author     = mort;
        subject    = "Presenting Decks";
        body       = "decks-n-drums.md";
        permalink  = "decks-n-drums";
      };
      { updated    = date (2014, 02, 11, 16, 0);
        author     = anil;
        subject    = "Mirage 1.1.0: the eat-your-own-dogfood release";
        body       = "mirage-1.1-released.md";
        permalink  = "mirage-1.1-released";
      };
      { updated    = date (2014, 02, 25, 18, 0);
        author     = anil;
        subject    = "MirageOS is in Google Summer of Code 2014";
        body       = "applying-for-gsoc2014.md";
        permalink  = "applying-for-gsoc2014";
      };
    ]
end

module Wiki = struct

  open People
  open Cowabloga.Date
  open Cowabloga.Wiki

  let weekly ~y ~m ~d ~a =
    let s = sprintf "%4d-%02d-%02d" y m d in
    { updated = date (y,m,d,16,0);
      author  = a;
      subject = "Weekly Meeting: " ^ s;
      body    = File (sprintf "weekly/%s.md" s);
      permalink = "weekly-"^s;
    }

  let entries = [
    weekly ~y:2014 ~m:4 ~d:15 ~a:dave;
    weekly ~y:2014 ~m:4 ~d:1 ~a:amir;
    weekly ~y:2014 ~m:3 ~d:18 ~a:amir;
    weekly ~y:2014 ~m:3 ~d:4 ~a:amir;
    weekly ~y:2014 ~m:2 ~d:26 ~a:amir;
    
    { updated    = date (2014, 02, 01, 01, 0);
      author     = jonludlam;
      subject    = "How Xen suspend and resume works";
      body       = File "xen-suspend.md";
      permalink  = "xen-suspend";
    };
    { updated    = date (2013, 12, 29, 17, 0);
      author     = dave;
      subject    = "Understanding Xen events with Mirage";
      body       = File "xen-events.md";
      permalink  = "xen-events";
    };
    { updated    = date (2013, 12, 25, 22, 0);
      author     = amir;
      subject    = "Deploying via Continuous Integration";
      body       = File "deployment.md";
      permalink  = "deploying-via-ci";
    };

    { updated    = date (2013, 10, 15, 16, 0);
      author     = amir;
      subject    = "Overview of Mirage";
      body       = File "overview-of-mirage.md";
      permalink  = "overview-of-mirage";
    };

    { updated    = date (2013, 11, 10, 16, 0);
      author     = ckoppelt;
      subject    = "Technical Background of Mirage";
      body       = File "technical-background.md";
      permalink  = "technical-background";
    };

    { updated    = date (2013, 12, 09, 16, 0);
      author     = anil;
      subject    = "Frequently Asked Questions (FAQ)";
      body       = File "faq.md";
      permalink  = "faq";
    };

    { updated    = date (2014, 02, 02, 17, 56);
      author     = dave;
      subject    = "Synthesizing virtual disks for Xen";
      body       = File "xen-synthesize-virtual-disk.md";
      permalink  = "xen-synthesize-virtual-disk";
    };

    { updated    = date (2013, 04, 23, 9, 0);
      author     = anil;
      subject    = "Developer Preview 1.0 Checklist";
      body       = File "dev-preview-checklist.md";
      permalink  = "dev-preview-checklist";
    };

    weekly ~y:2013 ~m:6 ~d:11 ~a:anil;
    weekly ~y:2013 ~m:6 ~d:4 ~a:anil;
    weekly ~y:2013 ~m:5 ~d:28 ~a:anil;
    weekly ~y:2013 ~m:5 ~d:21 ~a:anil;
    weekly ~y:2013 ~m:5 ~d:14 ~a:anil;
    weekly ~y:2013 ~m:4 ~d:30 ~a:anil;
    weekly ~y:2013 ~m:4 ~d:23 ~a:anil;
    weekly ~y:2013 ~m:4 ~d:16 ~a:anil;

    { updated    = date (2013, 08, 15, 16, 0);
      author     = balraj;
      subject    = "Getting Started with Lwt threads";
      body       = File "tutorial-lwt.md";
      permalink  = "tutorial-lwt";
    };

    { updated    = date (2011, 08, 12, 15, 0);
      author     = raphael;
      subject    = "Portable Regular Expressions";
      body       = File "ocaml-regexp.md";
      permalink  = "ocaml-regexp";
    };

    { updated    = date (2011, 06, 18, 15, 47);
      author     = anil;
      subject    = "Delimited Continuations vs Lwt for Threads";
      body       = File "delimcc-vs-lwt.md";
      permalink  = "delimcc-vs-lwt";
    };

    { updated    = date (2013, 12, 20, 23, 00);
      author     = anil; (* ++ mort ++ vb -- need multiple author support *)
      subject    = "Installation";
      body       = File "install.md";
      permalink  = "install";
    };

    { updated    = date (2013, 07, 17, 15, 00);
      author     = mort;
      subject    = "OPAM Libraries";
      body       = File "opam.md";
      permalink  = "opam";
    };

    { updated    = date (2013, 12, 21, 12, 50);
      author     = anil;
      subject    = "Building mirage-www";
      body       = File "mirage-www.md";
      permalink  = "mirage-www";
    };

    { updated    = date (2013, 12, 31, 19, 00);
      author     = mort;
      subject    = "Hello Mirage World";
      body       = File "hello-world.md";
      permalink  = "hello-world";
    };
    { updated    = date (2013, 08, 11, 15, 00);
      author     = anil;
      subject    = "Running Mirage Xen kernels";
      body       = File "xen-boot.md";
      permalink  = "xen-boot";
    };

    { updated    = date (2011, 04, 12, 10, 0);
      author     = anil;
      subject    = "DNS Performance Tests";
      body       = Html Perf.dns;
      permalink  = "performance";
    };

    { updated    = date (2011, 04, 12, 9, 0);
      author     = anil;
      subject    = "Publications";
      body       = Html Paper.html;
      permalink  = "papers";
    };

    { updated    = date (2013, 08, 14, 10, 0);
      author     = mort;
      subject    = "Presentations";
      body       = File "talks.md";
      permalink  = "talks";
    };

    { updated    = date (2010, 12, 13, 15, 0);
      author     = thomas;
      subject    = "COW: OCaml on the Web";
      body       = File "cow.md";
      permalink  = "cow";
    };

    {
      updated    = date (2010, 11, 4, 16, 30);
      author     = thomas;
      subject    = "Introduction to HTCaML";
      body       = File "htcaml.md";
      permalink  = "htcaml";
    };

    {
      updated    = date (2014, 04, 16, 17, 30);
      author     = tal;
      subject    = "Running Xen on the Cubieboard2";
      body       = File "xen-on-cubieboard2.md";
      permalink  = "xen-on-cubieboard2";
    };
  ]
end

module Links = struct
  open Cowabloga.Date
  open Cowabloga.Links
  let press = {
    name="press-coverage";
    icon="fa-pencil";
  }

  let talk = {
    name="public-talk";
    icon="fa-pencil";
  }

  let blog = {
    name="public-blog";
    icon="fa-user";
  }

  let entries = [
    { id="nw-lang-mirageos";
      uri=Uri.of_string "http://www.networkworld.com/slideshow/149127/beyond-the-usual-suspects-10-hot-programming-languages-on-the-rise.html#slide10";
      title="Beyond the usual suspects: 10 hot programming languages on the rise";
      date=day(2014,04,17);
      stream=press;
    };
    { id="citirx-containers-xen";
      uri=Uri.of_string "http://open.citrix.com/blog/328-are-containers-the-right-answer-to-the-wrong-question.html";
      title="Are Containers the Right Answer to the Wrong Question?";
      date=day(2014,04,08);
      stream=blog;
    };
    
    { id="mindy-unikernel-1";
      uri=Uri.of_string "http://www.somerandomidiot.com/blog/2014/03/14/its-a-mirage/";
      title="It's a Mirage! (or, How to Shave a Yak.)";
      date=day(2014,03,14);
      stream=blog;
    };

    { id="amirmc-jekyll-1";
      uri=Uri.of_string "http://amirchaudhry.com/from-jekyll-to-unikernel-in-fifty-lines/";
      title="From Jekyll site to Unikernel in fifty lines of code";
      date=day(2014,03,10);
      stream=blog;
    };

    { id="pcworld-2014-xenarm";
      uri=Uri.of_string "http://www.pcworld.com/article/2106460/xen-hypervisor-moves-into-arm-space.html";
      title="Xen hypervisor moves into ARM space";
      date=day(2014,03,10);
      stream=press;
    };
    { id="fosdem-2014-video";
      uri=Uri.of_string "http://video.fosdem.org/2014/Janson/Sunday/MirageOS_compiling_functional_library_operating_systems.webm";
      title="FOSDEM 2014: MirageOS: compiling functional library operating systems";
      date=day(2014,02,02);
      stream=talk;
    };
    { id="fosdem-2014";
      uri=Uri.of_string "https://fosdem.org/2014/interviews/2014-anil-madhavapeddy-richard-mortier/";
      title="Interview with Anil Madhavapeddy and Richard Mortier on MirageOS";
      date=day(2014,01,29);
      stream=press;
    };
    { id="osnews-2014";
      uri=Uri.of_string "http://www.osnews.com/comments/27516?view=threaded&sort=&threshold=0";
      title="OSNews: MirageOS: rise of the virtual library operating system";
      date=day(2014,01,15);
      stream=press;
    };
    { id="nymote-mirage-ann-2014";
      uri=Uri.of_string "http://nymote.org/blog/2014/announcing-first-mirage-release/";
      title="Nymote.org: Announcing the first major release of Mirage - the Cloud Operating System";
      date=day(2014,01,13);
      stream=press;
    };
    { id="infoworld-mirage-2014";
      uri=Uri.of_string "http://www.infoworld.com/t/operating-systems/xen-mirage-the-less-more-cloud-os-233823";
      title="Xen Mirage: The less-is-more cloud OS";
      date=day(2014,01,09);
      stream=press;
    };
    { id="infoq-rwo-2013";
      uri=Uri.of_string "http://www.infoq.com/articles/real-world-ocaml-interview";
      title="Book Review and Interview: Real World OCaml";
      date=day(2014,01,08);
      stream=press;
    };
    { id="techweek-europe-2013";
      uri=Uri.of_string "http://www.techweekeurope.co.uk/comment/xen-launches-mirage-cloud-os-133875";
      title="Xen Launches The Mirage Cloud OS";
      date=day(2013,12,11);
      stream=press;
    };
    {
      id="linuxcom-cloud-os-2013";
      uri=Uri.of_string "http://www.linux.com/news/enterprise/cloud-computing/751156-are-cloud-operating-systems-the-next-big-thing-";
      title="Linux.com: Are Cloud Operating Systems the Next Big Thing?";
      date=day (2013,12,03);
      stream=press;
    };
    {
      id="infoq-mirageos-2013";
      uri=Uri.of_string "http://www.infoq.com/news/2013/12/mirageos";
      title="InfoQ: Xen Project Releases 1.0 of Mirage OS";
      date=day (2013,12,23);
      stream=press;
    };
    {
      id="eweek-mirageos-2013";
      uri=Uri.of_string "http://www.eweek.com/cloud/xen-project-builds-its-own-cloud-os-mirage.html/";
      title="eWeek: Xen Project Builds Its Own Cloud OS Mirage";
      date=day (2013,12,09);
      stream=press;
    };
    {
      id="xenproject-mirageos-2013";
      uri=Uri.of_string "http://www.xenproject.org/about/in-the-news/162-xen-project-releases-mirage-os-welcomes-arm-as-newest-member.html";
      title="Xen Project Releases Mirage OS, Welcomes ARM as Newest Member";
      date=day (2013,12,09);
      stream=press;
    };
  ]

  let streams = [ press ]
end
