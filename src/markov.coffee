# Description:
#   Build a markov model based on everything that Hubot sees. Construct markov
#   chains based on its accumulated history on demand, to produce plausible-
#   sounding and occasionally hilarious nonsense.
#
#   While this is written to support any order of markov model, extensive
#   experimentation has shown that order 1 produces the most funny. Higher-
#   order models occupy a *lot* more storage space and frequently produce
#   exact quotes.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MARKOV_PLY - Order of the markov model to build. Default: 1
#   HUBOT_MARKOV_LEARN_MIN - Minimum number of tokens to use in training. Default: 1
#   HUBOT_MARKOV_GENERATE_MAX - Maximum number of tokens in a generated chain. Default: 50
#
# Commands:
#   hubot markov <seed> - Generate a markov chain, optionally seeded with the provided phrase.
#
# Author:
#   smashwilson

Url = require 'url'
Redis = require 'redis'

MarkovModel = require './model'
RedisStorage = require './redis-storage'

String::capitalize = ->
  @substr(0, 1).toUpperCase() + @substr(1)
  
String::strip = -> 
  if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

module.exports = (robot) ->

  # Configure redis the same way that redis-brain does.
  info = Url.parse process.env.REDISTOGO_URL or
    process.env.REDISCLOUD_URL or
    process.env.BOXEN_REDIS_URL or
    process.env.REDIS_URL or
    'redis://localhost:6379'
  client = Redis.createClient(info.port, info.hostname)

  if info.auth
    client.auth info.auth.split(":")[1]

  storage = new RedisStorage(client)

  # Read markov-specific configuration from the environment.
  ply = process.env.HUBOT_MARKOV_PLY or 1
  min = process.env.HUBOT_MARKOV_LEARN_MIN or 1
  max = process.env.HUBOT_MARKOV_GENERATE_MAX or 50

  model = new MarkovModel(storage, ply, min)

  # The robot hears ALL. You cannot run.
  robot.catchAll (msg) ->

    # Return on empty messages
    return if !msg.message.text
    
    # Return on empty users
    return if !msg.message.user.name
    
    userName = msg.message.user.name.toLowerCase()
    
    # Return on ignored users
    ignoredUsers = []
    if process.env.HUBOT_MARKOV_IGNORED_USERS?
      console.log process.env.HUBOT_MARKOV_IGNORED_USERS
      ignoredUsers = process.env.HUBOT_MARKOV_IGNORED_USERS.split ","
    
    return if userName in ignoredUsers
    
    # Extract text (not robot name)
    #re = new RegExp("(" + robot.name + "\s)?(.+)","i")
    learnText = msg.message.text.match ///( #{robot.name} \s)?(.+)///i
    model.learn userName, learnText[2]

  # Generate markov chains on demand, optionally seeded by some initial state.
  robot.hear /(markov|marakov|mrkv)\s+(\S+\s?)(.+)?$/i, (msg) ->
    userName = msg.match[2].toLowerCase().strip()
    if userName is 'me'
      userName = msg.message.user.name.toLowerCase().strip()
    else if userName is 'mumbot'
      return;
    
    seedText = msg.match[3] or ''
    model.generate userName, seedText, max, (text) =>
      msg.send text.capitalize()
