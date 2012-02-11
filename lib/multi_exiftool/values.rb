# coding: utf-8
require 'date'
module MultiExiftool

  # Representing (tag, value) pairs of metadata.
  # Access via bracket-methods or dynamic method-interpreting via
  # method_missing.
  class Values
    class << self
      def parsed values
        new values, true
      end

      def unparsed values
        new values, false
      end
    end

    def initialize values, parse = true
      @values = {}
      values.map do |tag,val|
        val = val.kind_of?(Hash) ? Values.new(val) : val
        @values[unify_tag(tag)] = parse ? parse_value(val) : val
      end
    end

    def [](tag)
      @values[unify_tag(tag.to_s)]
    end

    def to_hash
      @values.dup
    end

    def self.unify_tag tag
      tag.gsub(/[-_]/, '').downcase
    end

    private

    def unify_tag tag
      self.class.unify_tag tag
    end

    def method_missing tag, *args, &block
      res = self[unify_tag(tag.to_s)]
      if res && block_given?
        if block.arity > 0
          yield res
        else
          res.instance_eval &block
        end
      end
      res
    end

    def parse_value val
      return val unless val.kind_of?(String)
      case val
      when /^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d)(?::(\d\d))?([-+]\d\d:\d\d)?$/
        arr = $~.captures[0,6].map {|cap| cap.to_i}
        arr << $7 if $7
        Time.new(*arr)
      when %r(^(\d+)/(\d+)$)
        Rational($1, $2)
      else
        val
      end
    end

  end

end
