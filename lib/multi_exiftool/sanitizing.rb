# coding: utf-8
require 'shellwords'

module MultiExiftool
  
  module Sanitizing

    def escape str
      Shellwords.escape(str)
    end

    def escaped_filenames
      raise OperationsError.new('No filenames.') if filenames.empty?
      filenames.map { |fn| Shellwords.escape(fn) }
    end

  end
end
