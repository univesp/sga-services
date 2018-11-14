module Canvas
  class Repository
    include HTTParty

    def initialize(env)
      @env = env
      # @accept = accept
      set_canvas_credentials
    end

    def get_by_resources(resources,
                         url = '',
                         search_term = '')
      res = []

      resources.each do |resource|
        url << "/#{resource[:name]}"
        url << "/#{resource[:id]}" if resource[:id]
      end

      url = URI.encode url
      page = 1
      begin
        options = { query: { page: page }, verify: false }
        options[:query].merge!({ search_term: search_term }) unless search_term.empty?

        req = self.class.get url, options
        if req.parsed_response.is_a? Array # two or more results
          req.parsed_response.each { |r| res << r }
        else # unique result
          res = req.parsed_response
          break
        end
        page += 1
      end while req.headers.include?('link') && req.headers['link'].match(/next/)

      res.to_json
    end

    def set_by_resources(resources,
                         method,
                         params = nil,
                         url = '')
      res = []

      resources.each do |resource|
        url << "/#{resource[:name]}"
        url << "/#{resource[:id]}" if resource[:id]
      end

      url = URI.encode url
      options = { :body => params, :verify => false }

      case method
      when :post then res = self.class.post(url, options)
      when :put then res = self.class.put(url, options)
      when :delete then res = self.class.delete(url, options)
      end

      res.to_json
    end

    private
    def set_canvas_credentials
      canvas_host = ENV['CANVAS_HOST_NOVO']
      canvas_token = ENV['CANVAS_TOKEN_NOVO']

      # if @accept && @accept.include?('application/vnd.canvas_antigo')
      #   canvas_host = ENV['CANVAS_HOST_ANTIGO']
      #   canvas_token = ENV['CANVAS_TOKEN_ANTIGO']
      # end

      self.class.base_uri "#{canvas_host}/api/v1"
      self.class.headers('Authorization' => "Bearer #{canvas_token}")
    end
  end
end