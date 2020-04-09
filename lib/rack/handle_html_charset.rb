require 'byebug'

module Rack
  class HandleHtmlCharset
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
      headers = response[1]
      if headers['Content-Type'] == 'text/html'
        headers['Content-Type'] = 'text/html; charset=UTF-8'
      end
      response
    end
  end
end
