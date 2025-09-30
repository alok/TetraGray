import TetraGray.Clifford

open MultiVector

namespace CoordSystems

/-- Spherical coordinates (t, r, θ, φ) from Cartesian (t, x, y, z) -/
def sphericalFromCartesian (pos : MV4 Float) : MV4 Float :=
  let t := pos.scalar
  let x := pos.x
  let y := pos.y
  let z := pos.z

  let r := Float.sqrt (x * x + y * y + z * z)
  let theta := if r > 0 then Float.acos (z / r) else 0
  let phi := Float.atan2 y x

  -- Return as a 4-vector (t, r, θ, φ)
  #v[t, r, theta, phi, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Oblate spheroidal coordinates (t, μ, ν, φ) from Cartesian (t, x, y, z)

    Following Doran's convention:
    - μ: radial-like coordinate (μ ≥ 0)
    - ν: polar angle (0 ≤ ν ≤ π)
    - φ: azimuthal angle (0 ≤ φ < 2π)
    - a: scale factor (semi-major axis parameter)
-/
def spheroidalFromCartesian (a : Float) (pos : MV4 Float) : MV4 Float :=
  let t := pos.scalar
  let x := pos.x
  let y := pos.y
  let z := pos.z

  let phi := Float.atan2 y x
  let rho := Float.sqrt (x * x + y * y)

  -- Compute distances to foci
  let d1 := Float.sqrt ((rho + a) * (rho + a) + z * z)
  let d2 := Float.sqrt ((rho - a) * (rho - a) + z * z)

  -- Compute cosh(μ) and μ
  let cosh_mu := (d1 + d2) / (2 * a)
  let mu := Float.acosh (if cosh_mu > 1.0 then cosh_mu else 1.0)

  -- Compute cos(ν) with proper sign
  let cos2_nu := 1.0 - (d1 - d2) * (d1 - d2) / (4.0 * a * a)
  let cos_nu_unsigned := Float.sqrt (if cos2_nu > 0.0 then cos2_nu else 0.0)
  let cos_nu_sign := if z >= 0 then cos_nu_unsigned else -cos_nu_unsigned
  let nu := Float.acos cos_nu_sign

  -- Return as a 4-vector (t, μ, ν, φ)
  #v[t, mu, nu, phi, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Spheroidal basis vector ê_μ in Cartesian components -/
def spheroidalBasisVectorEmu (sinh_mu cosh_mu sin_nu cos_nu sin_phi cos_phi : Float) : MV4 Float :=
  let norm := 1.0 / Float.sqrt (sinh_mu * sinh_mu + cos_nu * cos_nu)
  let ex := sinh_mu * sin_nu * cos_phi * norm
  let ey := sinh_mu * sin_nu * sin_phi * norm
  let ez := cosh_mu * cos_nu * norm
  #v[0, ex, ey, ez, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Spheroidal basis vector ê_ν in Cartesian components -/
def spheroidalBasisVectorEnu (sinh_mu cosh_mu sin_nu cos_nu sin_phi cos_phi : Float) : MV4 Float :=
  let norm := 1.0 / Float.sqrt (sinh_mu * sinh_mu + cos_nu * cos_nu)
  let ex := cosh_mu * cos_nu * cos_phi * norm
  let ey := cosh_mu * cos_nu * sin_phi * norm
  let ez := -sinh_mu * sin_nu * norm
  #v[0, ex, ey, ez, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Spheroidal basis vector ê_φ in Cartesian components -/
def spheroidalBasisVectorPhi (sin_phi cos_phi : Float) : MV4 Float :=
  let ex := -sin_phi
  let ey := cos_phi
  #v[0, ex, ey, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Spheroidal basis vector ê_t (time direction) -/
def spheroidalBasisVectorT : MV4 Float :=
  #v[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Doran β parameter for spinning black holes -/
def doranBeta (cosh_mu sin_nu : Float) : Float :=
  Float.atanh (sin_nu / cosh_mu)

/-- Doran vector v for spinning black holes -/
def doranVectorV (beta : Float) (that phihat : MV4 Float) : MV4 Float :=
  that * Float.cosh beta + phihat * Float.sinh beta

/-- Doran position gauge transformation -/
def doranPositionGauge (sinh_mu : Float) (emuhat : MV4 Float) (a : Float) (doran_v vec : MV4 Float) : MV4 Float :=
  let rootfactor := Float.sqrt (2.0 * sinh_mu / a / (1.0 + sinh_mu * sinh_mu))
  let dot_product := vec ⋅ doran_v
  vec + emuhat * (rootfactor * dot_product)

/-- Doran rotation gauge transformation (returns bivector representing rotation) -/
def doranRotationGauge (sinh_mu cos_nu : Float) (muhat nuhat phihat that : MV4 Float)
    (beta : Float) (doran_v : MV4 Float) (a : Float) (vec : MV4 Float) : MV4 Float :=
  let alpha := -Float.sqrt (2.0 * sinh_mu / (a * (sinh_mu * sinh_mu + cos_nu * cos_nu)))

  let arg_dot_mu := vec ⋅ muhat
  let arg_dot_nu := vec ⋅ nuhat
  let arg_dot_phi := vec ⋅ phihat

  let muterm := (muhat ∧ doran_v) * (1.0 / alpha)
  let nuterm := -(nuhat ∧ doran_v) * alpha
  let phiterm := -(phihat ∧ that) * (alpha / Float.cosh beta)

  let common_scalar := a * sinh_mu
  let common_pseudo := a * cos_nu
  let common_denom := common_scalar * common_scalar + common_pseudo * common_pseudo

  let mu_scalar := (common_scalar * common_scalar - common_pseudo * common_pseudo) / (common_denom * common_denom)
  let mu_pseudo := 2.0 * common_scalar * common_pseudo / (common_denom * common_denom)

  -- Note: This is returning a bivector component - needs proper dual operation
  (muterm * mu_scalar + muterm.dual * mu_pseudo) * arg_dot_mu / (common_denom * common_denom) +
  ((nuterm * common_scalar + nuterm.dual * common_pseudo) * arg_dot_nu +
   (phiterm * common_scalar + phiterm.dual * common_pseudo) * arg_dot_phi) / common_denom

end CoordSystems