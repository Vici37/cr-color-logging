require "./spec_helper"

struct Log::ShortColorFormat
  class_getter color_map, severity_color_map
end

Spec.before_each do
  Log::ShortColorFormat.color_map.clear
  Log::ShortColorFormat.severity_color_map.clear
end

describe Log::ShortColorFormat do
  zero_timestamp = Time.unix(0)

  it "formats log entry" do
    io = String::Builder.new
    entry = Log::Entry.new("mysource", Log::Severity::Trace, "mymessage", Log::Metadata.new(entries: {data: "yes"}), nil, timestamp: zero_timestamp)

    formatter = Log::ShortColorFormat.new(entry, io)

    formatter.run

    io.to_s.should eq "1970-01-01T00:00:00.000000Z TRACE  - mysource: mymessage -- data: \"yes\""
  end

  it "formats and colorizes log entry" do
    io = String::Builder.new
    entry = Log::Entry.new("mysource", Log::Severity::Error, "mymessage", Log::Metadata.new(entries: {data: "yes"}), nil, timestamp: zero_timestamp)

    Log::ShortColorFormat.with_color("severity", :red)

    formatter = Log::ShortColorFormat.new(entry, io)

    formatter.run

    io.to_s.should eq "1970-01-01T00:00:00.000000Z \e[31mERROR \e[0m - mysource: mymessage -- data: \"yes\""
  end

  it "colorizes all available fields, with before and afters" do
    io = String::Builder.new
    entry = Log::Entry.new(
      "mysource",
      Log::Severity::Info,
      "mymessage",
      Log::Metadata.new(entries: {data: "yes"}),
      Exception.new,
      timestamp: zero_timestamp)

    Log::ShortColorFormat.with_color("timestamp", :green)
    Log::ShortColorFormat.with_color("severity", :red)
    Log::ShortColorFormat.with_color("before_source", :light_blue)
    Log::ShortColorFormat.with_color("source", :blue)
    Log::ShortColorFormat.with_color("message", :white)
    Log::ShortColorFormat.with_color("before_data", :light_cyan)
    Log::ShortColorFormat.with_color("data", :cyan)
    Log::ShortColorFormat.with_color("before_context", :black)
    Log::ShortColorFormat.with_color("context", :default)
    Log::ShortColorFormat.with_color("exception", :yellow)
    Log::ShortColorFormat.with_color("string", :light_red)

    formatter = Log::ShortColorFormat.new(entry, io)

    formatter.run

    io.to_s.should eq "\e[32m1970-01-01T00:00:00.000000Z\e[0m\e[91m \e[0m\e[31mINFO  \e[0m\e[91m - \e[0m\e[34mmysource\e[0m\e[34m: \e[0m\e[97mmymessage\e[0m\e[96m -- \e[0m\e[36mdata: \"yes\"\e[0m\e[33m (Exception)\n\e[0m"
  end

  it "colors by severity" do
    io = String::Builder.new
    entry = Log::Entry.new(
      "mysource",
      Log::Severity::Info,
      "mymessage",
      Log::Metadata.new(entries: {data: "yes"}),
      Exception.new,
      timestamp: zero_timestamp)

    Log::ShortColorFormat.with_colored_severity(Log::Severity::Info, :white)

    # This coloring won't matter and will be overridden by the above coloring
    Log::ShortColorFormat.with_color("timestamp", :green)

    formatter = Log::ShortColorFormat.new(entry, io)

    formatter.run

    io.to_s.should eq "\e[97m1970-01-01T00:00:00.000000Z\e[0m\e[97m \e[0m\e[97mINFO  \e[0m\e[97m - \e[0m\e[97mmysource\e[0m\e[97m: \e[0m\e[97mmymessage\e[0m\e[97m -- \e[0m\e[97mdata: \"yes\"\e[0m\e[97m (Exception)\n\e[0m"
  end
end
