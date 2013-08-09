require "gcalgen/version"
require 'gcalgen/config'
require 'gcalgen/event'
require 'gcalgen/every'

module Gcalgen
  def def_calendar(name, &block)
    c = GcalConfig.new(name)
    c.instance_eval &block
    $myConfig[name] = c
  end

  def event(title, &block)
    c = Event.new(title)
    c.instance_eval &block
    c.generate_gcalevent.each { |event|
      event.save!
    }
  end
end
