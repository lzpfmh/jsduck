require 'v8'
require 'json'
require 'singleton'

module JsDuck

  # Uses Esprima.js engine through V8 to tokenize JavaScript string.
  class EsprimaTokenizer
    include Singleton

    def initialize
      @v8 = V8::Context.new
      esprima = File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))+"/esprima/esprima.js";
      @v8.load(esprima)
      wrapper = File.dirname((File.expand_path(__FILE__)))+"/esprima_wrapper.js";
      @v8.load(wrapper)
    end

    # Input must be a String.
    def tokenize(input)
      @v8['js'] = @input = input

      out = JSON.parse(@v8.eval("EsprimaWrapper.parse(js)"))

      len = out["type"].length
      out_type = out["type"]
      out_value = out["value"]
      out_linenr = out["linenr"]

      type_array = [
        :number,
        :string,
        :ident,
        :regex,
        :operator,
        :keyword,
        :doc_comment,
      ]

      value_array = out["valueArray"]

      tokens = []
      for i in (0..(len-1))
        t = type_array[out_type[i]]
        if t == :doc_comment
          tokens << { :type => t, :value => out_value[i], :linenr => out_linenr[i] }
        elsif t == :keyword
          kw = value_array[out_value[i]].to_sym
          tokens << { :type => kw, :value => kw }
        else
          tokens << { :type => t, :value => value_array[out_value[i]] }
        end
      end

      tokens
    end

  end
end
