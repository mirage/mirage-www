open Printf

type ent = {
  updated: int * int * int * int * int; (* year,month,day,hour,min *)
  author: Atom.author;
  subject: string;
  category: string * string; (* category, subcategory, see list of them below *)
  body: string;
  permalink: string;
}

let anil = { Atom.name="Anil Madhavapeddy"; uri=Some "http://anil.recoil.org"; email=Some "anil@recoil.org" }
let thomas = { Atom.name="Thomas Gazagnaire"; uri=Some "http://gazagnaire.org"; email=Some "thomas.gazagnaire@gmail.com" }
let rights = Some "All rights reserved by the author"

let categories = [
  "overview", [
      "website"; "installation"; "papers"
  ];
  "language", [
      "syntax"; "dyntype"
  ];
  "backend", [
      "unix"; "xen"; "browser"; "arm"; "mips"
  ];
  "network", [
      "ethernet"; "dhcp"; "arp"; "tcpip"; "dns"; "http"; "typeropes"
  ];
  "storage", [
      "block"; "files"; "orm"
  ];
  "concurrency", [
      "threads"; "processes"
  ];
]

let entries = [
  { updated=2010,10,11,15,0;
    author=anil;
    subject="Self-hosting Mirage website";
    body="blog-welcome.md";
    permalink="self-hosting-mirage-website";
    category="overview","website";
  };

  { 
    updated=2010,11,4,16,30;
    author=thomas;
    subject="A (quick) introduction to HTCaML";
    category="language","syntax";
    body="htcaml-part1.md";
    permalink="introduction-to-htcaml";
  };
]

let num_categories l1 l2 =
  List.fold_left (fun a e ->
    let l1',l2' = e.category in
    if l1'=l1 && l2'=l2 then a+1 else a
  ) 0 entries

let permalink e =
  sprintf "%s/blog/%s" Config.baseurl e.permalink

let atom_entry_of_ent filefn e =
  let meta = { Atom.id=permalink e; title=`Text e.subject;
    subtitle=`Empty; author=Some e.author; contributors=[];
    updated=e.updated; rights } in
  let content = `XML (filefn e.body) in
  { Atom.entry=meta; summary=`Empty; content }
  
let atom_feed filefn es = 
  let es = List.rev (List.sort compare es) in
  let updated = (List.hd es).updated in
  let id = sprintf "%s/blog/" Config.baseurl in
  let title = `Text "openmirage blog" in
  let subtitle = `Text "a cloud operating system" in
  let author = Some anil in
  let contributors = [ anil; thomas ] in
  let feed = { Atom.id; title; subtitle; author; contributors; rights; updated } in
  let entries = List.map (atom_entry_of_ent filefn) es in
  { Atom.feed=feed; entries }

let bar = []

