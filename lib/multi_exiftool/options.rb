# coding: utf-8
module MultiExiftool
  
  module Options
    def options
      opts = @options.dup
      opts["g#{@group}"] = true if @group
      opts[:n] = true if @numerical
      opts[:overwrite_original] = true if @overwrite_original
      opts
    end

    def options_args
      opts = options
      return [] if opts.empty?
      opts.map do |opt, val|
        if val == true
          "-#{opt}"
        else
          "-#{opt} #{val}"
        end
      end
    end

    def tags_args
      return [] unless @tags
      @tags.map {|tag| "-#{tag}"}
    end
  end
end
