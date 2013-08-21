Multiplayer shooting platformer with destructible terrain
=========================================================


## Todo
- Two guns
   - One's bullet creates blocks when you fire it
   - One's bullets destroy blocks when you fire it
      - Add a contact listener to the bullet
      - Have the normal and collision place, and actual colliding objects?
- Map creation
    - Create initial random map from perlin noise
        - Grid size: 1 meter each
    - Make each block a shape in one body
        - I want to be able to destroy and create individual blocks
- Player movements and actions
    - Player is one body/shape
    - Can move left/right
    - Can jump from ground
    - Is looking at a place
    - Can shoot
- Player body
    - Body, head (head angles)
    - Legs?
        - Actually walking?
    - Arms? 
    - Jointed?
    - Gun?
        - Gun should angle along with head
        - Located in front of you (held by your hands)
- Game loop
    - Look at input state
    - Take actions according to state
        - Move or jump method calls
        - Set looking

### Supporting
- <s>Write code in coffeescript and auto-compile to public/</s>
    - <s>(delete old .js files when their .coffee gets removed)</s>
- <s>watched updating (recompile coffee automatically when it changes)</s>
    - <s>only recompile the file that was changed</s>
- <s>Auto-refreshing of page when coffee files change</s>
- Generic task for development: start server, compile, watch

Contact: hellocharlien@hotmail.com

