require 'test/unit'
require 'ringcentral'

class RingCentralTest < Test::Unit::TestCase
  def test_class_variables
    assert_equal 'https://platform.devtest.ringcentral.com', RingCentral.SANDBOX_SERVER
    assert_equal 'https://platform.ringcentral.com', RingCentral.PRODUCTION_SERVER
  end

  def test_initializer
    rc = RingCentral.new('app_key', 'app_secret', RingCentral.SANDBOX_SERVER)
    assert_equal 'app_key', rc.app_key
    assert_equal 'app_secret', rc.app_secret
    assert_equal 'https://platform.devtest.ringcentral.com', rc.server
    assert_equal true, rc.auto_refresh
  end
end
