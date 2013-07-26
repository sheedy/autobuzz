require 'sinatra/base'

class Buzzzzz < Sinatra::Base
  get '/' do
    content_type 'text/xml'
    %{
<Response>
  <Say>Hello</Say>
  <Play>http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/9.wav</Play>
  <Pause/>
  <Play>http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/9.wav</Play>
</Response>
    }
  end
end

Buzzzzz.run!
