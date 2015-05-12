##
# Unbuffered input in Ruby.
#
# @see http://blog.x-aeon.com/2014/03/26/how-to-read-one-non-blocking-key-press-in-ruby/
# @see http://stackoverflow.com/a/14527475/1095946
#
module Buffy
  @stty = begin
            require 'Win32API'
            false
          rescue LoadError
            true
          end

  ##
  # Get the integer value of a character from STDIN.
  #
  # In *nix mode, this method will:
  #
  # - Save stty state
  # - Set stty to:
  #     - raw mode
  #     - no echo
  #     - disable canonical input (ERASE and KILL processing)
  #     - enable the checking of characters against the special control
  #       characters INTR, QUIT, and SUSP
  # - Get and return a character from STDIN
  # - Ensure the stty state is reset
  #
  # In Windows mode, this method will:
  #
  # - Check for input using crtdll's _kbhit
  # - Return ctrdll's _getch
  # - Return nil if no input found
  #
  def self.getch
    if stty?
      state = `stty -g`.chomp
      system 'stty raw -echo -icanon isig'
      STDIN.getc.ord
    else
      Win32API.new('crtdll', '_getch', [], 'L').Call unless Win32API.new('crtdll', '_kbhit', [], 'I').Call.zero?
    end
  ensure
    system 'stty', *state.split if stty? # Reset terminal mode
  end

  private

  ##
  # Are we using *nix?
  #
  def self.stty?
    @stty
  end
end
