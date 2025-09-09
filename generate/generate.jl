using XML
using ColorTypes
using Colors

#https://github.com/JuliaComputing/XML.jl/issues/50
function Base.get(node::XML.Node, key, default)
    if haskey(node, key)
        node[key]
    else
        default
    end
end

function split_svg(doc)
    root = doc[end]
    colored_paths = Vector{Pair{String, Vector{Node}}}()
    previous_color = ""
    for child in children(root)
        fill = get(child, "fill", "#000000")
        color = lstrip(fill, '#')
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

function lume(hex_color)
    rgb = if haskey(Colors.color_names, hex_color)
        RGB(Colors.color_names["green"]./255 ...)
    else
        parse(RGB, "#"*hex_color)
    end
    grey = convert(Gray, rgb)
    return float(grey)
end

####################


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

function declare_openscad_for(output_dir, name, (viewbox_x, viewbox_y), parts)
    cur_scad = ""
    for (ii, hex_color) in parts
        part_svg_filename = relpath(
            svg_filename(output_dir, name, ii, hex_color),
            output_dir
        )

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
        {
            /* $name */
            center_def = is_undef(center) ? false : center;
            translate (center_def ? [$(-viewbox_x/2), $(-viewbox_y/2), 0] : [0, 0, 0]) {$cur_scad};
        }
    """)
end


function generate(input_dir="generate/original_svgs/")
    output_dir = mkpath(joinpath(dirname(@__DIR__), "src"))
    open(joinpath(output_dir, "twiemoji.scad"), "w") do output_scad_fh
        println(output_scad_fh, "module twiemoji (emoji, v_total, center) {\n")
        for input_filename in readdir(input_dir, join=true)
            emoji = filename2emoji(input_filename)
            @info "Processing" input_filename emoji
            println(output_scad_fh, """if (emoji == "$emoji") """)
            og_doc = read(input_filename, Node)
            viewbox = extract_viewbox(og_doc)
            parts = create_sub_svgs(output_dir, emoji, og_doc)
            println(
                output_scad_fh,
                declare_openscad_for(output_dir, emoji, viewbox, parts)
            )
            println(output_scad_fh, "else ")
        end
        println(output_scad_fh, """\tassert(false, "emjoi not recognized");""")
        println(output_scad_fh, "}")
    end
end


generate()
