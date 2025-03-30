import Lake
open Lake DSL

package tetraGray where
  -- add package configuration options here

lean_lib TetraGray where
  -- add library configuration options here

lean_exe SimpleTest where
  root := `TetraGray.SimpleTest

lean_exe PPMTest where
  root := `TetraGray.PPMTest

lean_exe SimpleRaytracer where
  root := `TetraGray.SimpleRaytracer

lean_exe SimpleRT where
  root := `TetraGray.SimpleRT

lean_exe Doran where
  root := `TetraGray.Doran
