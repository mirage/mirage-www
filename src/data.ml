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
        body       = "/blog/welcome.md";
        permalink  = "self-hosting-mirage-website";
      };
      { updated    = date (2011, 04, 11, 15, 0);
        author     = anil;
        subject    = "A Spring Wiki Cleaning";
        body       = "/blog/spring-cleaning.md";
        permalink  = "spring-cleaning";
      };
      { updated    = date (2011, 09, 29, 11, 10);
        author     = anil;
        subject    = "An Outing to CUFP 2011";
        body       = "/blog/an-outing-to-cufp.md";
        permalink  = "an-outing-to-cufp";
      };
      { updated    = date (2012, 02, 29, 11, 10);
        author     = mort;
        subject    = "Connected Cloud Control: OpenFlow in Mirage";
        body       = "/blog/announcing-mirage-openflow.md";
        permalink  = "announcing-mirage-openflow";
      };
      { updated    = date (2012, 9, 12, 0, 0);
        author     = dave;
        subject    = "Building a \"xenstore stub domain\" with Mirage";
        body       = "/blog/xenstore-stub.md";
        permalink  = "xenstore-stub-domain";
      };
      { updated    = date (2012, 10, 17, 17, 30);
        author     = anil;
        subject    = "Breaking up is easy to do (with OPAM)";
        body       = "/blog/breaking-up-with-opam.md";
        permalink  = "breaking-up-is-easy-with-opam";
      };
      { updated    = date (2013, 05, 20, 16, 20);
        author     = anil;
        subject    = "The road to a developer preview at OSCON 2013";
        body       = "/blog/the-road-to-a-dev-release.md";
        permalink  = "the-road-to-a-dev-release";
      };
      { updated    = date (2013, 07, 18, 11, 20);
        author     = dave;
        subject    = "Creating Xen block devices with Mirage";
        body       = "/blog/xen-block-devices-with-mirage.md";
        permalink  = "xen-block-devices-with-mirage";
      };
      { updated    = date (2013, 08, 08, 16, 00);
        author     = mort;
        subject    = "Mirage travels to OSCON'13: a trip report";
        body       = "/blog/oscon13-trip-report.md";
        permalink  = "oscon13-trip-report";
      };
      { updated    = date (2013, 08, 23, 17, 43);
        author     = vb;
        subject    = "Introducing vchan";
        body       = "/blog/introducing-vchan.md";
        permalink  = "introducing-vchan";
      };
      { updated    = date (2013, 12, 09, 12, 0);
        author     = anil;
        subject    = "Mirage 1.0: not just a hallucination!";
        body       = "/blog/releasing-mirage.md";
        permalink  = "announcing-mirage10";
      };
      { updated    = date (2013, 12, 19, 23, 0);
        author     = anil;
        subject    = "Mirage 1.0.3 released; tutorial on building this website available";
        body       = "/blog/mirage-1.0.3-released.md";
        permalink  = "mirage-1.0.3-released";
      };
      { updated    = date (2013, 12, 29, 17, 0);
        author     = dave;
        subject    = "Understanding Xen events with Mirage";
        body       = "/blog/xen-events.md";
        permalink  = "xen-events";
      };
    ]
end

module Wiki = struct

  open People
  open Cowabloga.Date
  open Cowabloga.Wiki

  let weekly ~y ~m ~d =
    let s = sprintf "%4d-%02d-%02d" y m d in
    { updated = date (y,m,d,16,0);
      author  = anil;
      subject = "Weekly Meeting: " ^ s;
      body    = File (sprintf "weekly/%s.md" s);
      permalink = "weekly-"^s;
    }

  let entries = [
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
      body       = File "technical_background.md";
      permalink  = "technical_background";
    };

    { updated    = date (2013, 12, 09, 16, 0);
      author     = anil;
      subject    = "Frequently Asked Questions (FAQ)";
      body       = File "faq.md";
      permalink  = "faq";
    };

    { updated    = date (2013, 07, 25, 17, 56);
      author     = dave;
      subject    = "Synthesizing virtual disks for xen";
      body       = File "xen-synthesize-virtual-disk.md";
      permalink  = "xen-synthesize-virtual-disk.md";
    };

    { updated    = date (2013, 04, 23, 9, 0);
      author     = anil;
      subject    = "Developer Preview 1.0 Checklist";
      body       = File "dev-preview-checklist.md";
      permalink  = "dev-preview-checklist";
    };

    weekly ~y:2013 ~m:6 ~d:11;
    weekly ~y:2013 ~m:6 ~d:4;
    weekly ~y:2013 ~m:5 ~d:28;
    weekly ~y:2013 ~m:5 ~d:21;
    weekly ~y:2013 ~m:5 ~d:14;
    weekly ~y:2013 ~m:4 ~d:30;
    weekly ~y:2013 ~m:4 ~d:23;
    weekly ~y:2013 ~m:4 ~d:16;

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

    { updated    = date (2013, 12, 20, 22, 00);
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
  ]
end

module Links = struct
  open Cowabloga.Date
  open Cowabloga.Links
  let press = {
     name="press-coverage";
     icon="fa-pencil";
  }

  let entries = [
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
