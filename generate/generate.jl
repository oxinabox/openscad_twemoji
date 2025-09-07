using XML
using ColorTypes
using Colors
function split_svg(doc)
    root = doc[end]
    colored_paths = Vector{Pair{String, Vector{Node}}}()
    previous_color = ""
    for child in children(root)
        color = lstrip(child["fill"], '#')
        if color != previous_color
            push!(colored_paths, color => Vector{Node}())
        end

        push!(colored_paths[end][2], child)
        previous_color = color
    end
    return colored_paths
end

function write_split_svg(svg_filename, doc, paths)
    root = doc[end]
        
    XML.write(
        svg_filename,
        XML.Document(XML.Element(tag(root),
            paths...; (Symbol(k)=>v for (k, v) in attributes(root))...
        ))
    )
end

function svg_filename(output_dir, name, ii, color)
    dirname = mkpath(joinpath(output_dir, "svgs", name))
    return joinpath(dirname, "$ii-$color.svg")
end

function create_sub_svgs(output_dir, name, og_doc)
    colored_paths = split_svg(og_doc)
    return map(enumerate(colored_paths)) do (ii, (hex_color, paths))
        write_split_svg(svg_filename(output_dir, name, ii, hex_color), og_doc, paths)
        return ii, hex_color
    end
end
#########

function grey_hex(hex_color)
    rgb = parse(RGB, "#"*hex_color)
    grey = convert(Gray, rgb)
    return "#"*hex(grey)
end

function lume(hex_color)
    rgb = parse(RGB, "#"*hex_color)
    grey = convert(Gray, rgb)
    return float(grey)
end


function filename2emoji(input_filename)
    utf16_codes_str = first(splitext(basename(input_filename)))
    utf16_codes = split(utf16_codes_str, "-")
    uft16 = parse.(UInt32, utf16_codes, base=16)
    return transcode(String, uft16)
end

################

function extract_viewbox(og_doc)
    xmin, ymin, xmax, ymax = parse.(Int, split(og_doc[1]["viewBox"]))
    @assert xmin == 0
    @assert ymin == 0 
    return (xmax, ymax)
end

function declare_openscad_module(output_dir, name, (viewbox_x, viewbox_y), parts)
    cur_scad = ""
    for (ii, hex_color) in parts
        part_svg_filename = svg_filename(output_dir, name, ii, hex_color)
        col = lume(hex_color)
        import_line = """color("#$hex_color") import("$part_svg_filename", center=false);"""
        main_line = "linear_extrude(height=$col*v_total) {$import_line};"
        if !isempty(cur_scad)
            cur_scad = """
                union(){difference(){
                    $cur_scad
                    $main_line
                };
                $main_line
            };
            """ |> strip
        else
            cur_scad = main_line
        end
    end

    return strip("""
        module $name (v_total, center) {
            center_def = is_undef(center) ? false : center;
            🏳️‍⚧️ = center_def ? [$(-viewbox_x/2), $(-viewbox_y/2), 0] : [0, 0, 0]
            translate (🏳️‍⚧️) {$cur_scad};
        }
    """) * "\n\n"
end


function generate(input_dir="generate/test_svgs/")
    output_dir = mkpath(joinpath(dirname(@__DIR__), "src"))
    open(joinpath(output_dir, "twiemoji.scad"), "w") do output_scad_fh
        for input_filename in readdir(input_dir, join=true)
            emoji = filename2emoji(input_filename)
            @info "Processing" input_filename emoji

            og_doc = read(input_filename, Node)
            viewbox = extract_viewbox(og_doc)
            parts = create_sub_svgs(output_dir, emoji, og_doc)
            print(
                output_scad_fh,
                declare_openscad_module(output_dir, emoji, viewbox, parts)
            )
        end
    end
end


generate()
