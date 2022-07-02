require 'base64'
require 'addressable/uri'
require 'json'
require 'concurrent'
require 'faraday'
require 'faraday/multipart'
require 'tmpdir'

class RingCentral
  def self.SANDBOX_SERVER
    'https://platform.devtest.ringcentral.com'
  end

  def self.PRODUCTION_SERVER
    'https://platform.ringcentral.com'
  end

  attr_reader :client_id, :client_secret, :server, :token
  attr_accessor :auto_refresh

  def initialize(client_id, client_secret, server)
    @client_id = client_id
    @client_secret = client_secret
    @server = server
    @auto_refresh = false
    @token = nil
    @timer = nil
    @faraday = Faraday.new(url: server, request: { params_encoder: Faraday::FlatParamsEncoder }) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.response :json, content_type: /\bjson$/
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

  def authorize(username: nil, extension: nil, password: nil, auth_code: nil, redirect_uri: nil, jwt: nil, verifier: nil)
    if auth_code != nil
      payload = {
        grant_type: 'authorization_code',
        code: auth_code,
        redirect_uri: redirect_uri,
      }
      if verifier != nil
        payload["code_verifier"] = verifier
      end
    elsif jwt != nil
      payload = {
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt
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
    self.token = r.body
  end

  def refresh
    return if @token == nil
    payload = {
      grant_type: 'refresh_token',
      refresh_token: @token['refresh_token']
    }
    self.token = nil
    r = self.post('/restapi/oauth/token', payload: payload)
    self.token = r.body
  end

  def revoke
    return if @token == nil
    payload = { token: @token['access_token'] }
    self.token = nil
    self.post('/restapi/oauth/revoke', payload: payload)
  end

  def authorize_uri(redirect_uri, state = '', challenge = nil, challenge_method = 'S256')
    uri = Addressable::URI.parse(@server) + '/restapi/oauth/authorize'
    uri.query_values = {
      response_type: 'code',
      state: state,
      redirect_uri: redirect_uri,
      client_id: @client_id
    }
    if challenge != nil
      uri.query_values["code_challenge"] = challenge
      uri.query_values["code_challenge_method"] = challenge_method
    end
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
      if files != nil && files.size > 0 # send fax or MMS
        io = StringIO.new(payload.to_json)
        payload = {}
        payload[:json] = Faraday::UploadIO.new(io, 'application/json')
        payload[:attachment] = files.map{ |file| Faraday::UploadIO.new(file[0], file[1]) }
        req.headers = headers
        req.body = payload
      elsif payload != nil && @token != nil
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

  def patch(endpoint, payload: nil, params: {}, files: nil)
    @faraday.patch do |req|
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

  private

    def basic_key
      Base64.encode64("#{@client_id}:#{@client_secret}").gsub(/\s/, '')
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
