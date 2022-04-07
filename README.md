# Color Logging Formatter

This shard adds a new module `ColorLogging` as well as a new short formatter `ShortColorFormat` to help add a bit of color to your otherwise excellent log lines.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cr-color-logging:
       github: vici37/cr-color-logging
   ```

2. Run `shards install`

## Usage

```crystal
require "cr-color-logging"

# This will output all debug and above severity log lines to STDOUT, colored via the ShortColorFormat formatter.
# By default, no colors are set and must be defined.
Log.setup(:debug, Log::IOBackend.new(formatter: Log::ShortColorFormat))

# Define the color you want for which part of the log message. Colors
# are the same as the ones defined in the `colorize` module.
Log::ShortColorFormat.with_color("severity", :red)
Log::ShortColorFormat.with_color("timestamp", :blue)

# Outputting a log now is as simple as:
Log.for(MyClass).info { "my information message" }
```

The full list of parts that the `ShortColorFormat` supports are:
```
timestamp
message
severity
source
after_source
before_data
data
before_context
context
exception
progname
pid
string
```

The `ShortColorFormat` was defined using the same string as the standard `ShortFormat` [here](https://github.com/crystal-lang/crystal/blob/ef05e26d6/src/log/format.cr#L201). A similar macro is also defined for the `ColorLogging` module to define custom formats as well:

```crystal
ColorFormat.define_formatter MyFormat "#{timestamp(after: ":")} #{severity(before: "[", after: "]")} #{message}"

# All parts, with exception to `string`, support a before_ and after_ prefixed part to color those
# specific pieces. If omitted, they inherit from the base part.
MyFormat.with_color("before_severity", :yellow)
MyFormat.with_color("after_severity", :yellow)
MyFormat.with_color("severity", :red)

# It might also be good to skip specific part coloring if a log line is of a sufficient severity.
# This will color the entire line this color if the severity matches.
MyFormat.with_colored_sevirity(Log::Severity::Error, :red)
```

## Contributing

1. Fork it (<https://github.com/your-github-user/color-logging/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Troy Sornson](https://github.com/vici37) - creator and maintainer
