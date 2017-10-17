require "sinatra"
require 'sinatra/reloader' if development?

require 'alexa_skills_ruby'
require 'httparty'
require 'iso8601'
require 'timeout'
require 'twilio-ruby'

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
      It was a typical sunny day. #{ENV["USERNAME"]} came late to the design studio, feeling something odd vibe.
      When you entered the studio, #{ENV["USERNAME"]} heard a scream of Manya from the kitchen."
    message += "Who the hell stole my sandwich? This is not funny! Manya said."
    message += "#{ENV["USERNAME"]} ran into the kitchen and saw Manya. She looked very angry and pointed to the fridge.
      On the door of the fridge, you could only see a note inside the fridge."

    media = "https://www.ndtv.com/news/2_BIcBdVI.jpg"

    @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    @client.api.account.messages.create(
      from: ENV["TWILIO_FROM"],
      to: ENV["USER_PHONE"],
      body: "A message from the lunchbox thief",
      media_url: media
    )

    message += "It must be the note from the lunch box thief! #{ENV["USERNAME"]} thought.
      As a dear friend of her, #{ENV["USERNAME"]} decided to help. Don't worry Manya, I will help you get back your lunch."
    message += "From now on, you should investigate the case within 10 minutes. You can either look around the kitchen,
      the studio and the classroom."
    response.set_output_speech_text( message )
    response.set_simple_card("Narrator", message )
    logger.info 'StartTheGame processed'
  end

  on_intent("MoveThePlace") do
    slots = request.intent.slots

    if slots["investigation_place"].include? "kitchen"
      message = "There is only one person, Vikas, is wondering around the kitchen. He is heating his microwave lunch. You can either talk with him or move to another place."
    elsif slots["investigation_place"].include? "studio"
      message = "At the entrance of the studio, you found another note."
      media = "https://i2.wp.com/www.thebibliophilegirluk.com/wp-content/uploads/img_2142.png?resize=600%2C576"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "The first clue",
        media_url: media
      )
      message += "There are two people, Meric and Mackenzie are talking to each other. You can talk with them, investigate the studio or move to another place."
    elsif slots["investigation_place"].include? "classroom"
      message = "You saw the message from Daragh’s TA in the white board."
      media = "https://pbs.twimg.com/media/C1voRuGXcAEGBkB.jpg"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "A message from Daragh",
        media_url: media
      )
    end

    response.set_output_speech_text( message )
    response.set_simple_card("Narrator", message )
    logger.info 'MoveThePlace processed'
  end

    on_intent("TalkToSuspect") do
      slots = request.intent.slots
        if slots["suspect_name"] == "vikas"
          message = "Yo unni, what's up?"
        elsif slots["suspect_name"] == "meric"
          message = "Yo what's up? said Meric, What do you want from me?"
        elsif slots["suspect_name"] == "mackenzie"
          message = "Hey #{ENV["USERNAME"]} what are you up to?"
        elsif slots["suspect_name"] == "manya"
          message = "Hey, thanks so much for your help. What do you want to know?"
        else
          message = "#{slots["suspect_name"]} doesn't seem to want to talk right now. "
        end
      response.set_output_speech_text( message )
      response.set_simple_card("Narrator", message )
      logger.info 'TalkToSuspect processed'
    end


  on_intent("Vikas_GetTheClue") do
    slots = request.intent.slots

      if slots["vikas_clue"] == "Handwriting"
        message = "Vikas said. My handwriting? Dunno why you ask me about it. Is there something happened to you?"
        media = "https://c5.staticflickr.com/9/8703/28188463060_2e37d1cc30.jpg"

        @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
        @client.api.account.messages.create(
          from: ENV["TWILIO_FROM"],
          to: ENV["USER_PHONE"],
          body: "A note of Vikas",
          media_url: media
        )
      elsif slots["vikas_clue"] == "memo"
        message = "Vikas answered. Oh, I saw Meric put a memo on the fridge door. Why don't you ask him? He's in the studio."
      elsif slots["vikas_clue"] == "phone"
        message = "Vikas said. Yo, my phone is dead now. I have lost my charger since yesterday so I can't answer it."
      elsif slots["vikas_clue"] == "lunch"
        message = "Vikas replied. I will have a nice frozen chicken tikka masala. It's the taste from home. Mmmmmm"
      elsif slots["vikas_clue"] == "meric"
        message = "Vikas said. He's in the studio"
      elsif slots["vikas_clue"] == "daragh"
        message = "Vikas said. I haven't seen Daragh today. I don't know where he is."
      elsif slots["alibi_time"]
        message = "Vikas said. I went to the grocery with Ahmed this morning."
      else
        message = "Vikas is puzzled and saying. I'm sorry dude, I don't get it. What do you want to know?"
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Vikas", message )
    logger.info 'Vikas_GetTheClue processed'
  end


  on_intent("Meric_GetTheClue") do
    slots = request.intent.slots
      if slots["meric_clue"] == "memo"
        message = "Meric answered. Oh yeah, I got the weird text from someone to put the memo next to the fridge? The phone number was four one two zero. I have no idea who it was."
      elsif slots["meric_clue"] == "lunch"
        message = "Meric said. Ah I had a nice tuna sandwich and chips. You can get it from Au Bon Pain."
      elsif slots["meric_clue"] == "project"
        message = "Meric said. I'm working on the chatbot that recommends lunch places near me. Today it suggested Au Bon Pain. Ha ha."
      elsif slots["meric_clue"] == "mackenzie"
        message = "Meric told. You better speak to her. I saw that she was looking inside the fridge this morning."
      elsif slots["alibi_time"]
        message = "Meric replied. I had a meeting with Daragh about my project this morning. It went too long so I almost missed my lunch time."
      else
        message = "Meric said. Sorry I didn't get it. What was that?"
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Meric", message )
    logger.info 'Meric_GetTheClue processed'
  end


  on_intent("Mackenzie_GetTheClue") do
    slots = request.intent.slots
      if slots["mackenzie_clue"].include? "memo"
        message = "Mackenzie said. Oh wait, was that memo about your sandwich? Dang, who is that douchebag? But I didn't see anyone today."
      elsif slots["mackenzie_clue"].include? "lunch"
        message = "Mackenzie answered. Sorry to hear that you lost your sandwich. Hey, I can share my lunch with you. Hope you like turkey and cheddar sandwich."
      elsif slots["mackenzie_clue"].include? "project"
        message = "Mackenzie said. Yeah I'm having a trouble because Daragh is out of town."
      elsif slots["mackenzie_clue"].include? "dara"
        message = "Mackenzie replied. Didn't you see his message? He texted us this morning that he is stuck at the airport in Minneapolis because of the bad weather. Hope he comes back soon!"
      elsif slots["alibi_time"]
        message = "Mackenzie said. Meric and I was working on our virtual reality project. Urgh, I don't think I can make this happen in my lifetime!"
      elsif slots["mackenzie_clue"].include? "phone number" or slots["mackenzie_clue"].include? "four one two zero"
        message = "Mackenzie said. Oh, I know that. four one two zero is Vikas's phone number."
      else
        message = "Mackenzie said. Sorry I didn't get it. What was that?"
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Mackenzie", message )
    logger.info 'Mackenzie_GetTheClue processed'
  end

  on_intent("Manya_GetTheClue") do
    slots = request.intent.slots
      if slots["manya_clue"].include? "lunch"
        message = "I brought a turkey swiss sandwich with rye bread. Argh, This sucks!!"
      elsif slots["manya_clue"].include? "memo"
        message = "It must be someone in the class! Otherwise who would have known that I go to a yoga class this morning!"
      elsif slots["manya_clue"].include? "yoga class" or slots["manya_clue"].include? "schedule"
        message = "I think I told Vikas and Meric."
      elsif slots["alibi_time"]
        message = "I took a yoga class this morning and when I came back, my sandwich was already gone!"
      else
        message = "Sorry #{ENV["USERNAME"]}, I don't know about it."
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Manya", message )
    logger.info 'Mackenzie_GetTheClue processed'
  end

  on_intent("CallTheSuspect") do
    slots = request.intent.slots
    message += "You called Vikas, but the only response you could here was, I'm sorry, but the person you called is not available. The phone is off now."

  response.set_output_speech_text( message )
  response.set_simple_card("Phone Message", message )
  logger.info 'CallTheSuspect processed'

  end

  on_intent("GuessTheSuspect") do
    message = "That's great! Tell me the name of the suspect and why."
  response.set_output_speech_text( message )
  response.set_simple_card("Narrator", message )
  logger.info 'CallTheSuspect processed'

  end

  on_intent("FinalDecision") do
    if slots["suspect_name"] == "Meric"
      message = "At last, you came to Meric and said “Dude, open your backpack.” Meric was hesitated, refusing to open it.
      You took his bag from him and opened it. As expected, there is your lunchbag in there."
      media = "http://images2.onionstatic.com/onion/5665/6/original/800.jpg"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "Got back your sandwich",
        media_url: media
      )
      message += "Congrats #{ENV["USERNAME"]}, You found a thief and also saved your turkey and swiss sandwich. Great job! If you want to play the game again, say replay"
    else
      media = "https://media.giphy.com/media/xT1XGWbE0XiBDX2T8Q/giphy.gif"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "Wrong guess",
        media_url: media
      )
      message += "Poor baby, you got the wrong suspect. You lost your sandwich and also your friend. When you came back to the fridge, you saw the new message from the thief."
      media += "https://metrouk2.files.wordpress.com/2014/08/college12.png"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "Game Over",
        media_url: media
      )
      message += "Sorry #{ENV["USERNAME"]}, but this investigation ended up being a total failure. If you want to play the game again, say replay."
    end
    response.set_output_speech_text( message )
    response.set_simple_card("Narrator", message )
    logger.info 'FinalDecision processed'

  end

  on_intent("ReplayTheGame") do
    message = "Super! Tell me the name of the suspect and why."
    response.set_output_speech_text( message )
    response.set_simple_card("Narrator", message )
    logger.info 'CallTheSuspect processed'

  end
end

# def run
#   begin
#     if timeout::timeout(5) do
#
#       media += "http://i.dailymail.co.uk/i/pix/2014/08/24/article-2732898-20BE9E6A00000578-145_634x483.jpg"
#       @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
#       @client.api.account.messages.create(
#         from: ENV["TWILIO_FROM"],
#         to: ENV["USER_PHONE"],
#         body: "Time is ticking 😈",
#         media_url: media
#       )
#     end
#
#   elsif timeout::timeout(10) do
#     message = "Oh no, time is up. You lost your lunchbox forever…If you want to retry the game, say replay."
#   end
#   end
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
