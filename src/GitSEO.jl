# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 hyperpolymath

module GitSEO

using Comonicon
using HTTP
using JSON3
using URIs

include("types.jl")
include("parsers.jl")
include("analyzers.jl")
include("scoring.jl")
include("cli.jl")

end # module
