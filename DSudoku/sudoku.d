// Written in the D programming language.

/*
 * ------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 12.11.2013
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
import std.math : abs;

struct Sudoku {

	/**
	 Returns the _field Array of the Sudoku.
	*/
	@property int[sudokuHeight][sudokuWidth] field() pure
	{ 
		return _field;
	}


	/**
         Replaces the value of _field with field.
	*/
	@property void field( in int[sudokuHeight][sudokuWidth] field ) 
	{
		_field = field;
	}

	/**
	 Returns the value of _field at the position specified at the input.
	*/
	int get( in int r, in int c ) const pure 
	in {
		assert( r >= 0 && r < Sudoku.sudokuHeight );
		assert( c >= 0 && c < Sudoku.sudokuWidth );
	}
	body {
		return _field[r][c];
	}


	/**
	 Replaces the Value of _field at the Position specified at the input, with val (input as well).
	*/
	void set( in int val, in int r, in int c )  
	in {
		assert( r >= 0 && r < Sudoku.sudokuHeight );
		assert( c >= 0 && c < Sudoku.sudokuWidth );
		assert( abs( val ) <= 9 );
	}
	body {
		_field[r][c] = val;
	}

	/**
	 Returns the height of the Sudoku.
	*/
	@property int height() pure
	{
		return Sudoku.sudokuHeight;
	}

	/**
	 Returns the width of the Sudoku.
	*/
	@property int width() pure
	{
		return Sudoku.sudokuWidth;
	}

	/**
	 Prints the Sudoku from the input.
	*/
	static void print( in Sudoku s ) {
		foreach( i; 0..Sudoku.sudokuHeight ) {
			if( i % 3 == 0 && i != 0 ) {
				foreach( l; 0..Sudoku.sudokuHeight * 2 + 1 ) {
					write( "-" );
				}
				writeln();
			}

			foreach( j; 0..Sudoku.sudokuHeight ) {
				auto val = s.get( i, j );
				
				if( j == 0 ) {
					if( val == 0 ) write( ". " );
					else write( val, " " );
				} else if( j % 3 == 0 ) {
					write( "|" );
					if( val == 0 ) write( ". " );
					else write( val, " " );
				} else {
					if( val == 0 ) write( ". " );
					else write( val, " " );
				}
			}
			writeln();
		}
	}

	/**
	 Tries to create a Sudoku from the Input-File "filename"
	*/
	static Sudoku createByFile( in string filename ) {
		Sudoku s;

		int r, c;
		int cur;

		if( exists( filename ) && filename.isFile ) {
			string[] vals = split( readText!(string)( filename) );

				foreach( i; 0..Sudoku.sudokuWidth ) {
					foreach( j; 0..Sudoku.sudokuHeight ) {
						s.set( to!(int)(vals[cur]), i, j);
						++cur;
					}
				}
		}
		return s;
	}

	/**
	 Tries to create a Sudoku by the User-Input.
	 */
	static Sudoku createByInput()
	{
		Sudoku s;

		foreach( row; 0..s.height ) {
			foreach( col; 0..s.width ) {
				write("Value: [", row+1, "|", col+1, "]: " );

				string str = chomp( readln() );
				if( str == Sudoku.endInput ) return s;
				else s.set( to!int(str), row, col );				
				writeln();
			}
		}

		return s;
	}

	static toFile( Sudoku s, string filename ) 
	{
		foreach( row; 0..s.height ) {
			foreach( col; 0..s.width ) {
				append( filename, format( "%s ", s.get( row, col ) ) );		
			}
				append( filename, "\n" );
		}
	}

	static enum endInput = "END";
	static enum sudokuHeight = 9;
	static enum sudokuWidth = 9;

	private int[sudokuHeight][sudokuWidth] _field;
}
