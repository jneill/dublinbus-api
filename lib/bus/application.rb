require 'bus/api'
require 'json'
require 'sinatra/base'
require 'sinatra/jsonp'
require 'haml'
require 'sass'

module Bus
  class Application < Sinatra::Base
    helpers Sinatra::Jsonp

    configure do
      API = Api.new
    end

    get '/stop/' do
      stops = API.stops

      origin = DefaultOrigin

      if params[:origin]
      	origin = Geokit::LatLng.normalize(params[:origin])
        stops = stops.by_distance_from origin
      end

      if params[:range]
        stops = stops.within_range(origin, params[:range].to_f)
      end

      if params[:count]
      	stops = stops.take(params[:count].to_i)
      end

      if params[:route]
        stops = stops.on_route(params[:route])
      end

      result = { :stops => stops.map { |s| s.to_hash.delete_if { |k, v| k == :live } } }

      jsonp result
    end

    get '/stop/:name/' do
      stops = API.stops.with_name(params[:name])

      not_found if stops.none?

      stops.each(&:update!)

      result = { :stops => stops.map(&:to_hash) }

      jsonp result
    end

    get '/stop/:name/:id' do
      stops = API.stops.with_id(params[:id])

      not_found if stops.none?

      stops.each(&:update!)

      result = { :stops => stops.map(&:to_hash) }

      jsonp result
    end
  end
end
