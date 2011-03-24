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

    get '/' do
      redirect 'http://github.com/jneill/dublinbus-api'
    end

    get '/stops' do
      stops = API.stops

      origin = params[:origin] ? Geokit::LatLng.normalize(params[:origin]) : DefaultOrigin

      stops = stops.sort_by_distance_from origin if params[:origin]
      stops = stops.within_range(origin, params[:range].to_f) if params[:range]
      stops = stops.take params[:count].to_i if params[:count]

      result = { :stops => stops.map { |s| s.to_hash.delete_if { |k, v| k == :live } } }

      jsonp result
    end

    get '/stops/:name' do
      live_data API.stops.with_name params[:name]
    end

    get '/stops/:name/:id' do
      live_data API.stops.with_id params[:id]
    end

    def live_data(stops)
      not_found if stops.none?
      stops.each(&:update!)
      jsonp({ :stops => stops.map(&:to_hash) })
	end
  end
end
