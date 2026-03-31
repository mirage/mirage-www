let render ~blog_posts ~contributors ~last_update =
  let b = Buffer.create 4096 in
  let add = Buffer.add_string b in
  let escape s =
    s |> String.to_seq
    |> Seq.iter (function
      | '&' -> add "&amp;"
      | '<' -> add "&lt;"
      | '>' -> add "&gt;"
      | '"' -> add "&quot;"
      | c -> Buffer.add_char b c)
  in
  add {|<?xml version="1.0" encoding="utf-8"?>|};
  add "\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n";
  add "  <id>https://mirageos.org/wiki/</id>\n";
  add "  <title>The MirageOS Blog</title>\n";
  add
    "  <subtitle>The MirageOS Blog on building functional operating \
     systems</subtitle>\n";
  add "  <rights>All rights reserved by the author</rights>\n";
  add "  <updated>";
  add (Ptime.to_rfc3339 last_update);
  add "</updated>\n";
  add "  <link rel=\"self\" href=\"https://mirageos.org/feed.xml\" />\n";
  add
    "  <link rel=\"alternate\" href=\"https://mirageos.org/blog/\" \
     type=\"text/html\" />\n";
  add "\n";
  contributors
  |> List.iter (fun (item : Mirageio_data.People.t) ->
      add "  <contributor>\n";
      add "    <name>";
      add item.name;
      add "</name>\n";
      (match item.uri with
      | Some uri ->
          add "    <uri>";
          escape uri;
          add "</uri>\n"
      | None -> ());
      (match item.email with
      | Some email ->
          add "    <email>";
          escape email;
          add "</email>\n"
      | None -> ());
      add "  </contributor>\n");
  add "\n";
  blog_posts
  |> List.iter (fun (item : Mirageio_data.Blog.t) ->
      add "  <entry>\n";
      add "    <id>https://mirageos.org/blog/";
      escape item.permalink;
      add "</id>\n";
      add "    <title>";
      escape item.subject;
      add "</title>\n";
      item.authors
      |> List.iter (fun (author : Mirageio_data.People.t) ->
          add "    <author>\n";
          add "      <name>";
          add author.name;
          add "</name>\n";
          (match author.uri with
          | Some uri ->
              add "      <uri>";
              escape uri;
              add "</uri>\n"
          | None -> ());
          (match author.email with
          | Some email ->
              add "      <email>";
              escape email;
              add "</email>\n"
          | None -> ());
          add "    </author>\n");
      add "    <rights>All rights reserved by the author</rights>\n";
      add "    <updated>";
      add (Ptime.to_rfc3339 item.updated);
      add "</updated>\n";
      add "    <link rel=\"alternate\" href=\"https://mirageos.org/blog/";
      escape item.permalink;
      add "\" type=\"text/html\" />\n";
      add "    <content type=\"xhtml\">\n";
      add "      <div xmlns=\"http://www.w3.org/1999/xhtml\">\n";
      add "        ";
      add item.body;
      add "\n";
      add "      </div>\n";
      add "    </content>\n";
      add "  </entry>\n");
  add "</feed>\n";
  Buffer.contents b
