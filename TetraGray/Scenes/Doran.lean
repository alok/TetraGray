import TetraGray.Clifford
import TetraGray.Raytracer
import TetraGray.Image

namespace Scenes.Doran
open MultiVector
open Raytracer
open Image

/-- Create a sphere scene object -/
def createSphere (center : MV4 Float) (radius : Float) (material : Material) : SceneObject :=
  let intersect := fun (ray : Ray) =>
    let oc := ray.origin - center
    let a := ray.direction ⋅ ray.direction
    let b := 2 * (oc ⋅ ray.direction)
    let c := (oc ⋅ oc) - radius * radius

    let discriminant := b * b - 4 * a * c
    if discriminant < 0 then
      none
    else
      let dist := (-b - Float.sqrt discriminant) / (2 * a)
      if dist <= 0 then none else
        let pos := ray.origin + ray.direction * dist
        let normal := (pos - center) / radius
        some ⟨dist, pos, normal, ⟩

  ⟨intersect, material⟩

/-- Create the Doran scene -/
def createDoranScene : Scene :=
  -- Materials
  let redMaterial : Material := ⟨
    color := rgb 0.8 0.1 0.1,
    ambient := 0.1,
    diffuse := 0.7,
    specular := 0.3,
    shininess := 32,
    reflectivity := 0.5
  ⟩

  let blueMaterial : Material := ⟨
    color := rgb 0.1 0.1 0.8,
    ambient := 0.1,
    diffuse := 0.7,
    specular := 0.3,
    shininess := 32,
    reflectivity := 0.5
  ⟩

  let greenMaterial : Material := ⟨
    color := rgb 0.1 0.8 0.1,
    ambient := 0.1,
    diffuse := 0.7,
    specular := 0.3,
    shininess := 32,
    reflectivity := 0.5
  ⟩

  -- Create spheres in a formation
  let sphere1 := createSphere (MV4.e1 * 3) 1 redMaterial
  let sphere2 := createSphere (MV4.e2 * 3) 1 blueMaterial
  let sphere3 := createSphere (MV4.e3 * 3) 1 greenMaterial

  -- Lights
  let light1 := MV4.e0 * 10 + MV4.e1 * 10 + MV4.e2 * 10
  let light2 := MV4.e0 * (-10) + MV4.e1 * 10 + MV4.e2 * 10

  ⟨
    objects := #[sphere1, sphere2, sphere3],
    lights := #[light1, light2],
    background := rgb 0.2 0.2 0.2,
    ambient := 0.1
  ⟩

/-- Create the camera for the Doran scene -/
def createDoranCamera : Camera :=
  ⟨
    position := MV4.e0 * 10,
    lookAt := MV4.e0 * 0,
    up := MV4.e2,
    fov := 60,
    aspect := 1.0
  ⟩

/-- Render the Doran scene -/
def renderDoranScene (width height : Nat) : IO Unit := do
  let scene := createDoranScene
  let camera := createDoranCamera

  IO.println s!"Rendering Doran scene at {width}x{height}..."
  let image := render scene camera width height 3

  IO.println "Writing image to doran.ppm..."
  image.writePPM "doran.ppm"
  IO.println "Done!"

/-- Main entry point -/
def main : IO Unit :=
  renderDoranScene 800 800

end Scenes.Doran
