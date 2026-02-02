library(hexSticker)

imgurl <- "inst/logo/baby_r_logo_colored.svg"

swadl_blue = "#063957"

sticker(
  imgurl,
  s_x = 1,
  s_y = .8,
  s_width = .6,
  package = "swadlr",
  p_y = 1.6,
  p_color = swadl_blue,
  p_size = 20,
  h_fill = "white",
  h_color = swadl_blue,
  filename = "inst/logo/logo.png",
  dpi = 300
)
