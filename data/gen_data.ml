module People = struct
  type t = { name : string; uri : string option; email : string option }
  [@@deriving yaml]

  let pp ppf v =
    Fmt.pf ppf
      {|
    { name = %a
    ; uri = %a
    ; email = %a
    }|}
      Pp.string v.name (Pp.option Pp.string) v.uri (Pp.option Pp.string) v.email
end

module Blog = struct
  type meta = {
    updated : string;
    authors : People.t list;
    subject : string;
    permalink : string;
  }
  [@@deriving yaml]

  type t = {
    updated : Ptime.t;
    authors : People.t list;
    subject : string;
    permalink : string;
    body : string;
  }

  let all () =
    Utils.map_md_files_in_dir ~decode_meta:meta_of_yaml
      (fun ~file:_ ~meta ~body ->
        let date =
          let int = int_of_string in
          match String.split_on_char '-' meta.updated with
          | [ year; month; day ] -> (int year, int month, int day)
          | _ -> failwith ("failed to parse date: '" ^ meta.updated ^ "'")
        in
        {
          updated = Ptime.of_date date |> Option.get;
          authors = meta.authors;
          subject = meta.subject;
          permalink = meta.permalink;
          body =
            Cmarkit.Doc.of_string ~strict:true ~heading_auto_ids:true body
            |> Hilite_markdown.transform
            |> Cmarkit_html.of_doc ~safe:false;
        })
      "data/blog/"
    |> List.sort (fun x1 x2 -> Ptime.compare x1.updated x2.updated)
    |> List.rev

  let pp ppf v =
    Fmt.pf ppf
      {|
    { updated = Ptime.of_float_s %f |> Option.get
    ; authors = %a
    ; subject = %a
    ; permalink = %a
    ; body = %a
    }|}
      (Ptime.to_float_s v.updated)
      (Pp.list People.pp) v.authors Pp.string v.subject Pp.string v.permalink
      Pp.string v.body
end

module Wiki = struct
  type meta = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
  }
  [@@deriving yaml]

  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    body : string;
  }

  let all () =
    Utils.map_md_files_in_dir ~decode_meta:meta_of_yaml
      (fun ~file:_ ~meta ~body ->
        {
          updated = meta.updated;
          author = meta.author;
          subject = meta.subject;
          permalink = meta.permalink;
          body =
            Cmarkit.Doc.of_string ~strict:true ~heading_auto_ids:true body
            |> Hilite_markdown.transform
            |> Cmarkit_html.of_doc ~safe:false;
        })
      "data/wiki/"
    |> List.sort (fun x1 x2 -> String.compare x1.updated x2.updated)
    |> List.rev

  let pp ppf v =
    Fmt.pf ppf
      {|
    { updated = %a
    ; author = %a
    ; subject = %a
    ; permalink = %a
    ; body = %a
    }|}
      Pp.string v.updated People.pp v.author Pp.string v.subject Pp.string
      v.permalink Pp.string v.body
end

module Weekly = struct
  type meta = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    description : string;
  }
  [@@deriving yaml]

  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    description : string;
    body : string;
  }

  let all () =
    Utils.map_md_files_in_dir ~decode_meta:meta_of_yaml
      (fun ~file:_ ~meta ~body ->
        {
          updated = meta.updated;
          author = meta.author;
          subject = meta.subject;
          permalink = meta.permalink;
          description = meta.description;
          body =
            Cmarkit.Doc.of_string ~strict:true ~heading_auto_ids:true body
            |> Hilite_markdown.transform
            |> Cmarkit_html.of_doc ~safe:false;
        })
      "data/weekly/"
    |> List.sort (fun x1 x2 -> String.compare x1.updated x2.updated)
    |> List.rev

  let pp ppf v =
    Fmt.pf ppf
      {|
    { updated = %a
    ; author = %a
    ; subject = %a
    ; permalink = %a
    ; description = %a
    ; body = %a
    }|}
      Pp.string v.updated People.pp v.author Pp.string v.subject Pp.string
      v.permalink Pp.string v.description Pp.string v.body
end

module Link = struct
  type t = {
    id : string;
    uri : string;
    title : string;
    date : string;
    stream : string;
  }
  [@@deriving yaml]

  let all () = Utils.with_yml_file ~decoder:of_yaml "data/link/links.yml"

  let pp ppf v =
    Fmt.pf ppf
      {|
    { id = %a
    ; uri = %a
    ; title = %a
    ; date = %a
    ; stream = %a
    }|}
      Pp.string v.id Pp.string v.uri Pp.string v.title Pp.string v.date
      Pp.string v.stream
end

module Paper = struct
  type link = { description : string; uri : string } [@@deriving yaml]

  type t = {
    name : string;
    title : string;
    links : link list;
    authors : string list;
    description : string;
    abstract : string;
  }
  [@@deriving yaml]

  let all () = Utils.with_yml_file ~decoder:of_yaml "data/paper/papers.yml"

  let pp_link ppf (v : link) =
    Fmt.pf ppf
      {|
          { description = %a
          ; uri = %a
          }|}
      Pp.string v.description Pp.string v.uri

  let pp ppf v =
    Fmt.pf ppf
      {|
    { name = %a
    ; title = %a
    ; links = %a
    ; authors = %a
    ; description = %a
    ; abstract = %a
    }|}
      Pp.string v.name Pp.string v.title (Pp.list pp_link) v.links
      (Pp.list Pp.string) v.authors Pp.string v.description Pp.string v.abstract
end

let output =
  Format.asprintf
    {|module People = struct
  type t = { name : string; uri : string option; email : string option }
end

module Blog = struct
  type t = {
    updated : Ptime.t;
    authors : People.t list;
    subject : string;
    permalink : string;
    body : string;
  }

  let all = %a
end

module Wiki = struct
  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    body : string;
  }

  let all = %a
end

module Weekly = struct
  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    description : string;
    body : string;
  }

  let all = %a
end

module Link = struct
  type t = {
    id : string;
    uri : string;
    title : string;
    date : string;
    stream : string;
  }

  let all = %a
end

module Paper = struct
  type link = { description : string; uri : string }

  type t = {
    name : string;
    title : string;
    links : link list;
    authors : string list;
    description : string;
    abstract : string;
  }

  let all = %a
end
|}
    (Pp.list Blog.pp) (Blog.all ()) (Pp.list Wiki.pp) (Wiki.all ())
    (Pp.list Weekly.pp) (Weekly.all ()) (Pp.list Link.pp) (Link.all ())
    (Pp.list Paper.pp) (Paper.all ())

let () = print_endline output
