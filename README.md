Multiplayer shooting platformer with destructible terrain
=========================================================

## How to run in dev?

    1. git clone
    2. npm install
    2. npm install -g grunt-cli
    2. grunt

Visit [localhost:3000](localhost:3000)

Any changes you make to .coffee files will be automatically compiled by grunt and your browser will auto-refresh.



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
    - Perhaps just a collection of blocks
        killing all the blocks kills the player
        or perhaps there's a "heart" block that you must destroy
- Game loop
    1. Look at input state
    1. Take actions according to state
        - Move or jump method calls
        - Set looking
        - set other features needed for rendering
    - (wait for input from other players)
    - "pre"-b2world-step: apply forces, etc.
    - b2world step
    - post-b2world-step: calculate vision, etc.
    - render here
- fog of war
    - explicit line of sight
    - "remember" the last time you saw blocks
    - see all blocks being created/destroyed, but only fog of war players?
    - pixel perfect masking of the visible poly?
        - you should definitely be able to see the layout in general
        - even if you can't see *directly* into the blocks, it should show them at least some
- rendering
    - shader to make blocks look interesting
    - masking the visible area

## style
- visual style
    - cave environment
    - parallax procedurally generated backgrounds
    - blues, dark colors, some whites/grays
    - ![](http://blog.frogatto.com/wp-content/uploads/2010/03/cave-background-demo.png)Background has good gradients
    - ![](http://ramnation.files.wordpress.com/2011/01/cave-interior-layout-design-entrance-nb.jpg)
    - ![](http://fc06.deviantart.net/fs70/f/2012/354/7/1/ice_cave_by_tatchit-d55zi1g.png)
    - ![](http://4.bp.blogspot.com/-ZQRlnDSXDY0/Uazxv1a495I/AAAAAAAAAbI/AQGQ3CXqJOg/s640/ice+cave2.jpg)
    - ![](http://www.blackorchard.co.uk/img/aggro_cave4c.jpg)
    - ![](http://static.gamesradar.com/images/mb/GamesRadar/us/Features/2009/12/Sonic%20and%20Mario%20rereviewed/Cave%206--article_image.jpg)
- more realistic, sharp distinctions between objects
- simplistic looking graphics; no toonish looking shit
- shouldn't be obvious textures are being used
    - that is, make it look like something generative

## bugs

### Supporting
- Reload on requireConfig change
- reload when app.js changes

Contact: hellocharlien@hotmail.com

