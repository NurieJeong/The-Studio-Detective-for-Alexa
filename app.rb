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

  on_intent("StartTheGame") do
    slots = request.intent.slots
    message = "Alright, let's play The Studio Detective.
      One sunny day, you put your lunchbox in the fridgerator. You worked hard, hard and so hard until noon, looking forward to having lunch. 
      It’s finally the lunch break. You opened the fridge and looked for the lunchbox. But instead of the lunchbox, you could only see a note inside the fridge."
    media = "https://www.ndtv.com/news/2_BIcBdVI.jpg"
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'StartTheGame processed'
  end

  on_intent("MoveThePlace") do
    slots = request.intent.slots("Kitchen")
    message = "There is only one person, Vikas, is wondering around the kitchen. He is heating his microwave lunch. You can talk with him or do something else."
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'MoveThePlace processed'
  end


  on_intent("MoveThePlace") do
    slots = request.intent.slots("Studio")
    message = "At the entrance of the studio, you found another note."
    media = "https://i2.wp.com/www.thebibliophilegirluk.com/wp-content/uploads/img_2142.png?resize=600%2C576"
    message = "There are two people, Meric and Kenz are talking to each other. You can talk with them or do something else."
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'MoveThePlace processed'
  end


  on_intent("MoveThePlace") do
    slots = request.intent.slots("The Classroom")
    message = "When you went inside the classroom, you found that your lunch bag was dropped on the floor. You grabbed it and see inside, but there was only a chocolate bar wrap folded.
Alas, you couldn’t save your chocolate bar, but you still might be able to save your sandwich…?"
    message = "You saw the message from Daragh’s TA in the white board."
    media = "https://pbs.twimg.com/media/C1voRuGXcAEGBkB.jpg"
    response.set_output_speech_text( message )
    response.set_simple_card("MeBot", message )
    logger.info 'MoveThePlace processed'
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
