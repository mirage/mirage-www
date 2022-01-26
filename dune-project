(lang dune 2.7)

(name mirageio)

(documentation "https://tmattio.github.io/mirageio/")

(source
 (github tmattio/mirageio))

(license ISC)

(authors "Thibaut Mattio")

(maintainers "Thibaut Mattio")

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
  mimic ; dependency of dream-mirage.paf
  (crunch :build)
  (omd :build)
  (yaml :build)
  (fmt :build)
  (ppx_deriving_yaml :build)))
