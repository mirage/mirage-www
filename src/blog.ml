open Printf

type ent = {
  year: int;
  month: int;
  day: int;
  author: string;
  author_link: string;
  subject: string;
  tags: string list;
  body: string;
}

let entries = [
  { year=2010;
    month=10;
    day=11;
    author="Anil Madhavapeddy";
    author_link="http://anil.recoil.org/";
    subject="Preparing the Mirage release";
    tags=[];
    body="blog-welcome.md"
  };

  { year=2010;
    month=11;
    day=4;
    author="Thomas Gazagnaire";
    author_link="http://gazagnaire.org/";
    subject="A (quick) introduction to HTCaML";
    tags=[];
    body="htcaml-part1.md"
  };

]

let bar = []
