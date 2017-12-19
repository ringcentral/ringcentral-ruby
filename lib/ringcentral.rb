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
      # todo: authorization code flow
    else
      # todo: password flow
    end
  end

  def refresh
    return if @token == nil
    # todo: refresh token
  end

  def revoke
    return if @token == nil
    # todo: revoke token
  end

  def authorize_uri(redirect_uri, state = '')
    # todo: construct authorize_uri
  end
end
