// Written in the D programming language. $(WEB: http://www.dlang.org)

/*
 * ------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 24.11.2013
 * License: "THE BEER-WARE LICENSE"; $(WEB: http://people.freebsd.org/~phk/)
 * ------------------------------------------------------------------------
 */

module solver;

import sudoku;
import utils;

import std.random : uniform;


/**
 Inserts all possible values for the Sudoku s, beginning at the specified Coordinate.
*/
bool insert( ref Sudoku s, in Point start, in bool randomized )
{
	insert( s, start.y, start.x, randomized );
}

/**
 Inserts all possible values for the Sudoku s, beginning at the specified Row/Column.
*/
bool insert( ref Sudoku s, in int startR, in int startC, in bool randomized = false)
in {
	assert( startR >= 0 && startR <= s.height );
	assert( startC >= 0 && startC <= s.width );
}
body {
	int[] poss;
	int r = startR + 1;
	int c = startC;

	if( s[ startR, startC ] == Sudoku.defaultValue ) {
		poss = getPossible( s, startR, startC );

		if( poss.length == 0 ) return false;

		if( randomized ) {
			s[ startR, startC ] = poss[ cast(int)uniform( 0, poss.length ) ];
		} else {
			s[ startR, startC ] = poss[0];
		}
	}	

	if( r >= s.height ) {
		r = 0;
		c++;	
	}

	if( c >= s.width ) {
		return true;
	}
	
	while( !insert( s, r, c ) ) {
		if( poss is null ) return false;
		else {
			poss = poss[1..$];

			if( poss.length == 0 ) {
				s[ startR, startC ] = Sudoku.defaultValue;
				return false;
			}
			
			if( randomized ) {
				s[ startR, startC ] = poss[ cast(int)uniform( 0, poss.length ) ];
			} else {
				s[ startR, startC ] = poss[0];
			}
		}
	}
	return true;
}

/**
 Tries to solve the Sudoku from the beginning.
 Returns false, if the algorithm can't solve it and true if the Sudoku was solved by the algorithm.
*/
bool solve( ref Sudoku s, in bool randomized = false )
{
	s = -s;

	if( !isSolvable( s ) ) {
		s = +s;
		return false;
	}

	auto solved = insert( s, 0, 0, randomized );
	s = +s;
	return solved;
}





