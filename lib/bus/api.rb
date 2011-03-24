require 'rubygems'
require 'yaml'
require 'rest_client'
require 'rexml/document'
require 'geokit'
require 'cgi'

module Bus
  DefaultOrigin = Geokit::LatLng.new(53.347778,-6.259722)

  class Api
    attr_reader :stops, :services

    def initialize
      config = YAML::load File.open('service-info.yml')

      stops = config['stops'].map { |s| Stop.new(s['id'], s['name'], Geokit::LatLng.normalize(s['location'])) }
      @stops = StopList.new(stops).sort_by_distance_from(DefaultOrigin)

      services = config['services'].map do |s|
        Service.new(s['route'], s['stops'].map { |x| @stops[x] })
      end
      @services = ServiceList.new services
    end
  end

  class StopList
    include Enumerable

    def initialize(stops)
      @stops = Hash[ stops.map{ |s| [s.id, s] }]
    end

    def[](id)
      @stops[id]
    end

    def each
      @stops.each { |id, s| yield s }
    end

    def sort_by_distance_from(origin)
      StopList.new sort_by { |s| s.distance_from origin }
    end

    def within_range(origin, range)
      StopList.new select { |s| s.distance_from(origin) <= range }	
    end

    def with_name(name)
      StopList.new select { |s| s.name.downcase == name }
    end
  end

  class ServiceList
    include Enumerable

    def initialize(services)
      @services = services
    end

    def each
      @services.each { |s| yield s }
    end

    def on_route(route)
      ServiceList.new select { |s| s.route.downcase == route }
    end

    def within_range(origin, range)
      StopList.new select { |s| s.distance_from(origin) <= range }	
    end

    def with_name(name)
      StopList.new select { |s| s.name.downcase == name }
    end
  end

  class Service < Struct.new(:route, :stops)
    def to_hash
      {
        :route => self.route,
        :from => self.stops.first.name,
        :to => self.stops.last.name
      }
    end

    def url
      "/services/#{CGI::escape(@name.downcase)}/#{@id}"
    end
  end

  class Stop
    attr_reader :id, :name, :location, :buses, :updated

    def initialize(id, name, location)
      @id = id
      @name = name
      @location = location
      @buses = []
      @updated = Time.at(0)
    end

    def url
      "/stops/#{CGI::escape(@name.downcase)}/#{@id}"
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
        :live =>
        { 
          :updated => @updated.iso8601, 
          :buses => @buses.map(&:to_hash)
        }
      }
    end

    def update!
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
    def to_hash
      {
        :route => self.route,
        :dest => self.destination,
        :time => self.time
      }
    end
  end
end
