require 'bus/api'
require 'yaml'
require 'json'
require 'sinatra/base'
require 'sinatra/jsonp'
require 'haml'
require 'sass'

module Bus
  class Views
    def services(services, options = {})
      {
        :data => services.map { |service|
          {
            :href => service.href,
            :route => service.route,
            :from => {
              :href => service.from.href,
              :name => service.from.name,
              :location => service.from.location
            },
            :to => {
              :href => service.to.href,
              :name => service.to.name,
              :location => service.to.location
            }
          }
          .merge(!options[:stops] ? {} : {
            :stops => service.stops.map { |stop|
              {
                :href => stop.href,
                :name => stop.name,
                :location => stop.location
              }
            }
          })
        }
      }
    end

    def stops(stops, options = {})
      {
        :data => stops.map { |stop|
          {
            :href => stop.href,
            :name => stop.name,
            :location => stop.location,
            :services => stop.services.map { |service|
              {
                :href => service.href,
                :route => service.route,
                :from => {
                  :href => service.from.href,
                  :name => service.from.name,
                  :location => service.from.location
                },
                :to => {
                  :href => service.to.href,
                  :name => service.to.name,
                  :location => service.to.location
                }
              }
            }
          }
          .merge(!options[:buses] ? {} : {
            :buses => stop.buses!.map { |bus|
              {
                :route => bus.route,
                :destination => bus.destination,
                :time => bus.time
              }
            }
          })
        }
      }
    end
  end
end
