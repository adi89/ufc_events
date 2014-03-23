require 'net/http'
require 'pry-debugger'
require 'multi_json'
require 'json'

class UFCEvents
  attr_accessor :query_id

  def event_extract(ufc_event)
    uri = encoded_event(ufc_event)
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      body = MultiJson.load(res.body)
      extract_content_from_json(body)
    else
      nil
    end
  end

protected
# we can call on these methods with ufc_events receiver or implicitly.

  def extract_content_from_json(body)
    begin
      query_hash = body['query']['pages']
      query_id = query_hash.keys.first
      content = query_hash[query_id]['extract']
      if content.empty?
        return "404. Not a valid UFC PPV"
      else
        puts content
        content
      end
    rescue
      puts "404. Not a valid UFC PPV."
    end
  end


  def formatted_ufc(event_string)
    event_string.gsub(/ufc/i, "UFC").strip.squeeze(" ")
  end

  def encoded_event(event_string)
    base_string = "http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&explaintext=&exsectionformat=plain&titles="
    ufc = URI.encode(formatted_ufc(event_string))
    URI("#{base_string}#{ufc}")
  end

end
