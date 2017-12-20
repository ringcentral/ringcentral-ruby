require 'base64'
require 'addressable/uri'
require 'subscription'

class RingCentral
  def self.SANDBOX_SERVER
    'https://platform.devtest.ringcentral.com'
  end

  def self.PRODUCTION_SERVER
    'https://platform.ringcentral.com'
  end

  attr_reader :app_key, :app_secret, :server
  attr_accessor :auto_refresh

  def initialize(app_key, app_secret, server)
    @app_key = app_key
    @app_secret = app_secret
    @server = server
    @auto_refresh = true
  end

  def token
    @token
  end

  def token=(value)
    @token = value
    if @timer != nil
      # todo: cancel the timer
      @timer = nil
    end
    if @auto_refresh && value != nil
      # todo: create the timer
    end
  end

  def authorize(username = nil, extension = nil, password = nil, auth_code = nil, redirect_uri = nil)
    if auth_code
      payload = {
        'grant_type': 'authorization_code',
        'code': auth_code,
        'redirect_uri': redirect_uri,
      }
    else
      payload = {
        'grant_type': 'password',
        'username': username,
        'extension': extension,
        'password': password,
      }
    end
    r = post('/restapi/oauth/token', payload: payload)
    @token = JSON.parse(r.body)
    r
  end

  def refresh
    return if @token == nil
    payload = {
      'grant_type': 'refresh_token',
      'refresh_token': @token.refresh_token
    }
    @token = nil
    r = post('/restapi/oauth/token', payload: payload)
    @token = JSON.parse(r.body)
    r
  end

  def revoke
    return if @token == nil
    payload = {
      token: @token.access_token
    }
    @token = nil
    post('/restapi/oauth/revoke', payload: payload)
  end

  def authorize_uri(redirect_uri, state = '')
    uri = Addressable::URI.parse(@server) + '/restapi/oauth/authorize'
    uri.query_values = {
      'response_type': 'code',
      'state': state,
      'redirect_uri': redirect_uri,
      'client_id': @app_secret
    }
    uri.to_s
  end

  def get(endpoint, params = nil)
    request(:GET, endpoint, params: params)
  end

  def post(endpoint, payload = nil, params = nil, files = nil)
    request(:POST, endpoint, payload: payload, params: params, files: files)
  end

  def put(endpoint, payload = nil, params = nil, files = nil)
    request(:PUT, endpoint, payload: payload, params: params, files: files)
  end

  def delete(endpoint, params = nil)
    request(:DELETE, endpoint, params: params)
  end

  def subscription(event_filters, callback)
    Subscription.new(event_filters, callback)
  end

  private

  def basic_key
    Base64.encode64 "#{@app_key}:#{@app_secret}"
  end

  def autorization_header
    return "Bearer #{@token.access_token}" if @token != nil
    return "Basic #{basic_key()}"
  end

  def request(method, endpoint, params = nil, payload = nil, files = nil)
    url = (Addressable::URI.parse(@server) + endpoint).to_s
    user_agent_header = "ringcentral/ringcentral-ruby Ruby #{RUBY_VERSION} #{RUBY_PLATFORM}"
    headers = {
      'Authorization': autorization_header(),
      'User-Agent': user_agent_header,
      'RC-User-Agent': user_agent_header,
    }
    RestClient::Request.execute(method: method.to_sym, url: url, params: params,
      payload: (payload == nil ? nil : payload.to_json), headers: headers, files: files)
  end
end
