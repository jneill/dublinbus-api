require 'rubygems'
require 'yaml'
require 'rest_client'
require 'rexml/document'
require 'geokit'
require 'cgi'

module Bus
  DefaultOrigin = Geokit::LatLng.new(53.347778,-6.259722)

  class Api
    attr_reader :stops

    def initialize
      config = YAML::load File.open('stops.yml')
      stops = config.map { |s| Stop.new(s['ref'], s['name'], Geokit::LatLng.new(s['lat'], s['lng'])) }
      @stops = StopList.new(stops).by_distance_from(DefaultOrigin)
    end
  end

  class StopList
    include Enumerable

    def initialize(stops)
      @stops = stops
    end

    def each
      @stops.each { |i| yield i }
    end

    def by_distance_from(origin)
      StopList.new sort_by { |s| s.distance_from origin }
    end

    def within_range(origin, range)
      StopList.new select { |s| s.distance_from(origin) <= range }	
    end

    def on_route(route)
      StopList.new select { |s| s.routes.include? route }
    end

    def with_id(id)
      StopList.new select { |s| s.id == id }
    end

    def with_name(name)
      StopList.new select { |s| s.name.downcase == name }
    end
  end

  class Stop
    attr_reader :id, :name, :location, :routes, :services, :updated

    def initialize(id, name, location)
      @id = id
      @name = name
      @location = location
      @routes = Set.new
      @services = []
      @updated = Time.at(0)
    end

    def url
      "/stop/#{CGI::escape(@name.downcase)}/#{@id}"
    end

    def distance_to(location)
      @location.distance_to location
    end

    alias distance_from distance_to

    def to_hash
      {
        :href => url,
        :name => @name,
        :loc => @location,
        :routes => @routes.to_a,
        :live =>
        { 
          :updated => @updated.iso8601, 
          :services => @services.map(&:to_hash)
        }
      }
    end

    def update!
      return self if (Time.now.utc - @updated) <= 30
      source = RestClient.get "http://rtpi.ie/Text/Pages/WebDisplay.aspx?stopRef=#{@id}"
      doc = REXML::Document.new source
      @services = doc.root.get_elements('//table/tr').drop(1).map { |tr|
        @routes.add(tr.elements[1].text)
        Service.new(tr.elements[1].text, tr.elements[2].text, tr.elements[3].text.to_i)
      }
      @updated = Time.now.utc
      self
    end
  end

  class Service < Struct.new(:route, :destination, :time)
    def to_hash
      {
        :route => self.route,
        :dest => self.destination,
        :time => self.time
      }
    end
  end
end
