usethis::use_build_ignore("devstuff_history.R")
usethis::use_pipe()
usethis::use_test("ij_as_sf")

# Documentation ----
usethis::use_readme_rmd()
usethis::use_vignette("read-roi")

# Dependencies ----
attachment::att_to_description(extra.suggests = "png")

# Dev
devtools::check()
devtools::build_vignettes()