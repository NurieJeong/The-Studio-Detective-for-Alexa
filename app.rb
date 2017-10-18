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
      When entering the studio, #{ENV["USERNAME"]} heard a scream of Manya from the kitchen. Who the hell stole my sandwich? This is not funny! Manya said.
      #{ENV["USERNAME"]} ran into the kitchen and saw Manya. She looked very angry and pointed to the fridge.
      On the door of the fridge, #{ENV["USERNAME"]} could only see a note inside the fridge. It must be the note from the lunch box thief! #{ENV["USERNAME"]} thought.
      As a dear friend of her, #{ENV["USERNAME"]} decided to help and said. Don't worry Manya, I will help you get back your lunch.
      From now on, you, as detective, should investigate the case within 10 minutes. You can either look around the kitchen, the studio and the classroom.
      If you want to start invstigation, make sure to start speaking. Alexa tell the detective. For example, when you want to look around the kitchen,
      say. Alexa, tell the detective let's go to the kitchen."

    media = "https://www.ndtv.com/news/2_BIcBdVI.jpg"

    @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    @client.api.account.messages.create(
      from: ENV["TWILIO_FROM"],
      to: ENV["USER_PHONE"],
      body: "A message from the lunchbox thief",
      media_url: media
    )

    response.set_output_speech_text( message )
    response.set_simple_card("Narrator", message )
    logger.info 'StartTheGame processed'
  end

  on_intent("MoveThePlace") do
    slots = request.intent.slots

    if slots["investigation_place"].include? "kitchen"
      message = "There are two people, Vikas and Manya, are wondering around the kitchen. Vikas is heating his microwave lunch and Manya seems so pissed.
                You can either talk with them or move to another place. By the way, when you talk to the suspects, make sure to speak their name first."
    elsif slots["investigation_place"].include? "studio"
      message = "At the entrance of the studio, you found a note.
                There is one person, Meric, is working on something. You can chat with them, or move to another place."
      media = "https://i2.wp.com/www.thebibliophilegirluk.com/wp-content/uploads/img_2142.png?resize=600%2C576"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "The first clue",
        media_url: media
      )

    elsif slots["investigation_place"].include? "classroom"
      message = "When you enter the classroom, you saw a message from Dara’s TA in the white board. You are not sure where Dara is right now.
                In the classroom, there is Mackenzie watching Moana. You can talk to her, or move to another place."
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
        if slots["initiate_talk"] == "vikas"
          message = "Vikas answered, yo unni, what's up?"
        elsif slots["initiate_talk"] == "meric"
          message = "Meric answered, yo, what do you want from me?"
        elsif slots["initiate_talk"] == "mackenzie"
          message = "Makenzie answered, hey #{ENV["USERNAME"]} what are you up to?"
        elsif slots["initiate_talk"] == "manya"
          message = "Manya answered, Hey, thanks so much for your help. What do you want to know?"
        else
          message = "#{slots["initiate_talk"]} doesn't seem to want to talk right now. "
        end
      response.set_output_speech_text( message )
      response.set_simple_card("Narrator", message )
      logger.info 'TalkToSuspect processed'
    end


  on_intent("Vikas_GetTheClue") do
    slots = request.intent.slots

      if slots["vikas_clue"] == "memo"
        message = "Vikas answered. Oh, I saw Meric put a memo on the fridge door. Why don't you ask him? He's in the studio."
      elsif slots["vikas_clue"] == "phone"
        message = "Vikas said. Yo, my phone is dead now. I have lost my charger since yesterday so I can't answer it."
      elsif slots["vikas_clue"] == "lunch"
        message = "Vikas replied. I will have a nice frozen chicken tikka masala. Dude, this is so authentic. Taste from home. Mmmmmm"
        media = "https://thismanskitchen.files.wordpress.com/2010/08/tikka.jpg"

        @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
        @client.api.account.messages.create(
          from: ENV["TWILIO_FROM"],
          to: ENV["USER_PHONE"],
          body: "Vikas's lunch",
          media_url: media
        )

      elsif slots["vikas_clue"] == "meric"
        message = "Vikas said. I think he's in the studio"
      elsif slots["vikas_clue"] == "dara"
        message = "Vikas said. I haven't seen Dara today. I don't know where he is."
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
        message = "Meric answered, Oh yeah, I got the weird text from someone to put the memo next to the fridge. The phone number was four one two zero.
        I have no idea who it was."
      elsif slots["meric_clue"] == "lunch"
        message = "Meric said, Ah, I had a nice tuna sandwich and chips. You can get it from Au Bon Pain."
      elsif slots["meric_clue"] == "project"
        message = "Meric said, I'm working on the chatbot that recommends lunch places near me. Today it suggested Au Bon Pain. Cool cool cool."
      elsif slots["meric_clue"] == "mackenzie"
        message = "Meric told, You better speak to her. I saw that she was looking inside the fridge this morning. She's in the classroom right now."
      elsif slots["alibi_time"]
        message = "Meric replied, I had a meeting with Dara about my project this morning. It went too long so I almost missed my lunch time."
      elsif slots["meric_clue"] == "dara"
        message = "Meric answered, Dara is in his office. I saw that he got a new pocket square. I wonder how many he has. Ha ha."
      else
        message = "Meric said, Sorry I didn't get it. What was that?"
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Meric", message )
    logger.info 'Meric_GetTheClue processed'
  end


  on_intent("Mackenzie_GetTheClue") do
    slots = request.intent.slots
      if slots["mackenzie_clue"].include? "memo"
        message = "Mackenzie said, Oh wait, was that memo about Manya's sandwich? Got dammit, who is that bastard?
                  I went to the kitchen this morning, but by the time when I got there, the thief was gone already. Sorry I can't help."
      elsif slots["mackenzie_clue"].include? "lunch"
        message = "Mackenzie showed her lunch bag and said, I brought a turkey and cheddar sandwich. Trust me, I'm not the thief!"
        media = "http://3.bp.blogspot.com/-PAlvM0-BN-8/UG1ty6d3prI/AAAAAAAAWYY/E4BScYdCmIg/s1600/arbys_turkey_n_cheddar_02.JPG"

        @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
        @client.api.account.messages.create(
          from: ENV["TWILIO_FROM"],
          to: ENV["USER_PHONE"],
          body: "A message from the lunchbox thief",
          media_url: media
        )

      elsif slots["mackenzie_clue"].include? "moana"
        message = "Mackenzie said, Oh my god, this is the best Disney movie ever! Oops, Sorry, I'm procrastinating everything because I'm stuck at my chatbot project and Dara is out of town."
      elsif slots["mackenzie_clue"].include? "dara"
        message = "Mackenzie replied. Hey, didn't you see his message? He texted us this morning that he is stuck at the airport in Minneapolis because of the bad weather. Hope he comes back soon!"
        media = "https://www.dropbox.com/s/22zbbxjioyxj37f/Screen%20Shot%202017-10-18%20at%2011.07.35%20AM.png?dl=0"

        @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
        @client.api.account.messages.create(
          from: ENV["TWILIO_FROM"],
          to: ENV["USER_PHONE"],
          body: "Mackenzie's lunch",
          media_url: media
        )

      elsif slots["alibi_time"]
        message = "Mackenzie said, I was grading my students' posters. Urgh, this is endless!"
      elsif slots["mackenzie_clue"].include? "phone number" or slots["mackenzie_clue"].include? "four one two zero"
        message = "Mackenzie said, Wait, I know that number. four one two zero is Vikas's phone number."
      else
        message = "Mackenzie said, Sorry I didn't get it. What was that?"
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Mackenzie", message )
    logger.info 'Mackenzie_GetTheClue processed'
  end

  on_intent("Manya_GetTheClue") do
    slots = request.intent.slots
      if slots["manya_clue"].include? "lunch"
        message = "Manya said, I brought a turkey swiss sandwich with rye bread. Argh, This sucks!!"
      elsif slots["manya_clue"].include? "memo"
        message = "Manya shouted, It must be someone in the class! Otherwise who would have known that I go to a yoga class this morning!"
      elsif slots["manya_clue"].include? "yoga class" or slots["manya_clue"].include? "schedule"
        message = "Manya answered, I think I told Vikas and Meric."
      elsif slots["alibi_time"]
        message = "Manya replied, I took a yoga class this morning and when I came back, my sandwich was already gone!"
      else
        message = "Manya said, Sorry #{ENV["USERNAME"]}, I don't know about it."
      end
    response.set_output_speech_text( message )
    response.set_simple_card("Manya", message )
    logger.info 'Manya_GetTheClue processed'
  end

  on_intent("CallTheSuspect") do
    message = "You called Vikas, but the only response you could here was, I'm sorry, but the person you called is not available. The phone is off now."
  response.set_output_speech_text( message )
  response.set_simple_card("Phone Message", message )
  logger.info 'CallTheSuspect processed'

  end

  on_intent("GuessTheSuspect") do
    message = "That's great! Tell me the name of the suspect and why."
  response.set_output_speech_text( message )
  response.set_simple_card("Narrator", message )
  logger.info 'GuessTheSuspect processed'

  end

  on_intent("FinalDecision") do
    if slots["final_call"].include? "Meric" && if slots["reason"]
      message = "At last, you came to Meric and said “Dude, open your backpack.” Meric hesitated, refusing to open it.
      You took his bag from him and opened it. As expected, there is your lunchbag in there.
      Meric said, guys it's just a prank, but how did you know that it was me?
      #{ENV["USERNAME"]} said, that was too easy, man! Because you are so bad at lying.
      Congrats #{ENV["USERNAME"]}, You found a thief and also saved Manya's turkey swiss sandwich.
      Great job! If you want to play the game again, say replay"
      media = "http://images2.onionstatic.com/onion/5665/6/original/800.jpg"

      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["USER_PHONE"],
        body: "Got back your sandwich",
        media_url: media
      )

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
    message = "Are you sure you want to start over again?"

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
