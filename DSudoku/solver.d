// Written in the D programming language. $(WEB: http://www.dlang.org)

/*
 * ------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 12.11.2013
 * License: "THE BEER-WARE LICENSE"; $(WEB: http://people.freebsd.org/~phk/)
 * ------------------------------------------------------------------------
 */

module solver;

import sudoku;

import std.math : abs ;

alias HEIGHT = Sudoku.sudokuHeight;
alias WIDTH = Sudoku.sudokuWidth;

immutable defaultVal = 0;

	version( unittest ) 
	{
		immutable int[] sudokuVals = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
	}

/**
 Removes an int (called v) from another array of ints (called arr) and returns the resulting array.
*/
int[] remove( in int[] arr, in int val ) pure
out( result ) {
	assert( result.length <= arr.length );
}
body {

	int[] tmp;

	foreach( element; arr ) {
		if( element != val ) {
			tmp ~= element;
		}
	}

	return tmp;
}


unittest {
	int[] arr = sudokuVals.dup;
	int val = 5;

	assert( remove( arr, val ) == [ 1, 2, 3, 4, 6, 7, 8, 9 ] );
	assert( remove( arr, val ).length == 8 );
}

/**
 Returns true if the Array of ints arr contains another int called val.
 If arr doesn't contain val, it returns false.
*/
bool contains( in int[] arr, in int val ) pure 
{
	
	foreach( element; arr ) {
		if( element == val ) {
			return true;
		}
	}

	return false;
}

unittest {
	int[] arr = sudokuVals.dup;
	int val = 5;

	assert( contains( arr, val ) );
	assert( !contains( arr, 10 ) );
}

/**
 Returns an Array of ints containing all possible values for the Sudoku s in the row r and the column c.
*/
int[] getPossible( in Sudoku s, in int r, in int c ) pure 
in {
	assert( r >= 0 && r < HEIGHT );
	assert( c >= 0 && c < WIDTH );
}
out( result ) {
	assert( result.length <= 9 );
}
body {
	int[] buf = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];

	foreach( i; 0..HEIGHT ) {
				buf = remove( buf, abs( s.get( r, i ) ) );
				buf = remove( buf, abs( s.get( i, c ) ) );
	}

	foreach( i; 0..3 ) {
		foreach( j; 0..3 ) {
				buf = remove( buf, abs( s.get( i + (c / 3 * 3), j + (r / 3 * 3) ) ) );		
		}
	}

	return buf;
}

unittest {

	Sudoku s;

	assert( getPossible(s, 0, 0 ) == sudokuVals );
	assert( getPossible( s, 0, 0).length == 9 );


	s.set( 1, 0, 0 );
	assert( getPossible( s, 0, 0 ) == sudokuVals[1..$] );

	s.set( 2, 0, 1 );
	assert( getPossible(s, 0, 0).length == 7 );

	s.set( 6, 0, 0 );
	s.set( 3, 0, 1 );
	s.set( 4, 0, 2 );
	s.set( 1, 0, 4 );
	s.set( 5, 0, 5 );
	s.set( 4, 1, 4 );
	s.set( 7, 2, 4 );
	s.set( 2, 4, 4 );
	s.set( 8, 6, 4 );
	s.set( 9, 7, 4 );
	s.set( 3, 8, 4 );

	assert( getPossible(s, 0, 4) == [] );
}

/**
 Returns true if the Sudoku is solvable.
*/
bool isSolvable( Sudoku s ) 
{


	int tmp;
	int[] poss;

	foreach( i; 0..HEIGHT ) {
		foreach( j; 0..WIDTH ) {	
		
			tmp = s.get( i, j );
			
			s.set( defaultVal, i, j );

			poss = getPossible( s, i, j );

				if( tmp != defaultVal && !contains( poss, tmp ) && !contains( poss, -tmp ) ) {
					return false;
				} 

			s.set( tmp, i, j );
		}
	}
	return true;
}

unittest {
	Sudoku s;

	assert( isSolvable(s) );
		
	s.set( 4, 0, 0 );
	assert( isSolvable(s) );
}


enum Sign {
	POSITIVE, NEGATIVE
}

/**
 Turns all the Values of s which are more than zero, if Sign.POSITIVE.
 Turns all the values of s which are less than zeri, if Sign.NEGATIVE.
*/
void turn( ref Sudoku s, in Sign sign = Sign.NEGATIVE ) 
{
	int cur;

	foreach( i; 0..HEIGHT ) {
		foreach( j; 0..WIDTH ) {
			cur = s.get( i, j );
			
			if( sign == Sign.NEGATIVE && cur < 0 ) {
				s.set( -cur, i, j );
			} else if ( sign == Sign.POSITIVE && cur > 0 ) {
				s.set( -cur, i, j );
			}
		}
	}
}

unittest {
	Sudoku s;

	s.set( 2, 0, 0 );
	turn( s, Sign.POSITIVE );

	assert( s.get(0,0) == -2 );

	turn( s, Sign.NEGATIVE );
	assert( s.get( 0, 0 ) == 2 );
}

/**
 Inserts all possible values for the Sudoku s, beginning at [startY][startX].
*/
bool insert( ref Sudoku s, in int startR, in int startC)
in {
	assert( startR >= 0 && startR <= HEIGHT );
	assert( startC >= 0 && startC <= WIDTH );
}
body {
	int[] poss;
	int r = startR + 1;
	int c = startC;

	if( s.get( startR, startC ) == 0 ) {
		poss = getPossible( s, startR, startC );

		if( poss.length == 0 ) return false;

		s.set( poss[0], startR, startC ); 
	}	

	if( r >= HEIGHT ) {
		r = 0;
		c++;	
	}

	if( r >= WIDTH ) {
		return true;
	}
	
	while( !insert( s, r, c ) ) {
		if( poss is null ) return false;
		else {
			poss = poss[1..$];

			if( poss.length == 0 ) {
				s.set( 0, startR, startC );
				return false;
			}
			s.set( poss[0], startR, startC );		
		}
	}
	return true;
}

/**
 Tries to solve the Sudoku from the beginning.
 Returns false, if the algorithm can't solve it and true if the Sudoku was solved by the algorithm.
*/
bool solve( ref Sudoku s )
{
	if( !isSolvable( s ) ) {
		turn( s, Sign.NEGATIVE );
		return false;
	}

	auto solved = insert( s, 0, 0 );
	turn( s, Sign.NEGATIVE );
	return solved;
}





