% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ij_as_sf.R
\name{ijroi_as_sf}
\alias{ijroi_as_sf}
\alias{ijzip_as_sf}
\alias{ij_as_sf}
\title{Transform roi file as sf object}
\usage{
ijroi_as_sf(x, crs = 2154, check_ring_dir = TRUE)

ijzip_as_sf(x, ...)

ij_as_sf(x, ...)
}
\arguments{
\item{x}{\code{\link[=read.ijroi]{ijroi}} or \code{\link[=read.ijzip]{ijzip}} object to be converted.}

\item{crs}{fake coordinate reference system for spatial objects (projected crs in meters is better)}

\item{check_ring_dir}{Logical. Set polygon in classical direction. If FALSE, anti-clockwise direction is supposed to be a hole inside a polygon.}

\item{...}{optional parameters of \code{\link{ijroi_as_sf}}}
}
\value{
A simple feature object (spatial vector object) with a fake coordinate reference system.
}
\description{
Transform roi file as sf object
}
\examples{
file <- system.file("extdata", "ijroi", "ijzip.zip", package = "RImageJROI")
x <- read.ijzip(file)
x_sf <- ij_as_sf(x)
plot(x_sf)

}
\seealso{
\code{\link{read.ijroi}} \code{\link{read.ijzip}}
}
