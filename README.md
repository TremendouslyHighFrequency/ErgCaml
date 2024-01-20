This is a work in progress translation between C bindings for sigma-rust and native ergoscript functions to OCaml / ReasonML (TypeScipt/React)
We do not recommend utilizing this repository in its current state.

Contracts:
~~-Psuedocode convesions to eML and ML for existing ergoscript contracts~~
- Create native functions and variables where direct translation between ErgoScript and OCaml is allowed
- Import C types from ergo-lib-c when needed initially to achieve functionality

Library:
- Build ergo-lib-c into project directory
- Create native translations of C types into OCaml/ReasonML
- Translate from ErgCaML to React components
