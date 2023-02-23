(lang dune 2.7)

(name mirageio)

(documentation "https://mirage.github.io/mirage-www/")

(source
 (github mirage/mirage-www))

(license ISC)

(authors
  "Anil Madhavapeddy"
  "Amir Chaudhry"
  "Thomas Gazagnaire"
  "Richard Mortier"
  "Hannes Mehnert"
  "Mindy Preston"
  "Lucas Pluvinage"
  "Thomas Leonard"
  "Dave Scott"
  "Martin Keegan"
  "Thibaut Mattio")

(maintainers "mirageos-devel@list.xenproject.org")

(generate_opam_files true)

(package
 (name mirageio)
 (synopsis "Website infrastructure and content for mirage.io")
 (description "Website infrastructure and content for mirage.io")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  dream
  dream-mirage
  mirage-kv-mem
  mirage-clock-unix
  mirage-unix
  (tailwindcss :build)
  (crunch (and :build (>= 3.1.0)))
  (omd :build)
  (yaml :build)
  (fmt :build)
  (ppx_deriving_yaml :build)))
