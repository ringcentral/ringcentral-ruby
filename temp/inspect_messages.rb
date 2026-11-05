require 'dotenv'
require 'time'
require_relative '../lib/ringcentral'

Dotenv.load(File.expand_path('../.env', __dir__), overwrite: true)
required = %w[RINGCENTRAL_CLIENT_ID RINGCENTRAL_CLIENT_SECRET RINGCENTRAL_JWT_TOKEN]
missing = required.select { |name| ENV[name].to_s.empty? }
abort "Missing environment variables: #{missing.join(', ')}" unless missing.empty?

rc = RingCentral.new(
  ENV.fetch('RINGCENTRAL_CLIENT_ID'),
  ENV.fetch('RINGCENTRAL_CLIENT_SECRET'),
  ENV.fetch('RINGCENTRAL_SERVER_URL', RingCentral.PRODUCTION_SERVER)
)

begin
  rc.authorize(jwt: ENV.fetch('RINGCENTRAL_JWT_TOKEN'))
  date_from = (Time.now.utc - 7 * 24 * 60 * 60).iso8601
  puts "Outbound fax and SMS/MMS since #{date_from} (UTC); phone numbers masked."
  %w[Fax SMS].each do |type|
    page = 1
    count = 0
    loop do
      body = rc.get('/restapi/v1.0/account/~/extension/~/message-store', {
        direction: 'Outbound', messageType: type, dateFrom: date_from,
        dateTo: Time.now.utc.iso8601, perPage: 100, page: page
      }).body
      body.fetch('records').each do |message|
        summary = message.slice('id', 'type', 'creationTime', 'lastModifiedTime',
          'messageStatus', 'deliveryErrorCode', 'faxErrorCode', 'faxErrorDescription',
          'faxPageCount', 'faxResolution', 'smsSendingAttemptsCount')
        summary['to'] = message.fetch('to', []).map do |recipient|
          recipient.slice('messageStatus', 'faxErrorCode', 'faxErrorDescription',
            'deliveryErrorCode').merge('phoneNumber' => "***#{recipient['phoneNumber'].to_s[-4, 4]}")
        end
        summary['attachments'] = message.fetch('attachments', []).map do |attachment|
          attachment.slice('type', 'contentType')
        end
        puts JSON.pretty_generate(summary)
        count += 1
      end
      break unless body.dig('navigation', 'nextPage')
      page += 1
    end
    puts "#{type}: #{count} outbound messages."
  end
rescue StandardError => e
  # SDK exceptions contain full response headers; keep those out of diagnostics.
  warn "Message inspection failed (#{e.class}): #{e.message.lines.first.to_s.strip}"
  exit 1
ensure
  if rc.token
    begin
      rc.revoke
    rescue StandardError
      warn 'Could not revoke the diagnostic session token.'
    end
  end
end
