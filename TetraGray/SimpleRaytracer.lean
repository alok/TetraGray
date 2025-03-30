import TetraGray.PPMTest

namespace SimpleRaytracer

open PPMTest

/-- A 3D vector -/
structure Vec3 where
  x : Float
  y : Float
  z : Float
  deriving Repr

/-- Create a Vec3 -/
def vec3 (x y z : Float) : Vec3 := ⟨x, y, z⟩

instance : Zero Vec3 where
  zero := ⟨0, 0, 0⟩

instance : Add Vec3 where
  add v₁ v₂ := ⟨v₁.x + v₂.x, v₁.y + v₂.y, v₁.z + v₂.z⟩

instance : Sub Vec3 where
  sub v₁ v₂ := ⟨v₁.x - v₂.x, v₁.y - v₂.y, v₁.z - v₂.z⟩

instance : Neg Vec3 where
  neg v := ⟨-v.x, -v.y, -v.z⟩

instance : HMul Float Vec3 Vec3 where
  hMul s v := ⟨s * v.x, s * v.y, s * v.z⟩

instance : HMul Vec3 Float Vec3 where
  hMul v s := ⟨v.x * s, v.y * s, v.z * s⟩

/-- Dot product of two vectors -/
def dot (v₁ v₂ : Vec3) : Float :=
  v₁.x * v₂.x + v₁.y * v₂.y + v₁.z * v₂.z

/-- Squared length of a vector -/
def lengthSquared (v : Vec3) : Float :=
  dot v v

/-- Length of a vector -/
def length (v : Vec3) : Float :=
  (lengthSquared v).sqrt

/-- Normalize a vector -/
def normalize (v : Vec3) : Vec3 :=
  let len := length v
  if len > 0 then v * (1.0 / len) else v

/-- A ray with origin and direction -/
structure Ray where
  origin : Vec3
  direction : Vec3
  deriving Repr

/-- Create a ray -/
def ray (origin direction : Vec3) : Ray := ⟨origin, direction⟩

/-- Get point along ray at parameter t -/
def Ray.at (r : Ray) (t : Float) : Vec3 :=
  r.origin + t * r.direction

/-- A sphere with center and radius -/
structure Sphere where
  center : Vec3
  radius : Float
  deriving Repr

/-- Create a sphere -/
def sphere (center : Vec3) (radius : Float) : Sphere := ⟨center, radius⟩

/-- Ray-sphere intersection result -/
inductive HitResult
  | hit (t : Float) (point : Vec3) (normal : Vec3)
  | miss
  deriving Repr

/-- Check if a ray intersects a sphere -/
def Sphere.hit (s : Sphere) (r : Ray) (tMin tMax : Float) : HitResult :=
  let oc := r.origin - s.center
  let a := lengthSquared r.direction
  let halfB := dot oc r.direction
  let c := lengthSquared oc - s.radius * s.radius
  let discriminant := halfB * halfB - a * c

  if discriminant < 0 then
    HitResult.miss
  else
    let sqrtd := discriminant.sqrt
    -- Try first root
    let t := (-halfB - sqrtd) / a
    if t < tMin || t > tMax then
      -- Try second root
      let t := (-halfB + sqrtd) / a
      if t < tMin || t > tMax then
        HitResult.miss
      else
        let point := r.at t
        let outwardNormal := (point - s.center) * (1.0 / s.radius)
        HitResult.hit t point outwardNormal
    else
      let point := r.at t
      let outwardNormal := (point - s.center) * (1.0 / s.radius)
      HitResult.hit t point outwardNormal

/-- Calculate color for a ray -/
def rayColor (r : Ray) (s : Sphere) : RGB :=
  match s.hit r 0.001 1000000.0 with
  | HitResult.hit _ _ normal =>
    -- Map normal vector to RGB color (simple shading)
    let n := normalize normal
    rgb ((n.x + 1) * 0.5) ((n.y + 1) * 0.5) ((n.z + 1) * 0.5)
  | HitResult.miss =>
    -- Simple blue sky gradient background
    let dir := normalize r.direction
    let t := 0.5 * (dir.y + 1.0)
    mix (rgb 1.0 1.0 1.0) (rgb 0.5 0.7 1.0) t

/-- Render a scene with a sphere -/
def renderScene (width height : Nat) : Image :=
  -- Set up camera
  let aspectRatio := width.toFloat / height.toFloat
  let viewportHeight := 2.0
  let viewportWidth := aspectRatio * viewportHeight
  let focalLength := 1.0

  let origin := vec3 0 0 0
  let horizontal := vec3 viewportWidth 0 0
  let vertical := vec3 0 viewportHeight 0
  let lowerLeftCorner := origin - horizontal * 0.5 - vertical * 0.5 - vec3 0 0 focalLength

  -- Create a sphere
  let sphere := sphere (vec3 0 0 (-5)) 2

  -- Create image
  let img := Image.black width height

  -- Render pixels
  let img := Id.run do
    let mut img := img
    for j in [:height] do
      for i in [:width] do
        let u := i.toFloat / (width - 1).toFloat
        let v := (height - 1 - j).toFloat / (height - 1).toFloat

        let dir := lowerLeftCorner + u * horizontal + v * vertical - origin
        let r := ray origin dir

        let pixelColor := rayColor r sphere
        img := img.setPixel i j pixelColor
    img

  img

def runRaytracer : IO Unit := do
  -- Render a 256x256 image with a simple sphere
  let img := renderScene 256 256

  -- Write to PPM file
  img.writePPM "sphere_render.ppm"
  IO.println "Generated image: sphere_render.ppm"

end SimpleRaytracer

def main : IO Unit := SimpleRaytracer.runRaytracer
