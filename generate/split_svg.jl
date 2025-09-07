using XML
using ColorTypes
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

function color2texture(hex_color)
    rgb = parse(RGB, "#"*hex_color)
    grey = convert(Gray, rgb)
    prob = grey.val
    hf_raw = collect(sprand(100, 100, float(prob)))
    hf = round.(hf_raw, digits=1)
    "[$(join(collect.(eachcol(hf)), ", "))]"
end

################

input_filename = joinpath(@__DIR__, "input", "dancer.svg")

image_name = splitext(basename(input_filename))[1]
og_doc = read(input_filename, Node)
colored_paths = split_svg(og_doc)

output_dir = mkpath(joinpath(@__DIR__, "output", image_name))


cur_scad = ""
for (ii, (hex_color, paths)) in enumerate(colored_paths)
    svg_filename = joinpath(output_dir, "$ii-$color.svg")
    write_split_svg(svg_filename, og_doc, paths)

    col = lume(hex_color)
    import_line = """color("#$hex_color") import("$svg_filename", center=false);"""
    extrude_line = "linear_extrude(height=10) {scale(2) $import_line};"
    main_line = """
        intersection(){
            up(0.5)
            cuboid([125, 125, ($col)+0.5], anchor=FRONT+LEFT+BOTTOM);
            //textured_tile("hills", [125, 125, 2], tex_reps=10, anchor=FRONT+LEFT+BOTTOM);
            $extrude_line
        }
    """
    if !isempty(cur_scad)
        cur_scad = """
            union(){difference(){
                $cur_scad
                $extrude_line
            };
            $main_line
        };
        """ |> strip
    else
        cur_scad = main_line
    end
end
open(joinpath(output_dir, "image.scad"), "w") do scad_fh
    print(scad_fh, "include <BOSL2/std.scad>")
    print(
        scad_fh,
        """
        difference(){
            cube([20, 20, 2]);
            up(0.1)
            render(){$cur_scad};
        }
        """
        
    )
end

