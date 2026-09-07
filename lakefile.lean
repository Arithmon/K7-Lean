import Lake
open Lake DSL

package «GIFT»

require checkdecls from git
  "https://github.com/PatrickMassot/checkdecls.git" @ "3d425859e73fcfbef85b9638c2a91708ef4a22d4"

require «doc-gen4» from git
  "https://github.com/leanprover/doc-gen4" @ "v4.33.1"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.33.1"

@[default_target]
lean_lib «GIFT» where
  globs := #[.submodules `GIFT]
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`linter.unnecessarySimpa, false⟩
  ]

lean_lib «GIFTTest» where
  globs := #[.submodules `GIFTTest]

lean_lib «Verification» where
  globs := #[.submodules `Verification]
