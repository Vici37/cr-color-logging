require "colorize"
require "log"

module ColorLogging
  macro define_formatter(name, pattern)
    struct {{name}} < ColorLogging::ColorFormatter
      def run
        {% for part in pattern.expressions %}
          {% if part.is_a?(StringLiteral) %}
            string {{ part }}
          {% else %}
            {{ part }}
          {% end %}
        {% end %}
      end
    end
  end

  # Most of this class is directly cribbed from Crystal's own StaticFormatter class.
  # Macro providing the colorizing option and the static with_colors method provided by this project.
  # Modify the `run` method below to change how log lines behave in terminal
  abstract struct ColorFormatter
    extend ::Log::Formatter

    @@color_map = {} of String => Symbol
    @@severity_color_map = {} of Log::Severity => Symbol

    macro define_colorized_method(name, method_override = nil, conditional = nil)
    def {{name.id}}(*, before = nil, after = nil)
      {% if conditional %}{{conditional.id}}{% end %}
        @io << before.colorize(color_for("{{name.id}}", "before")) if before
        @io << {{method_override ? method_override.id : "@entry.#{name.id}".id}}.colorize(color_for("{{name.id}}"))
        @io << after.colorize(color_for("{{name.id}}", "after")) if after
      {% if conditional %}end{% end %}
    end
    end

    def self.with_color(prop : String, color : Symbol)
      @@color_map[prop] = color
    end

    def self.with_colored_severity(severity : Log::Severity, color : Symbol)
      @@severity_color_map[severity] = color
    end

    def initialize(@entry : Log::Entry, @io : IO)
    end

    private def color_for(prop : String, modifier : String = "") : Symbol
      if @@severity_color_map.empty?
        @@color_map["#{modifier}_#{prop}"]? || @@color_map.fetch(prop, :default)
      else
        @@severity_color_map.fetch(@entry.severity, :default)
      end
    end

    define_colorized_method(timestamp, @entry.timestamp.to_rfc3339(fraction_digits: 6))
    define_colorized_method(message)
    define_colorized_method(severity, @entry.severity.label.ljust(6))
    define_colorized_method(source, nil, "if @entry.source.size > 0")
    define_colorized_method(data, nil, "unless @entry.data.empty?")
    define_colorized_method(context, nil, "unless @entry.context.empty?")
    define_colorized_method(exception, "ex.inspect_with_backtrace", "if ex = @entry.exception")
    define_colorized_method(progname, Log.progname)
    define_colorized_method(pid, Log.pid)

    def string(value : String)
      @io << value.colorize(color_for("string"))
    end

    def self.format(entry, io) : Nil
      new(entry, io).run
    end

    abstract def run
  end
end

ColorLogging.define_formatter Log::ShortColorFormat, "#{timestamp} #{severity} - #{source(after: ": ")}#{message}" \
                                                     "#{data(before: " -- ")}#{context(before: " -- ")}#{exception}"
