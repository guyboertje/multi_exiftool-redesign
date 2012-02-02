# coding: utf-8
require_relative '../lib/multi_exiftool'
require 'minitest/spec'
require 'minitest/autorun'
require 'open3'
require 'stringio'

module TestHelper

  def mocking_open3(command, outstr, errstr)
    open3_eigenclass = class << Open3; self; end
    open3_eigenclass.module_exec(command, outstr, errstr) do |cmd, out, err|
      define_method :popen3 do |arg|
        if arg == cmd
          return [nil, StringIO.new(out), StringIO.new(err)]
        else
          raise ArgumentError.new("Expected call of Open3.popen3 with argument #{cmd.inspect} but was #{arg.inspect}.")
        end
      end
    end
  end

end

class MiniTest::Spec
  include TestHelper
end
