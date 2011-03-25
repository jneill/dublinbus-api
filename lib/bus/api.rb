require 'bus/stop'
require 'bus/service'
require 'rubygems'
require 'geokit'
require 'cgi'

module Bus
  DefaultOrigin = Geokit::LatLng.new(53.347778,-6.259722)

  class Api
    attr_reader :stops, :services

    def initialize(config)
      stops = config['stops'].map { |s| Stop.new(s['id'], s['name'], Geokit::LatLng.normalize(s['location'])) }
      @stops = StopList.new(stops).sort_by_distance_from(DefaultOrigin)

      services = config['services'].map.with_index do |s,i|
      	stops = s['stops'].map { |x| @stops[x] }
        Service.new(s['id'], s['route'], stops)
      end
      services.sort_by! { |s| s.route.to_i }
      @services = ServiceList.new services

      @services.each do |service|
        service.stops.each do |stop|
          stop.services.push(service)
        end
      end

      self
    end
  end
end
