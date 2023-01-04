module People : sig
  type t = { name : string; uri : string option; email : string option }
end

module Blog : sig
  type t = {
    updated : Ptime.t;
    authors : People.t list;
    subject : string;
    permalink : string;
    body : string;
  }

  val all : t list
end

module Wiki : sig
  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    body : string;
  }

  val all : t list
end

module Weekly : sig
  type t = {
    updated : string;
    author : People.t;
    subject : string;
    permalink : string;
    description : string;
    body : string;
  }

  val all : t list
end

module Link : sig
  type t = {
    id : string;
    uri : string;
    title : string;
    date : string;
    stream : string;
  }

  val all : t list
end

module Paper : sig
  type link = { description : string; uri : string }

  type t = {
    name : string;
    title : string;
    links : link list;
    authors : string list;
    description : string;
    abstract : string;
  }

  val all : t list
end
