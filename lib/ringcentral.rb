require 'base64'
require 'addressable/uri'
require 'subscription'
require 'json'
require 'concurrent'
require 'faraday'

class RingCentral
  def self.SANDBOX_SERVER
    'https://platform.devtest.ringcentral.com'
  end

  def self.PRODUCTION_SERVER
    'https://platform.ringcentral.com'
  end

  attr_reader :app_key, :app_secret, :server, :token
  attr_accessor :auto_refresh

  def initialize(app_key, app_secret, server)
    @app_key = app_key
    @app_secret = app_secret
    @server = server
    @auto_refresh = true
    @token = nil
    @timer = nil
    @faraday = Faraday.new(url: server) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def token=(value)
    @token = value
    if @timer != nil
      @timer.shutdown
      @timer = nil
    end
    if @auto_refresh && value != nil
      @timer = Concurrent::TimerTask.new(execution_interval: value['expires_in'] - 120, timeout_interval: 60) { self.refresh }
      @timer.execute
    end
  end

  def authorize(username: nil, extension: nil, password: nil, auth_code: nil, redirect_uri: nil)
    if auth_code != nil
      payload = {
        grant_type: 'authorization_code',
        code: auth_code,
        redirect_uri: redirect_uri,
      }
    else
      payload = {
        grant_type: 'password',
        username: username,
        extension: extension,
        password: password,
      }
    end
    self.token = nil
    r = self.post('/restapi/oauth/token', payload: payload)
    self.token = JSON.parse(r.body)
  end

  def refresh
    return if @token == nil
    payload = {
      grant_type: 'refresh_token',
      refresh_token: @token['refresh_token']
    }
    self.token = nil
    r = self.post('/restapi/oauth/token', payload: payload)
    self.token = JSON.parse(r.body)
  end

  def revoke
    return if @token == nil
    payload = { token: @token['access_token'] }
    self.token = nil
    self.post('/restapi/oauth/revoke', payload: payload)
  end

  def authorize_uri(redirect_uri, state = '')
    uri = Addressable::URI.parse(@server) + '/restapi/oauth/authorize'
    uri.query_values = {
      response_type: 'code',
      state: state,
      redirect_uri: redirect_uri,
      client_id: @app_secret
    }
    uri.to_s
  end

  def get(endpoint, params = {})
    @faraday.get do |req|
      req.url endpoint
      req.params = params
      req.headers = headers
    end
  end

  def post(endpoint, payload: nil, params: {}, files: nil)
    @faraday.post do |req|
      req.url endpoint
      req.params = params
      if payload != nil && @token != nil
        req.headers = headers.merge({ 'Content-Type': 'application/json' })
        req.body = payload.to_json
      else
        req.headers = headers
        req.body = payload
      end
    end
  end

  def put(endpoint, payload: nil, params: {}, files: nil)
    @faraday.put do |req|
      req.url endpoint
      req.params = params
      req.headers = headers.merge({ 'Content-Type': 'application/json' })
      req.body = payload.to_json
    end
  end

  def delete(endpoint, params = {})
    @faraday.delete do |req|
      req.url endpoint
      req.params = params
      req.headers = headers
    end
  end

  def subscription(events, callback)
    Subscription.new(self, events, callback)
  end

  private

    def basic_key
      Base64.encode64("#{@app_key}:#{@app_secret}").gsub(/\s/, '')
    end

    def autorization_header
      @token != nil ? "Bearer #{@token['access_token']}" : "Basic #{basic_key}"
    end

    def headers
      user_agent_header = "ringcentral/ringcentral-ruby Ruby #{RUBY_VERSION} #{RUBY_PLATFORM}"
      {
        'Authorization': autorization_header,
        'RC-User-Agent': user_agent_header,
        'User-Agent': user_agent_header,
      }
    end
end
