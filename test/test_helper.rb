require 'test/unit'
require 'benchmark'
require 'rubygems'
require 'active_support'

# load the b4r module, but once
lib_path = File.dirname(__FILE__) + '/../lib/'
Dependencies.load_paths << lib_path
Dependencies.load_once_paths << lib_path

# for the fake application directory - needed to test reloading
Dependencies.load_paths << File.dirname(__FILE__) + '/app/'