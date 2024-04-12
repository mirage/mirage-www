(lang dune 3.8)
(using mdx 0.4)

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
   (>= 4.14))
  dune
  dream
  dream-mirage
  (tcpip (>= 8.0))
  (mirage-time (>= 3.0))
  (mirage-kv-mem (>= 3.2.1))
  (mirage-clock-unix (>= 3.0))
  (mirage-unix (>= 5.0.0))
  (ptime (>= 0.8.1))
  (mdx :with-test)
  (mirage :with-test)
  (tailwindcss :build)
  (crunch (and :build (>= 3.1.0)))
  (omd (and :build (< 2.0.0~alpha3)))
  (yaml :build)
  (fmt :build)
  (ppx_deriving_yaml (and :build (>= 0.2.1)))))
