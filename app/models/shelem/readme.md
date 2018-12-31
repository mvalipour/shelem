## Structure

- Match
  - many: Game
    - bidding
    - trumping
    - playing

### Match

A match is a series of games between two teams (2 players each)

Inputs:
- 2 Teams -- 2 players each

Outputs:
- Scores

State:
- Next bid starter -- the player to start the next bidding (rota)
- Scores (for each team)

-- scores are collective scores of all games played

### Game

A game is a round of Shelem.

Inputs:
- Bid amount
- Bid winner

Output:
- Scores

State:
- Player hands
- Current score
- Game suit
- Round lead
- Round suit
- Round cards

Scoring rules:
- If the bidding team wins at least score of bid amount, they get their score
- Otherwise they get minus the bidding amount

### Bidding

Bidding is the process that runs before each game.  
This goes in round and each player either raises the previous bid
or passes (once passed a player cannot bid again). Once all the players passed the player with higher bid becomes the game lead.

Rules:

- Minimum bid: 100
- Minimum raise: 5
- Maximum bid (higher score a.k.a Shelem): 165

Inputs:
- Bid starter

Outputs:
- Bid winner
- Bid amount

### Trumping

Player with winning bid, takes 4 widow cards and swaps as they please to make
up their best hand of 12 cards for the game.
