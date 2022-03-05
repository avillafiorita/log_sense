require 'terminal-table'
require 'json'
require 'erb'
require 'ostruct'

module LogSense
  module Emitter

    #
    # Emit Data
    #
    def self.emit data = {}, options = {}
      @input_format = options[:input_format] || "apache"
      @output_format = options[:output_format] || "html"

      # for the ERB binding
      @data = data
      @options = options

      # determine the main template to read
      @template = File.join(File.dirname(__FILE__), "templates", "#{@input_format}.#{@output_format}.erb")
      erb_template = File.read @template
      
      output = ERB.new(erb_template).result(binding)

      if options[:output_file]
        file = File.open options[:output_file], "w"
        file.write output
        file.close
      else
        puts output
      end
    end

    private

    def self.render(template, vars)
      @template = File.join(File.dirname(__FILE__), "templates", "_#{template}")
      erb_template = File.read @template
      ERB.new(erb_template).result(OpenStruct.new(vars).instance_eval { binding })
    end

    def self.escape_javascript(string)
      js_escape_map = { "<script" => "&lt;script", "</script" => "&lt;script", "</" => '<\/', "\\" => "\\\\", "\r\n" => '\\r\\n', "\n" => '\\n', "\r" => '\\r', '"' => '\\"', "'" => "\\'", "`" => "\\`", "$" => "\\$" }
      js_escape_map.each do |k, v|
        string = string.gsub(k, v)
      end
      string
    end
  end
end
