import Lake
open Lake DSL

package tetraGray where
  -- add package configuration options here

@[default_target]
lean_lib TetraGray where
  -- add library configuration options here

@[default_target]
lean_exe PPMTest where
  root := `TetraGray.PPMTest

@[default_target]
lean_exe SimpleRaytracer where
  root := `TetraGray.SimpleRaytracer

@[default_target]
lean_exe SimpleRT where
  root := `TetraGray.SimpleRT

@[default_target]
lean_exe Doran where
  root := `TetraGray.Doran
