

 * 26 external user IOs pins :

   - 10 dedicated inputs
   -  8 dedicated outputs
   -  8 bidirectional IOs

   Results in :

   - 18 input  lines on user module:
     . 10 from dedicated inputs
     .  8 from bidir
  
   - 24 output lines on user module
     . 8 data to dedicated outputs
     . 8 data to bidir
     . 8 enables for bidir

   - So 42 pins on the user module
     . Need to find a way to force order / position so we can match
       them to get straight / direct wiring

   Rationale:

   - Having bidir IOs is great for QSPI for instance, or I2C
     Don't want to go overboard (3 lines per bidir IO) so 8
     seemed not a bad compromise

   - 2 more inputs for user clk/rst
     While they are not treated different internally I thought it
     would be useful to just have 2 more lines.


 * Input path ( Controller -> User module ) :

   - Distribution tree

     . Equal number of buffers from root to each module

     . Each stage is a AND gate so we can disable inactive
       branches

     . Disabled modules are guaranteed to have '0' as input
       ( so prefer active low reset !!! ). This means there
       is a buffer right before each user module.

   - Try to match routing between the different lines.

     . If space allows, include guard traces to better match
       the parasitics between each input path

     . Different modules might still get different routing length
       though, so no matching between modules )

   - Probably a vertical "spine" with horizontal branches


 * Output path ( User module -> Controller ) :

   - Using TBUFs

     . Might experiment with a first stage of MUX4 and see in the timing
       how this affect things

     . Output of inactive modules should have no influence on the final
       output (i.e. no assumptions on what the user module outputs)


   - Probably a vertical "spine" with horizontal branches


 * External config :

   - The only function provided by the controller is selecting the active
     design. So no internal clock gen, or reset gen or anything like that.
     Theses are assumed to be provided externally.

   - Config interface is a simple 'rst' / 'inc' 2 wire interface to select the
     active design. (i.e. pulse reset then send 200 pulses to enable design
     #200 for instance).

   - All internal enable signals will be combinatorially derived from the
     selected instance ID. (but still inactive until the 'global enable' line
     is set, see below)

   - External 'global enable' line is also provided to actually enable the
     design when ready


 * Design grids :

    - Let call the 'base' (smallest) design dimensions H x W.
      
      Designs can be 1H or 2H in height
      Designs can be 1W, 2W or 4W in width.

      This should provide between 1x up to 8x the area while still making
      it easy to keep alignement to a grid and keep "routing" lanes clear.

    - Grid size would be something like :

      . 16 designs wide
        (8 left and 8 right of the vertical "spine")

      . 24 designs tall
        (2*12 'distribution blocks')

    - See attached pdf


 * Other :

   - Provide an "enable" signal to the module which tells it if it's the
     active module or not

   - Outside of the controller, but I would have wire `user_clk` and
     `user_clk2` to two IOs, along with a few IOs configured to be GPIO of the
     mgmt core.

     This way if the caravel works fine, we 'jumper' those externaly to the
     pins needed to drive/control the user designs and not require an external
     control uC.
