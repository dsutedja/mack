require "test/unit"

module Mack
  
  module TestHelpers
    
    # Runs the given rake task. Takes an optional hash that mimics command line parameters.
    def rake_task(name, env = {}, tasks = File.join(File.dirname(__FILE__), "..", "mack_tasks.rb"))
      # set up the Rake application
      rake = Rake::Application.new
      Rake.application = rake
      
      load(tasks)
      
      # save the old ENV so we can revert it
      old_env = ENV.to_hash
      # add in the new ENV stuff
      env.each_pair {|k,v| ENV[k.to_s] = v}
      
      begin
        # run the rake task
        rake[name].invoke
        
        # yield for the tests
        yield if block_given?
        
      rescue Exception => e
        raise e
      ensure
        # empty out the ENV
        ENV.clear
        # revert to the ENV before the test started
        old_env.to_hash.each_pair {|k,v| ENV[k] = v}

        # get rid of the Rake application
        Rake.application = nil
      end
    end
    
    # Temporarily changes the application configuration. Changes are reverted after
    # the yield returns.
    def temp_app_config(options = {})
      app_config.load_hash(options, String.randomize)
      yield
      app_config.revert
    end
    
    def remote_test # :nodoc:
      if (app_config.run_remote_tests)
        yield
      end
    end
    
    # Retrieves an instance variable from the controller from a request.
    def assigns(key)
      $mack_app.instance_variable_get("@app").instance_variable_get("@response").instance_variable_get("@controller").instance_variable_get("@#{key}")
    end

    # Performs a 'get' request for the specified uri.
    def get(uri, options = {})
      build_response(request.get(uri, build_request_options(options)))
    end
    
    # Performs a 'put' request for the specified uri.
    def put(uri, options = {})
      build_response(request.put(uri, build_request_options({:input => options.to_params})))
    end
    
    # Performs a 'post' request for the specified uri.
    def post(uri, options = {})
      build_response(request.post(uri, build_request_options({:input => options.to_params})))
    end
    
    # Performs a 'delete' request for the specified uri.
    def delete(uri, options = {})
      build_response(request.delete(uri, build_request_options(options)))
    end
    
    # Returns a Rack::MockRequest. If there isn't one, a new one is created.
    def request
      @request ||= Rack::MockRequest.new(mack_app)
    end
    
    # Returns the last Rack::MockResponse that got generated by a call.
    def response
      responses.last
    end
    
    # Returns all the Rack::MockResponse objects that get generated by a call.
    def responses
      @responses
    end
    
    # Returns a Mack::Session from the request.
    def session # :nodoc:
      Cachetastic::Caches::MackSessionCache.get(cookies[app_config.mack.session_id])
    end
    
    # Used to create a 'session' around a block of code. This is great of 'integration' tests.
    def in_session
      @in_session = true
      clear_session
      yield
      clear_session
      @in_session = false
    end
    
    # Clears all the sessions.
    def clear_session
      Cachetastic::Caches::MackSessionCache.expire_all
    end
    
    # Returns a Hash of cookies from the response.
    def cookies
      test_cookies
    end
    
    # Sets a cookie to be used for the next request
    def set_cookie(name, value)
      test_cookies[name] = value
    end
    
    # Removes a cookie.
    def remove_cookie(name)
      test_cookies.delete(name)
    end
    
    def method_missing(sym, *args)
      sym = sym.to_s
      case sym
      when /^clean_(.+)/
        captures = sym.match(/^clean_(.+)/).captures
        thing = eval(captures.first)
        if File.exists?(thing)
          FileUtils.rm_rf(thing)
        end
      else
        raise NoMethodError.new(sym)
      end
    end
    
    private
    def test_cookies
      @test_cookies = {} if @test_cookies.nil?
      @test_cookies
    end
    
    def mack_app
      if $mack_app.nil?
        $mack_app = Rack::Recursive.new(Mack::Runner.new)
      end
      $mack_app
    end
    
    def build_request_options(options)
      {"HTTP_COOKIE" => test_cookies.join("%s=%s", "; ")}.merge(options)
    end
    
    def build_response(res)
      @responses = [res]
      strip_cookies_from_response(res)
      # only retry if it's a redirect request
      if res.redirect? 
        until res.successful?
          [res].flatten.each do |r|
            strip_cookies_from_response(r)
          end
          res = request.get(res["Location"])
          @responses << res
        end
      end
    end
    
    def strip_cookies_from_response(res)
      unless res.original_headers["Set-Cookie"].nil?
        res.original_headers["Set-Cookie"].each do |ck|
          spt = ck.split("=")
          name = spt.first
          value = spt.last
          if name == app_config.mack.session_id
            value = nil unless @in_session
          end
          set_cookie(name, value)
        end
      end
    end
    
  end # TestHelpers
  
end # Mack

Test::Unit::TestCase.send(:include, Mack::TestHelpers)