# Hubot Markov Model

Generates a markov model based on everything that your Hubot sees in your
chat.

## Installing

1. Add `hubot-markov` to your `package.json`:

```json
  "dependencies": {
    "hubot-markov": "~1.3.0"
  },
```

2. Require the module in `external-scripts.json`:

```json
["hubot-markov"]
```

3. Run `npm update` and restart your Hubot.

## Commands

Saying anything at all in chat appends to the model. The robot is always
watching!

`Hubot: markov` will randomly generate text based on the current contents of
its model.

`Hubot: markov your mother is a` will generate a random phrase seeded with
the phrase you give it. This command might output "your mother is a classy
lady", for example. Remember: Hubot is an innocent soul, and what he says
only acts as a mirror for everything in your hearts.

## Configuring

The Hubot markov model can optionally be configured by two environment
variables:

`HUBOT_MARKOV_PLY` controls the *order* of the model that's built; effectively,
how many previous states (words) are considered to choose the next state. You
can bump this up if you'd like, but the default of 1 is both economical with
storage and maximally hilarious.

`HUBOT_MARKOV_LEARN_MIN` controls the minimum length of a phrase that will
be used to train the model, default 1. Set this higher to avoid training your
model with a bunch of immediate terminal transitions like "lol".

`HUBOT_MARKOV_GENERATE_MAX` controls the maximum size of a markov chain that will be
generated by the "markov" command.
