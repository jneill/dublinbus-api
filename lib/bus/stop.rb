require 'rest_client'
require 'rexml/document'

module Bus
  class StopList
    include Enumerable

    def initialize(stops)
      @stops = Hash[ stops.map{ |s| [s.id, s] }]
    end

    def each
      @stops.each { |id, s| yield s }
    end

    def[](id)
      @stops[id]
    end

    def sort_by_distance_from(origin)
      StopList.new sort_by { |s| s.distance_to origin }
    end

    def within_range(origin, range)
      StopList.new select { |s| s.distance_to(origin) <= range }	
    end

    def on_routes(routes)
      StopList.new select { |s| s.services.any? { |service| routes.include? service.route } }
    end

    def with_name(name)
      StopList.new select { |s| (s.name.casecmp name) == 0 }
    end
  end

  class Stop
    attr_reader :id, :name, :location, :buses, :updated, :services

    def initialize(id, name, location)
      @id = id
      @name = name
      @location = location
      @services = []
      @buses = []
      @updated = Time.at(0)
    end

    def href
      "/stops/#{CGI::escape(@name.downcase)}/#{CGI::escape(@id.downcase)}"
    end

    def routes
      @services.map(&:route).uniq
    end

    def distance_to(location)
      @location.distance_to location
    end

    def buses!
      self.update!
      self.buses
    end

    def update!
      puts "update!"
      return self if (Time.now.utc - @updated) <= 30
      source = RestClient.get "http://rtpi.ie/Text/Pages/WebDisplay.aspx?stopRef=#{@id}"
      doc = REXML::Document.new source
      @buses = doc.root.get_elements('//table/tr').drop(1).map { |tr|
        Bus.new(tr.elements[1].text, tr.elements[2].text, tr.elements[3].text.to_i)
      }
      @updated = Time.now.utc
      self
    end
  end

  class Bus < Struct.new(:route, :destination, :time)
  end
end