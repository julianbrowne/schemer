
dir = File.dirname(__FILE__)

$: << File.expand_path("#{dir}/../lib")
$: << File.expand_path("#{dir}/../test")
$: << File.expand_path("#{dir}/..")

require 'test/unit'
require 'tuff'

Dir.glob("#{dir}/**/*.spec.rb") do |test_case|
    puts "adding #{test_case}"
    require "#{test_case}"
end
