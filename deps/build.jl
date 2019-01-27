using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcsfml-graphics", "csfml-graphics-2"], :libcsfml_graphics),
    LibraryProduct(prefix, ["libsfml-window", "sfml-window-2"], :libsfml_window),
    LibraryProduct(prefix, ["libsfml-audio", "sfml-audio-2"], :libsfml_audio),
    LibraryProduct(prefix, ["libsfml-network", "sfml-network-2"], :libsfml_network),
    LibraryProduct(prefix, ["libsfml-system", "sfml-system-2"], :libsfml_system),
    LibraryProduct(prefix, ["libsfml-graphics", "sfml-graphics-2"], :libsfml_graphics),
    LibraryProduct(prefix, ["libcsfml-system", "csfml-system-2"], :libcsfml_system),
    LibraryProduct(prefix, ["libcsfml-network", "csfml-network-2"], :libcsfml_network),
    LibraryProduct(prefix, ["libcsfml-window", "csfml-window-2"], :libcsfml_window),
    LibraryProduct(prefix, ["libcsfml-audio", "csfml-audio-2"], :libcsfml_audio),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/Gnimuc/SFMLBuilder/releases/download/2.5-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Windows(:i686) => ("$bin_prefix/SFML.v2.5.1.i686-w64-mingw32.tar.gz", "cd343574d291b2febb8cf86e815c4771ddf2cd6799d3ed8fda6304247bc86494"),
    MacOS(:x86_64) => ("$bin_prefix/SFML.v2.5.1.x86_64-apple-darwin14.tar.gz", "2a99b4548ed7c25867601c6a68e1e61e98983da1cbcb48823b8c5e22ad782be3"),
    Windows(:x86_64) => ("$bin_prefix/SFML.v2.5.1.x86_64-w64-mingw32.tar.gz", "b782fe5882a534734716b4d54c5418f3afdc702e5b1fca9f9aa0e2152380134e"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
