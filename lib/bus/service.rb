
module Bus
  class ServiceList
    include Enumerable

    def initialize(services)
      @services = Hash[ services.map{ |s| [s.id, s] }]
    end

    def each
      @services.each { |id, s| yield s }
    end

    def[](id)
      @services[id]
    end

    def on_route(route)
      ServiceList.new select { |s| (s.route.casecmp route) == 0 }
    end
  end

  class Service < Struct.new(:id, :route, :stops)
    def href
      "/services/#{CGI::escape(route.downcase)}/#{CGI::escape(id.downcase)}"
    end

    def from
      self.stops.first
    end

    def to
      self.stops.last
    end
  end
end