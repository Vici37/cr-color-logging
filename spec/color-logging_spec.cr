require "./spec_helper"

describe ColorLogging::ColorFormatter do
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

    io.to_s.should eq "1970-01-01T00:00:00.000000Z \e[31m\e[0m\e[31mERROR \e[0m\e[31m\e[0m - mysource: mymessage -- data: \"yes\""
  end
end
