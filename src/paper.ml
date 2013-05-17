open Cow

type item = {
  href : string;
  img : string;
  alt : string;
}

let html_of_item i = <:xml<
  <a href=$str:i.href$><img src=$str:i.img$ width="22" height="22" alt=$str:i.alt$/></a>
>>

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

let html_of_paper p = <:xml<
  <p>
    <p>
      <a name=$str:p.name$/>
      $list:List.map html_of_item p.items$
      <b>$str:p.title$</b>
    </p>
    <p>
      <i>$html_of_authors p.authors$</i>.
      $p.descr$
    </p>
     <p>$p.abstract$<hr/></p>
  </p>
>>

let anil    = "Anil Madhavapeddy"
let richard = "Richard Mortier"
let rip     = "Ripduman Sohan"
let thomas  = "Thomas Gazagnaire"
let steven  = "Steven Hand"
let tim     = "Tim Deegan"
let derek   = "Derek McAuley"
let jon     = "Jon Crowcroft"
let alex    = "Alex Ho"
let dave    = "David Scott"
let haris   = "Charalampos Rotsos"
let balraj  = "Balraj Singh"
let smith   = "Steven Smith"

let pdf href = {
  href;
  img = "/graphics/pdf.png";
  alt = "PDF";
}

let acm id = {
  href = "http://portal.acm.org/citation.cfm?id=" ^ id;
  img  = "/graphics/acm.png";
  alt  = "ACM Portal";
}

let bcs id = {
  href = "http://www.bcs.org/server.php?show=" ^ id;
  img  = "/graphics/acm.png";
  alt  = "BCS homepage";
}

let prezi path = {
  href = "http://prezi.com/" ^ path;
  img  = "/graphics/prezi.png";
  alt  = "Prezi presentation";
}

let papers = [

  { name     = "asplos";
    items    = [
      pdf "http://anil.recoil.org/papers/2013-asplos-mirage.pdf";
      acm "2451116.2451167" ];
    title    = "Unikernels: library operating systems for the cloud";
    authors  = [ anil; richard; haris; dave; balraj; thomas; smith; steven; jon ];
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

  { name     = "hotcloud";
    items    = [
      pdf "http://anil.recoil.org/papers/2010-hotcloud-lamp.pdf";
      acm "1863114" ];
    title    = "Turning down the LAMP: Software Specialisation for the Cloud";
    authors  = [ anil; richard; rip; thomas; steven; tim; derek; jon ];
    descr    = <:xml<
      2nd USENIX Workshop on Hot Topics in Cloud Computing
      <a href="http://www.usenix.org/events/hotcloud10/">HotCloud '10</a>, June 2010 >>;
    abstract = <:xml<
       This paper positions work on the Xen backend for Mirage. It is a decent summary of the idea,
       although some details such as the filesystem extension are likely to be significantly different
       in the first release. >>;
  };

  { name     = "visions";
    items    = [
      pdf "http://anil.recoil.org/papers/2010-bcs-visions.pdf";
      bcs "nav.11980" ];
    title    = "Multiscale not Multicore: Efficient Heterogeneous Cloud Computing";
    authors  = [ anil; richard; jon; steven ];
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
      This paper defines the [dyntype](http://github.com/mirage/dyntype) dynamic typing extension we developed for
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
  <br />
  <p>This page lists any publications, technical reports and related work to Mirage. If you know of any work that should be listed here, please <a href="/about">contact</a> us.</p>
  <h2>Publications</h2>
  $list:List.map html_of_paper papers$
  <h2>Related Work</h2>
  $list:List.map html_of_paper related_papers$
>>
