import TetraGray.Clifford
import TetraGray.Particle
import TetraGray.Image

namespace Raytracer
open MultiVector
open Image

/-- Ray in 4D space with origin and direction -/
structure Ray where
  origin : MV4 Float
  direction : MV4 Float
  deriving Repr

/-- Ray-particle intersection result -/
structure Intersection where
  distance : Float
  position : MV4 Float
  normal : MV4 Float
  deriving Repr

/-- Material properties for rendering -/
structure Material where
  color : RGB
  ambient : Float
  diffuse : Float
  specular : Float
  shininess : Float
  reflectivity : Float
  deriving Repr

/-- Scene object with geometry and material -/
structure SceneObject where
  -- Each object implements its own intersection test
  intersect : Ray → Option Intersection
  material : Material
  deriving Repr

/-- Raytracer scene with objects and lights -/
structure Scene where
  objects : Array SceneObject
  lights : Array (MV4 Float) -- Light positions
  background : RGB
  ambient : Float
  deriving Repr

/-- Camera for viewing the scene -/
structure Camera where
  position : MV4 Float
  lookAt : MV4 Float
  up : MV4 Float
  fov : Float
  aspect : Float
  deriving Repr

/-- Create a ray given camera and pixel coordinates -/
def createRay (camera : Camera) (x y : Float) : Ray :=
  let forward := (camera.lookAt - camera.position).grade1
  let right := (forward ∧ camera.up).dual
  let up := (right ∧ forward).dual

  let fovRadians := camera.fov * (Float.pi / 180)
  let halfHeight := Float.tan (fovRadians / 2)
  let halfWidth := halfHeight * camera.aspect

  let dir := forward
           + right * (x * halfWidth * 2 - halfWidth)
           + up * (y * halfHeight * 2 - halfHeight)

  ⟨camera.position, dir⟩

/-- Check if a ray intersects with any object in the scene -/
def Scene.intersect (scene : Scene) (ray : Ray) : Option (Intersection × SceneObject) :=
  Id.run do
    let mut closestDist := Float.infinity
    let mut result : Option (Intersection × SceneObject) := none

    for obj in scene.objects do
      match obj.intersect ray with
      | some intersection =>
        if intersection.distance < closestDist then
          closestDist := intersection.distance
          result := some (intersection, obj)
      | none => pure ()

    return result

/-- Calculate lighting at an intersection point -/
def calculateLighting (scene : Scene) (intersection : Intersection) (obj : SceneObject) (ray : Ray) : RGB :=
  Id.run do
    let material := obj.material
    let point := intersection.position
    let normal := intersection.normal
    let viewDir := -ray.direction

    -- Start with ambient lighting
    let mut color := material.ambient * scene.ambient * material.color

    -- Add contribution from each light
    for light in scene.lights do
      let lightDir := (light - point).grade1
      let lightDist := MV4.normSquared lightDir
      let lightDirNorm := lightDir / Float.sqrt lightDist

      -- Check for shadows
      let shadowRay : Ray := ⟨point, lightDirNorm⟩
      let inShadow := match scene.intersect shadowRay with
        | some (hit, _) => hit.distance * hit.distance < lightDist
        | none => false

      if !inShadow then
        -- Calculate diffuse lighting
        let diff := Float.max 0 (normal ⋅ lightDirNorm)
        color := color + material.diffuse * diff * material.color

        -- Calculate specular lighting
        let reflectDir := (2 * (normal ⋅ lightDirNorm)) * normal - lightDirNorm
        let spec := Float.max 0 (viewDir ⋅ reflectDir)
        let spec := spec ^ material.shininess
        color := color + material.specular * spec * white

    return color

/-- Trace a ray through the scene recursively -/
def traceRay (scene : Scene) (ray : Ray) (depth : Nat) : RGB :=
  if depth = 0 then
    return scene.background

  match scene.intersect ray with
  | some (intersection, obj) =>
    let directColor := calculateLighting scene intersection obj ray

    -- Handle reflections
    if obj.material.reflectivity > 0 then
      let normal := intersection.normal
      let reflectDir := ray.direction - (2 * (normal ⋅ ray.direction)) * normal
      let reflectRay : Ray := ⟨intersection.position, reflectDir⟩
      let reflectColor := traceRay scene reflectRay (depth - 1)
      directColor + obj.material.reflectivity * reflectColor
    else
      directColor
  | none =>
    scene.background

/-- Render a scene to an image -/
def render (scene : Scene) (camera : Camera) (width height : Nat) (maxDepth : Nat := 3) : Image :=
  Id.run do
    let img := Image.black width height
    let mut result := img

    for y in [:height] do
      for x in [:width] do
        let u := x.toFloat / (width.toFloat - 1)
        let v := y.toFloat / (height.toFloat - 1)
        let ray := createRay camera u v
        let color := traceRay scene ray maxDepth
        result := result.setPixel x y color

    return result

end Raytracer
