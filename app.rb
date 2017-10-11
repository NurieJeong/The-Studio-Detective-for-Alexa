require "sinatra"
require 'sinatra/reloader' if development?

require 'alexa_skills_ruby'
require 'httparty'
require 'iso8601'

# ----------------------------------------------------------------------

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end

# enable sessions for this project
enable :sessions


# ----------------------------------------------------------------------
#     How you handle your Alexa
# ----------------------------------------------------------------------

class CustomHandler < AlexaSkillsRuby::Handler

  on_intent("GetWhoIs") do
    slots = request.intent.slots
    message = "I'm Daragh's MeBot"
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end

  on_intent("GetWhatIs") do
    slots = request.intent.slots
    message = "I'm a bot that'll let you ask things about Daragh without bothering him."
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end

  on_intent("GetWhyIs") do
    slots = request.intent.slots
    message = "He made me for this class. To show you how to make simple bots"
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end

  on_intent("GetWhereIs") do
    slots = request.intent.slots
    message = "Daragh's in class right now. Standing right in front of you. I'm floating on a server in the cloud. "
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end


  on_intent("GetWhenIs") do
    slots = request.intent.slots
    message = "It's today. And today is my birthday."
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end


  on_intent("GetRandom") do

    message = ["Daragh is from Dublin", "Daragh moved to the US in 2011", "Daragh lived in Phoenix Arizona for two years", "Daragh will never skydive again", "Daragh has lots of pocketsquares"].sample
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'
  end

  on_intent("AMAZON.HelpIntent") do

    message = "I can help you find out things about Daragh. Ask me random things"
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'GetWhoIs processed'

  end



end

# ----------------------------------------------------------------------
#     ROUTES, END POINTS AND ACTIONS
# ----------------------------------------------------------------------


get '/' do
  404
end


# THE APPLICATION ID CAN BE FOUND IN THE


post '/alexa/incoming' do

  content_type :json

  handler = CustomHandler.new(application_id: ENV['ALEXA_APPLICATION_ID'], logger: logger)

  begin
    hdrs = { 'Signature' => request.env['HTTP_SIGNATURE'], 'SignatureCertChainUrl' => request.env['HTTP_SIGNATURECERTCHAINURL'] }
    handler.handle(request.body.read, hdrs)
  rescue AlexaSkillsRuby::Error => e
    logger.error e.to_s
    403
  end

end



# ----------------------------------------------------------------------
#     ERRORS
# ----------------------------------------------------------------------



error 401 do
  "Not allowed!!!"
end
