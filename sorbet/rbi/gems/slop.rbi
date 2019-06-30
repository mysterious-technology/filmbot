# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: true
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/slop/all/slop.rbi
#
# slop-4.6.2
module Slop
  def self.option_defined?(name); end
  def self.parse(items = nil, **config, &block); end
  def self.string_to_option(s); end
  def self.string_to_option_class(s); end
end
class Slop::Option
  def block; end
  def call(_value); end
  def config; end
  def count; end
  def default_value; end
  def desc; end
  def ensure_call(value); end
  def expects_argument?; end
  def finish(_result); end
  def flag; end
  def flags; end
  def help?; end
  def initialize(flags, desc, **config, &block); end
  def key; end
  def null?; end
  def required?; end
  def reset; end
  def suppress_errors?; end
  def tail; end
  def tail?; end
  def to_s(offset: nil); end
  def underscore_flags?; end
  def value; end
  def value=(arg0); end
end
class Slop::Options
  def add_option(option); end
  def banner; end
  def banner=(arg0); end
  def config; end
  def each(&block); end
  def initialize(**config); end
  def longest_flag_length; end
  def longest_option; end
  def method_missing(name, *args, **config, &block); end
  def on(*flags, **config, &block); end
  def options; end
  def parse(strings); end
  def parser; end
  def respond_to_missing?(name, include_private = nil); end
  def separator(string); end
  def separators; end
  def to_a; end
  def to_s(prefix: nil); end
  include Enumerable
end
class Slop::Parser
  def arguments; end
  def config; end
  def initialize(options, **config); end
  def matching_option(flag); end
  def options; end
  def parse(strings); end
  def partition(strings); end
  def process(option, arg); end
  def reset; end
  def suppress_errors?; end
  def try_process(flag, arg); end
  def try_process_grouped_flags(flag, arg); end
  def try_process_smashed_arg(flag); end
  def unused_options; end
  def used_options; end
end
class Slop::Result
  def [](flag); end
  def []=(flag, value); end
  def args; end
  def arguments; end
  def get(flag); end
  def initialize(parser); end
  def method_missing(name, *args, &block); end
  def option(flag); end
  def options; end
  def parser; end
  def respond_to_missing?(name, include_private = nil); end
  def set(flag, value); end
  def to_h; end
  def to_hash; end
  def to_s(**opts); end
  def unused_options; end
  def used_options; end
end
class Slop::StringOption < Slop::Option
  def call(value); end
end
class Slop::BoolOption < Slop::Option
  def call(value); end
  def default_value; end
  def expects_argument?; end
  def explicit_value; end
  def explicit_value=(arg0); end
  def force_false?; end
  def value; end
end
class Slop::IntegerOption < Slop::Option
  def call(value); end
end
class Slop::FloatOption < Slop::Option
  def call(value); end
end
class Slop::ArrayOption < Slop::Option
  def call(value); end
  def default_value; end
  def delimiter; end
  def limit; end
end
class Slop::RegexpOption < Slop::Option
  def call(value); end
end
class Slop::NullOption < Slop::BoolOption
  def null?; end
end
class Slop::Error < StandardError
end
class Slop::NotImplementedError < Slop::Error
end
class Slop::MissingArgument < Slop::Error
  def flags; end
  def initialize(msg, flags); end
end
class Slop::UnknownOption < Slop::Error
  def flag; end
  def initialize(msg, flag); end
end
class Slop::MissingRequiredOption < Slop::Error
end
