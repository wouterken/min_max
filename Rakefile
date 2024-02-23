# frozen_string_literal: true

require "bundler/gem_tasks"
require "rb_sys/extensiontask"

task build: :compile

RbSys::ExtensionTask.new("min_max") do |ext|
  ext.lib_dir = "lib/min_max"
end

task default: :compile
