require 'test/unit'
require 'ringcentral'

class RingCentralTest < Test::Unit::TestCase
  def test_hello
    assert_equal 'https://platform.devtest.ringcentral.com', RingCentral.SANDBOX_SERVER
    assert_equal 'https://platform.ringcentral.com', RingCentral.PRODUCTION_SERVER
  end
end
