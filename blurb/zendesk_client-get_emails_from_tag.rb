require 'zendesk_api'
require 'logger'

LOGGER = Logger.new(STDOUT)

if ARGV[0].nil? || ARGV[1].nil? || ARGV[2].nil?
  LOGGER.info("Usage: ruby zendesk_client-get_emails_from_tag.rb 'blurb_zendesk_email' 'password' 'zendesk_tag'")
  abort
end

client = ZendeskAPI::Client.new do |config|
  # Mandatory:
  config.url = "https://blurb.zendesk.com/api/v2"

  # Basic / Token Authentication
  config.username = ARGV[0]
  config.password = ARGV[1]

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true
end

def process_item(item)
  LOGGER.info "#{item.result_type},#{item.id},#{item.via.source.from.address}"
end

search_results = client.search(:query => "type:ticket tags:#{ARGV[2]}")

search_results.all(1) {|item| process_item(item)}

