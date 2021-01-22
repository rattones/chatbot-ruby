require 'socket'
require 'logger'

Thread.abort_on_exception

class Twitch
  attr_reader :logger, :running, :socket

  def initialize(logger= nil)
    @logger= logger || Logger.new(STDOUT)

    @running= false
    @socket= nil 
  end

  def send(message)
    logger.info "< #{message}"
    socket.puts("PRIVMSG #rattones :#{message}")
  end

  def run
    logger.info 'conectando ...'

    @socket= TCPSocket.new('irc.chat.twitch.tv', 6667)
    @running= true
    
    socket.puts("PASS twitch-token")
    socket.puts("NICK Ratto_Bot")

    logger.info 'conectado'

    socket.puts('JOIN #rattones')
    
    Thread.start do
      while (running)
        ready = IO.select([socket])
    
        ready[0].each do |s|
          line= s.gets.chomp
          match= line.match(/:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
          message= match && match[4]
          user= match && match[1]

          if message =~ /^!ola/
            logger.info "> user command: #{user} !ola"
            send "Ola #{user}! Tudo bem com você? Como foi seu dia?"
          else 
            logger.info message.inspect
          end

          logger.info "> #{line}"
        end
      end
    end
  end

  def stop
    @running= false
    logger.info 'obrigado.'
  end
end

bot= Twitch.new
bot.run

while (bot.running) do
  command = gets.chomp

  if command == ':sair'
    bot.stop
  else 
    bot.send(command)
  end
end

puts 'saiu'