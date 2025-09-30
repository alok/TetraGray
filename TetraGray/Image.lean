import TetraGray.Clifford

import TetraGray.ODE
open MultiVector ODE

namespace Image

/-- RGB color representation with values in [0,1] -/
structure RGB where
  r : Float
  g : Float
  b : Float
  deriving Repr

/-- Create an RGB color -/
def rgb (r g b : Float) : RGB := ⟨r, g, b⟩

/-- Black color -/
instance : Zero RGB where
  zero := ⟨0, 0, 0⟩

/-- Default value for RGB -/
instance : Inhabited RGB where
  default := ⟨0, 0, 0⟩

/-- White color -/
def white : RGB := ⟨1, 1, 1⟩

/-- Add two colors, clamping to [0,1] -/
instance : Add RGB where
  add c₁ c₂ := ⟨
    min 1 (c₁.r + c₂.r),
    min 1 (c₁.g + c₂.g),
    min 1 (c₁.b + c₂.b)
  ⟩

/-- Scale a color by a factor, clamping to [0,1] -/
instance : HMul Float RGB RGB where
  hMul s c := ⟨
    min 1 (s * c.r),
    min 1 (s * c.g),
    min 1 (s * c.b)
  ⟩

/-- Mix two colors with weights -/
def mix (c₁ c₂ : RGB) (t : Float) : RGB :=
  let s := 1 - t
  ⟨
    s * c₁.r + t * c₂.r,
    s * c₁.g + t * c₂.g,
    s * c₁.b + t * c₂.b
  ⟩

/-- Image with width, height, and pixel data -/
structure Image where
  width : Nat
  height : Nat
  data : Array RGB

/-- Create a black image of given dimensions -/
def Image.black (w h : Nat) : Image :=
  let data := Array.replicate (w * h) (0 : RGB)
  ⟨w, h, data⟩

/-- Get pixel at position -/
def Image.getPixel (img : Image) (x y : Nat) : RGB :=
  if x < img.width && y < img.height then
    img.data[y * img.width + x]!
  else
    0

/-- Set pixel at position -/
def Image.setPixel (img : Image) (x y : Nat) (color : RGB) : Image :=
  if x < img.width && y < img.height then
    let idx := y * img.width + x
    let data := img.data.set! idx color
    ⟨img.width, img.height, data⟩
  else
    img

/-- Write image to PPM file (common simple image format) -/
def Image.writePPM (img : Image) (filename : String) : IO Unit := do
  let mut file ← IO.FS.Handle.mk filename IO.FS.Mode.write
  -- Write PPM header
  try
    let header := s!"P3\n{img.width} {img.height}\n255\n"
    file.putStrLn header

    -- Write pixel data
    for i in [:img.height] do
      for j in [:img.width] do
        let color := img.getPixel j i
        let r := (color.r * 255).toUInt8
        let g := (color.g * 255).toUInt8
        let b := (color.b * 255).toUInt8
        file.putStr s!"{r} {g} {b} "
      file.putStrLn ""

    pure ()
  finally
    file.flush
    pure ()

end Image
