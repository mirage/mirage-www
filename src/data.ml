open Cow

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
    ]
end
