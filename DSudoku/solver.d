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
	int[] arr = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
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
	int[] arr = [ 1, 2, 3, 4, 5, 6, 7,8, 9 ];
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

	int startX = cast(int)( (r / 3) * 3 );
	int startY = cast(int)( (c / 3) * 3 );

	foreach( i; 0..HEIGHT ) {
				buf = remove( buf, abs( s.get( r, i ) ) );
				buf = remove( buf, abs( s.get( i, c ) ) );
	}

	foreach( i; 0..3 ) {
		foreach( j; 0..3 ) {
				buf = remove( buf, abs( s.get( i + startX, j + startY ) ) );		
		}
	}

	return buf;
}

unittest {

	Sudoku s;

	assert( getPossible(s, 0, 0 ) == [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] );
	assert( getPossible( s, 0, 0).length == 9 );


	s.set( 1, 0, 0 );
	assert( getPossible( s, 0, 0 ) == [ 2, 3, 4, 5, 6, 7, 8, 9 ] );

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
bool insert( ref Sudoku s, in int startY, in int startX )
in {
	assert( startY >= 0 && startY <= HEIGHT );
	assert( startX >= 0 && startX <= WIDTH );
}
body {
	int[] poss;
	int y = startY + 1;
	int x = startX;

	if( s.get( startY, startX ) == 0 ) {
		poss = getPossible( s, startY, startX );

		if( poss.length == 0 ) return false;

		s.set( poss[0], startY, startX ); 
	}	

	if( y >= HEIGHT ) {
		y = 0;
		x++;	
	}

	if( x >= WIDTH ) {
		return true;
	}
	
	while( !insert( s, y, x ) ) {
		if( poss is null ) return false;
		else {
			//poss = remove( poss, s.get( startY, startX ) );
			poss = poss[1..$];

			if( poss.length == 0 ) {
				s.set( 0, startY, startX );
				return false;
			}
			s.set( poss[0], startY, startX );		
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





