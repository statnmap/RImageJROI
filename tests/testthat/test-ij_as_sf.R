file <- system.file("extdata", "ijroi", "ijzip.zip", package = "RImageJROI")
roi_zip <- read.ijzip(file)

context("test-ij_as_sf")

test_that("returns sf object", {
  roi_zip_sf <- ij_as_sf(roi_zip)
  expect_true(
    all(sf::st_is(roi_zip_sf, 
              c("MULTIPOINT", "POLYGON", "LINESTRING", "LINESTRING",
                "POLYGON", "LINESTRING", "MULTIPOINT"))))
  expect_equal(nrow(roi_zip_sf), 7)
  expect_equal(ncol(roi_zip_sf), 2)
})
