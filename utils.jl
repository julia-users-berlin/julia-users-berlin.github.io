using YAML
using DataFrames
using PrettyTables
using Dates
using Markdown

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
    return pretty_table(
        String,
        df;
        nosubheader = true,
        tf = tf_html_default,
        alignment = :c,
        formatters = (x, i, j) -> Franklin.md2html(x, stripp = true),
        allow_html_in_cells = true,
    )
end

default_location() = "<a href=https://c-base.org>c-base</a>"

function hfun_front_message()
    today = now()

    events = YAML.load_file("events.yaml")
    latest_event = first(events)
    date_event = DateTime(latest_event["date"], DateFormat("d.m.y"))
    # Check that the date is a 2nd Tuesday
    dayofweek(date_event) == 2 || @warn "The added day is not a Tuesday"
    dayofweekofmonth(date_event) == 2 || @warn "The added day is not the second Tuesday"
    text = if today > date_event # It's passed already! We put a default message
        next_date = tonext(today) do x
            dayofweek(x) == Dates.Tuesday &&
            dayofweekofmonth(x) == 2
        end
        """
            <b>$(day(next_date))th of $(monthname(next_date)) at 19:00 at $(default_location())</b>. Topic to be announced, if you have a topic <a href=https://github.com/julia-users-berlin/julia-users-berlin.github.io/issues/new>contact us</a>.
        """
    else # It's coming! 
        """
            <b>$(day(date_event))th of $(monthname(date_event)) at 19:00 at $(latest_event["location"])</b>.
            $(latest_event["topic"])
        """
    end
    return text
end
