// Written in the D programming language.

/*
 * ------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 16.11.2013
 * License. "THE BEER-WARE LICENSE"; $(WEB http://people.freebsd.org/~phk/)
 * ------------------------------------------------------------------------
 */

/*
 * A type that represents a Sudoku (Japanese Game) $(WEB http://de.wikipedia.org/wiki/Sudoku)
 */

module sudoku;

import std.stdio : write, writeln, readln; 
import std.file : exists, isFile, readText, append;
import std.string : chomp, split, format;
import std.conv : to;

struct Sudoku {

	/**
	 Returns the height of the Sudoku.
	*/
	@property int height() const pure
	{
		return Sudoku.sudokuHeight;
	}
	
	unittest {
		Sudoku s;
		assert( s.height == Sudoku.sudokuHeight );
		assert( s.height == 9 );
	}

	/**
	 Returns the width of the Sudoku.
	*/
	@property int width() const pure
	{
		return Sudoku.sudokuWidth;
	}

	unittest {
		Sudoku s;
		assert( s.width == Sudoku.sudokuWidth );
		assert( s.width == 9 );
	}

	
	/**
	 Initializes the Sudoku with an empty Sudoku.
	*/
	@property void reset() {
		this =  Sudoku();
	}

	unittest {
		Sudoku s;
		s[0, 0] = 1;
		s[0, 1] = 2;
		s[0, 2] = 3;
		s[0, 3] = 4;

		s.reset;

		assert( s == Sudoku() );
	}

	/**
	 Returns the string-representation of a sudoku-object
	*/
	string toString() const {

		string str;

		string zeroString = ". ";
		string pipe = "| ";
		string seperate = "-";

		foreach( row; 0..height() ) {
			if( row % 3 == 0 && row != 0 ) {
				foreach( col; 0..height() * 2 + 3 ) {
					str ~= seperate;
				}
				str ~= "\n";
			}

			foreach( col; 0..width() ) {
				auto val = this[row, col];
			
				if( col == 0 ) {
					if( val == 0 ) str ~= zeroString;
					else str ~= format( "%s ", val );
				} else if( col % 3 == 0 ) {
					str ~= pipe;
					if( val == 0 ) str ~= zeroString;
					else str ~= format( "%s ", val );
				} else {
					if( val == 0 ) str ~= zeroString;
					else str ~= format( "%s ", val );
				}

			}
			str ~= "\n";
		}

		return str;
	}

	/**
	 Returns the value at the specified index.
	*/
	int opCall( in int index ) const pure
	in {
		assert( index >= 0 && index < 81 );
	}
	body {
		return _board[ index / height ][ index % width ];
	}

	unittest {
		Sudoku s;

		s[ 8, 8 ] = 9;

		assert( s(80) == 9 );
	}

	/**
	 Returns the value at the specified row and column.
   	*/
	int opIndex( in int row, in int col ) const pure
	in {
		assert( row >= 0 && row < height );
		assert( col >= 0 && col < width );
	}
	body {
		return _board[row][col];
	}

	unittest {
		Sudoku s;

		s[ 0, 0 ] = 5;

		assert( s[ 0, 0 ] == 5 );
	}

	/**
	 Sets the given value at the specified row and column.
	*/
	void opIndexAssign( in int val, in int row, in int col )
	in {
		assert( row >= 0 && row < height );	
		assert( col >= 0 && col < width );
		assert( val >= -9 && val <= 9 );
	}
	body {
		_board[row][col] = val;
	}
	
	unittest {
		Sudoku s;

		s[ 5, 0 ] = 5;

		assert( s[ 5, 0 ] == 5 );
	}	

	/**
	 Turns the sign of every positive value of the given Sudoku.
	*/	
	ref Sudoku opUnary( string op )() if( op == "-" )
	{
		foreach( row; 0..height ) {
			foreach( col; 0..width ) {
				if( this[ row, col ] > 0 ) {
					this[ row, col ] = -this[ row, col ];
				}
			}
		}
		return this;
	}

	/**
	 Turns the sign of every negative value of the given Sudoku.
	*/
	ref Sudoku opUnary( string op )() if( op == "+" )
	{
		foreach( row; 0..height ) {
			foreach( col; 0..width ) {
				if( this[ row, col ] < 0 ) {
					this[ row, col ] = -this[ row, col ];
				}
			}
		}
		return this;
	}

	unittest {
		Sudoku s;

		s[ 0, 0 ] = 5;
		s = -s;

		assert( s[ 0, 0 ] == -5 );	

		s = +s;
		assert( s[0, 0] == 5 );

	}

	/**
	 Returns true if the specified Value is already used in the specified Row/Column/Grid, and false otherwise.
	*/
	bool opBinaryRight( string op )( int[] lhs ) const pure if( op == "in" ) 
	in {
		assert( lhs.length > 2 );
	}
	body {
		int val = lhs[0];
		int startR = lhs[1] / 3 * 3;
		int startC = lhs[2] / 3 * 3;
		
		foreach( row; 0..height ) {
			foreach( col; 0..width ) {
				if( this[ startR, col ] == val || this[ row, startC ] == val )
					return true;
			}
		}

		foreach( row; 0..3 ) {
			foreach( col; 0..3 ) {
				if( this[ startR + row, startC + col ] == val )
					return true;
			}
		}
		
		return false;

	}

	unittest {
		Sudoku s;

		s[ 0, 0 ] = 4;
		assert( [ 4, 0, 0 ] in s );

	}

	/**
	 Returns the Multidimensional-Integer-Array-representation of a Sudoku.
	*/
	int[sudokuHeight][sudokuWidth] opConv( T : int[sudokuHeight][sudokuWidth] )() const pure
	{
		return _board;
	}

	unittest {
		Sudoku s;
	
		s[ 0, 0 ] = 4;

		int[sudokuHeight][sudokuWidth] board = cast(int[sudokuHeight][sudokuWidth])(s);

		assert( board[0][0] == 4 );

	}

	/**
	 This is D's approach for default-constructors inside Stucts.
	 It is used like this:
		Sudoku s = Sudoku();
	*/
	static Sudoku opCall()
	{
		Sudoku s;
		return s;
	}


        /**
         Tries to create a Sudoku from the Input-File "filename"
        */
        static Sudoku createByFile( in string filename ) {
                Sudoku s;

                int cur;

                if( exists( filename ) && filename.isFile ) {
                        string[] vals = split( readText!(string)( filename) );

                                foreach( row; 0..Sudoku.sudokuWidth ) {
                                        foreach( col; 0..Sudoku.sudokuHeight ) {
                                                s[row, col] = to!(int)(vals[cur]);
                                                ++cur;
                                        }
                                }
                }
                return s;
        }

	/**
	 Writes the given Sudoku to the file, called filename.
	*/
        static toFile( Sudoku s, in string filename )
        {
                foreach( row; 0..s.height ) {
                        foreach( col; 0..s.width ) {
                                append( filename, format( "%s ", s[row, col] ) );         
                        }
                                append( filename, "\n" );
                }
        }

	static enum endInput = "END";
	static enum sudokuHeight = 9;
	static enum sudokuWidth = 9;
	static enum defaultValue = 0;
	static enum totalValueAmount = sudokuHeight * sudokuWidth;

	private int[sudokuHeight][sudokuWidth] _board;
}
