open Cow

type item = {
  href : string;
  icon : string;
  alt : string;
}

let html_of_item i =
  let cl = Printf.sprintf "fa fa-%s" i.icon in
  <:xml<<a href=$str:i.href$><i class=$str:cl$> </i></a> >>

type author = string

let html_of_authors al =
  match List.rev al with
    | []   -> assert false
    | [a]  -> <:xml<$str:a$&>>
    | a::t -> <:xml<$str:String.concat ", " (List.rev t)$ and $str:a$&>>

type paper = {
  name : string;
  items : item list;
  title : string;
  authors : author list;
  descr : Html.t;
  abstract : Html.t;
}

let html_of_paper p = <:html<
    <h4>$str:p.title$ &nbsp; &nbsp;
    <a name=$str:p.name$> </a>$list:List.map html_of_item p.items$ </h4>
    <p>
      <i>$html_of_authors p.authors$</i>.
      <br />
      $p.descr$
    </p>
     <blockquote>$p.abstract$</blockquote>
>>

let anil    = "Anil Madhavapeddy"
let mort    = "Richard Mortier"
let rip     = "Ripduman Sohan"
let thomas  = "Thomas Gazagnaire"
let steven  = "Steven Hand"
let tim     = "Tim Deegan"
let mac     = "Derek McAuley"
let derek   = "Derek Murray"
let jon     = "Jon Crowcroft"
let alex    = "Alex Ho"
let dave    = "David Scott"
let andrew = "Andrew Moore"
let haris   = "Charalampos Rotsos"
let balraj  = "Balraj Singh"
let smith   = "Steven Smith"
let malte   = "Malte Schwarzkopf"
let theo    = "Theo Hong"
let watson = "Robert Watson"
let yminsky = "Yaron Minsky"
let jhickey = "Jason Hickey"

let pdf href = {
  href;
  icon = "cloud-download";
  alt = "PDF";
}

let acm id = {
  href = "http://portal.acm.org/citation.cfm?id=" ^ id;
  icon  = "external-link-square";
  alt  = "ACM Portal";
}

let bcs id = {
  href = "http://www.bcs.org/server.php?show=" ^ id;
  icon  = "external-link-square";
  alt  = "BCS homepage";
}

let ext id = {
  href = id;
  icon = "external-link-square";
  alt = ""
}

let prezi path = {
  href = "http://prezi.com/" ^ path;
  icon  = "desktop";
  alt  = "Prezi presentation";
}

let papers = [
  { name = "cacm";
    items = [ ext "http://queue.acm.org/detail.cfm?id=2566628" ];
    title = "Unikernels: Rise of the Virtual Library Operating System";
    authors = [ anil; dave ];
    descr = <:xml< In <a href="http://cacm.acm.org">Communications of the ACM</a>, January 2014. >>;
    abstract = <:xml< What if all the software layers in a virtual appliance were compiled within the same safe, high-level language framework? >>;
  };
  { name     = "rwo";
    items = [ ext "https://realworldocaml.org"; ];
    title = "Real World OCaml: functional programming for the masses";
    authors = [ anil; yminsky; jhickey ];
    descr = <:xml<
      Published by O'Reilly Associates, 510 pages, Nov 2013.
      >>;
    abstract = <:xml<
This fast-moving tutorial introduces you to OCaml, an industrial-strength programming language designed for expressiveness, safety, and speed. Through the book’s many examples, you’ll quickly learn how OCaml stands out as a tool for writing fast, succinct, and readable systems code.
Real World OCaml takes you through the concepts of the language at a brisk pace, and then helps you explore the tools and techniques that make OCaml an effective and practical tool. In the book’s third section, you’ll delve deep into the details of the compiler toolchain and OCaml’s simple and efficient runtime system. >>

  };
  { name     = "asplos";
    items    = [
      pdf "http://anil.recoil.org/papers/2013-asplos-mirage.pdf";
      acm "2451116.2451167" ];
    title    = "Unikernels: library operating systems for the cloud";
    authors  = [ anil; mort; haris; dave; balraj; thomas; smith; steven; jon ];
    descr    = <:xml<
      Proceedings of the 18th International Conference on Architectural Support for Programming Languages and Operating Systems
      <a href="http://asplos13.rice.edu/">ASPLOS '13</a>, April, 2013 >>;
    abstract = <:xml<
       We present <em>unikernels</em>, a new approach to deploying cloud services via
       applications written in high-level source code. Unikernels are
       single-purpose appliances that are compile-time specialised into
       standalone kernels, and sealed against modification when deployed to a
       cloud platform. In return they offer significant reduction in image
       sizes, improved efficiency and security, and should reduce operational
       costs. Our Mirage prototype compiles OCaml code into unikernels that
       run on commodity clouds and offer an order of magnitude reduction in
       code size without significant performance penalty. The architecture
       combines static type-safety with a single address-space layout that can
       be made immutable via a hypervisor extension. Mirage contributes a
       suite of type-safe protocol libraries, and our results demonstrate that
       the hypervisor is a platform that overcomes the hardware compatibility
       issues that have made past library operating systems impractical to
       deploy in the real-world. >>;
  };

  { name = "openflow";
    items = [
      pdf "http://www.cs.nott.ac.uk/~rmm/papers/pdf/iccsdn12-mirageof.pdf";
    ];
    title = "Cost, Performance & Flexibility in OpenFlow: Pick Three";
    authors = [ mort; haris; anil; balraj; andrew];
    descr = <:xml<
      Proceedings of IEEE ICC Software Defined Networking workshop, June 2012.
        >>;
    abstract = <:xml<
      >>;
  };

  { name = "droplets";
    items = [
      pdf "http://www.cs.nott.ac.uk/~rmm/papers/pdf/icdcn11-droplets.pdf";
    ];
    title = "Unclouded Vision";
    authors = [ jon; anil; malte; theo; mort ];
    descr = <:xml<
      Proceedings of 12th International Conference on Distributed Computing and Networking
      <a href="http://icdcn2012.comp.polyu.edu.hk/">ICDCN '11</a>, January 2011. Invited paper.
      >>;
    abstract = <:xml<
      >>;
  };

  { name     = "hotcloud";
    items    = [
      pdf "http://anil.recoil.org/papers/2010-hotcloud-lamp.pdf";
      acm "1863114" ];
    title    = "Turning down the LAMP: Software Specialisation for the Cloud";
    authors  = [ anil; mort; rip; thomas; steven; tim; mac; jon ];
    descr    = <:xml<
      2nd USENIX Workshop on Hot Topics in Cloud Computing
      <a href="http://www.usenix.org/events/hotcloud10/">HotCloud '10</a>, June 2010 >>;
    abstract = <:xml<
       This paper positions work on the Xen backend for Mirage. It is a decent summary of the idea,
       although some details such as the filesystem extension are likely to be significantly different
       in the first release. >>;
  };

  { name = "dustclouds";
    items = [
      pdf "http://www.cs.nott.ac.uk/~rmm/papers/pdf/iwsp10-dustclouds.pdf";
    ];
    title = "Using Dust Clouds to Enhance Anonymous Communication";
    authors = [ mort; anil; theo; derek; malte ];
    descr = <:xml<
      Proceedings of the 18th International Workshop on Security Protocols (IWSP), April 2010
      >>;
    abstract = <:xml<
      >>;
  };

  { name     = "visions";
    items    = [
      pdf "http://anil.recoil.org/papers/2010-bcs-visions.pdf";
      bcs "nav.11980" ];
    title    = "Multiscale not Multicore: Efficient Heterogeneous Cloud Computing";
    authors  = [ anil; mort; jon; steven ];
    descr    = <:xml<
      ACM/BCS <a href="http://www.bcs.org/server.php?show=nav.11980">Visions of Computer Science</a>, April 2010 >>;
    abstract = <:xml<
      This is a vision paper that lays out the broader background to the project, including some of the problem
      areas we are tackling in social networking and scientific computing.  The first half is a good introduction
      to the area, but read the later <a href="#hotcloud">HotCloud</a> paper instead of the technical second half. >>;
  };

  { name     = "wgt";
    items    = [
      pdf "http://anil.recoil.org/papers/2010-dyntype-wgt.pdf";
      prezi "qjkrijlacqiq/mirage/" ];
    title    = "Statically-typed value persistence for ML";
    authors  = [ thomas; anil ];
    descr    = <:xml<
      <a href="http://wgt2010.elte.hu/">Workshop on Generative Technologies</a>, April 2010 >>;
    abstract = <:xml<
      This paper defines the <a href="http://github.com/mirage/dyntype">dyntype</a> dynamic typing extension we developed for
      OCaml, and the SQL mapper that converts ML values directly into SQL calls. The approach is useful as it is
      purely meta-programming instead of compiler patching, and thus much easier to integrate with other OCaml code.
      There is an extended journal paper currently under review; please contact the authors if you wish to read it.>>;
   };

  { name     = "icfem";
    items    = [ pdf "http://anil.recoil.org/papers/2009-icfem-spl.pdf" ];
    authors  = [ anil ];
    title    = "Combining Static Model Checking with Dynamic Enforcement using the Statecall Policy Language";
    descr    = <:xml<
      International Conference on Formal Engineering Methods
      <a href="http://icfem09.inf.puc-rio.br/ICFEM.html">ICFEM</a>, December 2009. >>;
    abstract = <:xml<
      A small domain-specific language which compiles to both PROMELA (for static model checking) and OCaml
      (for dynamic enforcement) of state machines. This paper defines the DSL and an example against an
      <a href="http://github.com/avsm/melange/tree/master/apps/sshd">SSH server</a> written in pure OCaml.>>;
  };

  { name     = "eurosys";
    items    = [
      pdf "http://anil.recoil.org/papers/2007-eurosys-melange.pdf";
      acm "1272996.1273009" ];
    title    = "Melange: Towards a \"functional\" Internet";
    authors  = [ anil; alex; tim; dave; rip ];
    descr    = <:xml< <a href="http://www.gsd.inesc-id.pt/conference/EuroSys2007/">EuroSys 2007</a>, March 2007. >>;
    abstract = <:xml<
      The original paper that formed the basis of Mirage. We define <a href="http://github.com/avsm/mpl">MPL</a>, a
      DSL to express bi-directional packet descriptions and compile them into efficient, type-safe OCaml code.
      Performance is tested for DNS and SSH servers written in OCaml versus their C counterparts (BIND and
      OpenSSH). >>;
  }
]

let related_papers = [
  { name     = "mainname";
    items    = [ pdf "http://www.tjd.phlegethon.org/words/thesis.pdf" ];
    title    = "The Main Name System";
    authors  = [ tim ];
    descr    = <:xml< PhD Thesis, University of Cambridge, 2006. >>;
    abstract = <:xml<
      This thesis describes the Main Name System, an approach to centralising DNS for improved reliability. The source
      code for the Mirage DNS library is based directly off the data structures described in this thesis. >>;
  }
]

let html = <:xml<
  <p>This page lists any publications, technical reports and related work to Mirage. If you know of any work that should be listed here, please <a href="/about">contact</a> us.</p>
  <hr />
  $list:List.map html_of_paper papers$
  <h2>Related Work</h2>
  $list:List.map html_of_paper related_papers$
>>
