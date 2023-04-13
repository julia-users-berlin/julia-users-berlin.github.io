using YAML
using DataFrames
using PrettyTables

function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits = 2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function hfun_event_table()
    events = YAML.load_file("events.yaml")
    df = mapreduce(DataFrame, vcat, events)
    df = rename(
        df,
        :event => :Event,
        :date => :Date,
        :location => :Location,
        :topic => :Topic,
    )
    df = df[:, [:Date, :Event, :Topic, :Location]]
    pretty_table(
        String,
        df;
        nosubheader = true,
        tf = tf_html_default,
        alignment = :c,
        formatters = (x, i, j) -> Franklin.md2html(x, stripp = true),
        allow_html_in_cells = true,
    )
end
