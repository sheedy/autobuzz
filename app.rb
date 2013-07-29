require 'sinatra/base'
require 'redis'
require 'uri'
require 'time'

class AutoBuzz < Sinatra::Base
  PHONENUMBER = ENV['PHONENUMBER'] || '+11231231234'
  DOORCODE = ENV['DOORCODE'] || '1111'

  uri = URI.parse(ENV['REDISCLOUD_URL'] || 'redis://localhost:16379')
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  set :bind, '0.0.0.0'

  helpers do
    def open_until
      @open_until ||=
        if open_until = REDIS.get('autobuzz.open_until')
          Time.at(open_until.to_i)
        end
    end

    def open_minutes
      (open_until - Time.now).to_i/60 if open_door?
    end

    def open_door?
      open_until && Time.now < open_until
    end
  end

  get '/' do
    content_type 'text/xml'
    if open_door?
      %{
<Response>
  <Pause length="2"/>
  <Say>Unlocking the door.</Say>
  <Play>http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/9.wav</Play>
  <Sms to="#{PHONENUMBER}">I just let someone through the door!</Sms>
  <Pause length="8"/>
</Response>
      }
    else
      %{
  <Response>
    <Gather action="/verify" timeout="3" numDigits="#{DOORCODE.length}">
      <Say>One moment, you are now being connected...</Say>
    </Gather>
    <Dial><Number>#{PHONENUMBER}</Number></Dial>
  </Response>
      }
    end
  end

  post '/verify' do
    content_type 'text/xml'
    if params[:Digits] == DOORCODE
      %{
<Response>
  <Play>http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/9.wav</Play>
  <Say>Welcome.</Say>
  <Sms to="#{PHONENUMBER}">I just let someone through the door!</Sms>
</Response>
      }
    elsif params[:tries]
      %{
<Response>
  <Say>That password was incorrect, again. I'll let you talk to a human.</Say>
  <Dial><Number>#{PHONENUMBER}</Number></Dial>
</Response>
      }
    else
      %{
<Response>
  <Gather action="/verify?tries=1" timeout="6" numDigits="#{DOORCODE.length}">
    <Say>That password was incorrect. Try again.</Say>
  </Gather>
  <Say>Sorry, I could not verify your password.</Say>
</Response>
      }
    end
  end

  get '/sms' do
    if params[:From] == PHONENUMBER
      case params[:Body]
      when /^lock door/i
        if open_door?
          REDIS.del('autobuzz.open_until', 0)
          return %{ <Response> <Sms>#{open_minutes} minutes were remaining, but the door is now locked.</Sms> </Response> }
        else
          return %{ <Response> <Sms>The door was already locked.</Sms> </Response> }
        end

      when /^(un)?(lock )?status/i
        if open_door?
          return %{ <Response> <Sms>The door will remain automatically unlocked for the next #{open_minutes} minutes.</Sms> </Response> }
        else
          return %{ <Response> <Sms>The door is locked. Say "unlock for [minutes]" to automatically open the door.</Sms> </Response> }
        end

      when /^unlock for (\d+)/i
        mins = $1.to_i
        REDIS.set('autobuzz.open_until', Time.now.to_i + (mins*60))
        return %{ <Response> <Sms>The door will now automatically be open for the next #{open_minutes} minutes.</Sms> </Response> }
      end
    end

    %{
<Response>
  <Sms>Huh?</Sms>
</Response>
    }
  end
end

if __FILE__ == $0
  AutoBuzz.run!
end
