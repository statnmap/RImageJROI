#' @param crs fake coordinate reference system for spatial objects (projected crs in meters is better)
#' @param check_ring_dir Logical. Set polygon in classical direction. If FALSE, anti-clockwise direction is supposed to be a hole inside a polygon.
#' 
#' @importFrom sf st_sf st_polygon st_linestring st_multipoint
#' @importFrom dplyr mutate tibble rowwise
#' 
#' @rdname ij_as_sf
#' 
#' @export
ijroi_as_sf <- function(x, crs = 2154, check_ring_dir = TRUE) {
  # with(x, {
  strType <- x$strType
  name <- x$name

  if (strType == "noRoi") stop("Nothing to convert. Remove 'noRoi' objects.")
  if (strType == "rect") {
    coords <- cbind(
      c(x$left, x$left, x$right, x$right, x$left),
      c(x$bottom, x$top, x$top, x$bottom, x$bottom)
    )
    res <- tibble(
      geometry = list(st_polygon(list(coords)))
    )
    # rect(left, bottom, right, top, ...)
  } else if (strType == "oval") {
    theta <- seq(0, 2*pi, len = 360)
    coords <- cbind(x$left + x$width/2*(1 + sin(theta)),
                    x$top + x$height/2*(1 + cos(theta)))
    res <- tibble(
      geometry = list(st_polygon(list(coords)))
    )
    # polygon(left + width/2*(1 + sin(theta)),
    #         top + height/2*(1 + cos(theta)), ...)
  } else if (strType == "line") {
    # if (!is.null(x$strSubtype) && x$subtype == 2) {
    #   res <- tibble(
    #     x1 = x$x1, y1 = x$y1,
    #     x2 = x$x2, y2 = x$y2) %>% 
    #     rowwise() %>% 
    #     mutate(
    #       geometry = list(st_linestring(matrix(c(x1, x2, y1, y2), ncol = 2)))
    #     )
    #   check_ring_dir <- FALSE
    #   # arrows(x0 = x1, y0 = y1, x1 = x2, y1 = y2, lwd = strokeWidth, ...)
    # } else {
      # if (is.null(x$strSubtype)) {
      res <- tibble(
        geometry = list(st_linestring(x$coords))
      )
      check_ring_dir <- FALSE
      # lines(coords, ...)
    # }
  } else if (strType %in% c("polygon", "traced")) {
    coords <- rbind(x$coords, x$coords[1,])
    res <- tibble(
      geometry = list(st_polygon(list(coords)))
    )
  } else if (x$strType %in% c("freehand")) {
    if (is.null(x$strSubtype) && x$strSubtype %in% c("ELLIPSE")) {
      centerX <- (x$x1 + x$x2)/2
      centerY <- (x$y1 + x$y2)/2
      theta <- seq(0, 2*pi, len = 360)
      dx <- x$x2 - x$x1
      dy <- x$y2 - x$y1
      major <- sqrt(dx^2 + dy^2)
      minor <- major*x$aspectRatio
      a <- major/2
      b <- minor/2
      phi <- atan2(dy, dx)
      ellipX <- centerX + a*cos(theta)*cos(phi) - b*sin(theta)*sin(phi)
      ellipY <- centerY + a*cos(theta)*sin(phi) + b*sin(theta)*cos(phi)
      # polygon(ellipX, ellipY, ...)
      coords <- rbind(ellipX, ellipY)
      tibble(
        geometry = list(st_polygon(list(coords)))
      )
    } else {
      res <- tibble(
        geometry = list(st_linestring(x$coords))
      )
      check_ring_dir <- FALSE
      # lines(coords, ...)
    }
  } else if (strType %in% c("polyline", "freeline", "angle")) {
    res <- tibble(
      geometry = list(st_linestring(x$coords))
    )
    check_ring_dir <- FALSE
    # lines(coords, ...)
  } else if (strType == "point") {
    res <- tibble(
      geometry = list(st_multipoint(x$coords))
    )
    check_ring_dir <- FALSE
    # points(coords, ...)
  } else {
    stop("strType is not of known type")
  }

   res %>% 
    mutate(name = name) %>% 
    st_sf(crs = crs, check_ring_dir = check_ring_dir)

  # })
}

#' @importFrom sf st_cast
#' @rdname ij_as_sf
#' 
#' @export
ijzip_as_sf <- function(x, ...) {
  res <- lapply(x, function(x) ijroi_as_sf(x, ...))
  do.call("rbind", res) %>% 
    st_cast()
}

#' Transform roi file as sf object
#' 
#' @param x \code{\link[=read.ijroi]{ijroi}} or \code{\link[=read.ijzip]{ijzip}} object to be converted.
#' @param ... optional parameters of \code{\link{ijroi_as_sf}}
#' 
#' @return A simple feature object (spatial vector object) with a fake coordinate reference system.
#' 
#' @seealso \code{\link{read.ijroi}} \code{\link{read.ijzip}} 
#' 
#' @examples
#' file <- system.file("extdata", "ijroi", "ijzip.zip", package = "RImageJROI")
#' x <- read.ijzip(file)
#' x_sf <- ij_as_sf(x)
#' plot(x_sf)
#' 
#' @export
ij_as_sf <- function(x, ...) {
  if (class(x) == "ijroi") {
    ijroi_as_sf(x, ...)
  } else if (class(x) == "ijzip") {
    ijzip_as_sf(x, ...)
  } else {
    stop("class of x is not ijroi or ijzip")
  }
}