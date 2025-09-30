namespace SimpleRT

structure RGB where
  r : Float
  g : Float
  b : Float
  deriving Repr

def rgb (r g b : Float) : RGB := ⟨r, g, b⟩

instance : Zero RGB where
  zero := ⟨0, 0, 0⟩

instance : Inhabited RGB where
  default := 0

structure Image where
  width : Nat
  height : Nat
  data : Array RGB

def Image.black (w h : Nat) : Image :=
  let data := Array.replicate (w * h) (0 : RGB)
  ⟨w, h, data⟩

def Image.getPixel (img : Image) (x y : Nat) : RGB :=
  if x < img.width && y < img.height then
    img.data[y * img.width + x]!
  else
    0

def Image.setPixel (img : Image) (x y : Nat) (color : RGB) : Image :=
  if x < img.width && y < img.height then
    let idx := y * img.width + x
    let data := img.data.set! idx color
    ⟨img.width, img.height, data⟩
  else
    img

def Image.writePPM (img : Image) (filename : String) : IO Unit := do
  let mut file ← IO.FS.Handle.mk filename IO.FS.Mode.write
  try
    let header := s!"P3\n{img.width} {img.height}\n255\n"
    file.putStrLn header

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

-- Constants for the visualization
def PI : Float := 3.14159265358979323846
def extractRadius : Float := 50.0

/-- Calculate atan2 approximation -/
def atan2 (y x : Float) : Float :=
  if x == 0 then
    if y >= 0 then PI/2 else -PI/2
  else
    let t := Float.atan (y / x)
    if x < 0 then t + PI else t

/-- Minimum of two Float values -/
def minFloat (a b : Float) : Float :=
  if a < b then a else b

-- Simplified Doran-like visualization function
def createDoranVisualization (width height : Nat) : Image := Id.run do
  let mut img := Image.black width height
  let centerX := width.toFloat / 2
  let centerY := height.toFloat / 2
  let radius := (minFloat centerX centerY) * 0.8

  -- Create a colorful grid pattern with a black hole effect
  for y in [:height] do
    for x in [:width] do
      let dx := x.toFloat - centerX
      let dy := y.toFloat - centerY
      let distance := (dx * dx + dy * dy).sqrt

      -- Calculate normalized polar coordinates
      let theta := atan2 dy dx + PI
      let normTheta := theta / (2 * PI)

      -- Color based on quadrants and distance
      -- Use simple if/else approach instead of modular arithmetic
      let quadrant :=
        if theta < PI/2 then 0     -- 0 to π/2
        else if theta < PI then 1  -- π/2 to π
        else if theta < 3*PI/2 then 2  -- π to 3π/2
        else 3                     -- 3π/2 to 2π

      -- Base color for each quadrant
      let baseColor := match quadrant with
        | 0 => rgb 1 0 0  -- Red
        | 1 => rgb 0 1 0  -- Green
        | 2 => rgb 0 0 1  -- Blue
        | _ => rgb 1 1 0  -- Yellow

      -- Apply black hole effect
      if distance < radius * 0.2 then
        -- Black hole center
        img := img.setPixel x y (rgb 0 0 0)
      else if distance < radius then
        -- Distortion effect near the black hole
        let distortionFactor := 1 - (distance / radius)
        let warpFactor := 1 + 2 * distortionFactor

        -- Create grid effect
        let gridX := Float.sin (dx * warpFactor / 30)
        let gridY := Float.sin (dy * warpFactor / 30)
        let gridPattern := Float.abs (gridX * gridY)

        -- Mix colors based on distance
        let r := baseColor.r * gridPattern
        let g := baseColor.g * gridPattern
        let b := baseColor.b * gridPattern

        img := img.setPixel x y (rgb r g b)
      else
        -- Background
        let bgFactor := 0.2
        img := img.setPixel x y (rgb (baseColor.r * bgFactor) (baseColor.g * bgFactor) (baseColor.b * bgFactor))

  return img

def main : IO Unit := do
  IO.println "Creating simplified Doran-like visualization..."

  let img := createDoranVisualization 800 600
  img.writePPM "doran_simplified.ppm"

  IO.println "Image generated: doran_simplified.ppm"

  -- To convert to PNG, run this command manually:
  -- convert doran_simplified.ppm doran_simplified.png
  IO.println "To convert to PNG, run: convert doran_simplified.ppm doran_simplified.png"

end SimpleRT

def main : IO Unit := SimpleRT.main
