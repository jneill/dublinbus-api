require 'bus/api'
require 'bus/views'
require 'yaml'
require 'json'
require 'sinatra/base'
require 'sinatra/jsonp'
require 'haml'
require 'sass'

module Bus
  class Application < Sinatra::Base
    helpers Sinatra::Jsonp

    configure do
      API = Api.new(YAML::load(File.open('service-info.yml')))
    end

    get '/' do
      redirect 'http://github.com/jneill/dublinbus-api'
    end

    get '/services' do
      services = API.services

      view :services, services
    end

    get '/services/:route' do
      services = API.services.on_route params[:route]

      not_found if services.none?

      view :services, services, :stops => true
    end

    get '/services/:route/:id' do
      services = [API.services[params[:id]]]

      not_found if services.none?

      view :services, services, :stops => true
    end

    get '/stops' do
      stops = API.stops

      origin = params[:origin] ? Geokit::LatLng.normalize(params[:origin]) : DefaultOrigin

      stops = stops.sort_by_distance_from origin if params[:origin]
      stops = stops.within_range(origin, params[:range].to_f) if params[:range]
      stops = stops.on_routes params[:routes].split(',') if params[:routes]

      view :stops, stops
    end

    get '/stops/:name' do
      stops = API.stops.with_name params[:name]

      not_found if stops.none?

      view :stops, stops
    end

    get '/stops/:name/:id' do
      stops = [API.stops[params[:id]]]

      not_found if stops.none?

      view :stops, stops, :buses => true
    end

    def view(view, data, options = {})
      jsonp(Views.new.method(view).call(data, options))
    end
  end
end
