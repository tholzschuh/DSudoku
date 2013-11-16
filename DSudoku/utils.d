// Written in the D programming language. $(WEB: http://www.dlang.org)

/*
 * -------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 16.11.2013
 * License: "THE BEER-WARE LICENSE"; $(WEB: http://people.freebsd.org/~phk/)
 * -------------------------------------------------------------------------
 */


module utils;

import sudoku;

import std.math : abs;

	version( unittest )
	{
		immutable(int[]) testValues = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
	}

/**
 Removes the specified Value from the Array, if the Array contains it.
*/
void remove(T)( ref T arr[], in T val )
body {
	foreach( i; 0..arr.length ) {
		if( arr[i] == val ) {
			foreach( j; i..arr.length-1 ) {
				arr[j] = arr[j+1];
			}
			break;
		}
	}

	arr = arr[0..$-1];
}

unittest {
	auto arr = testValues.dup;

	remove!(int)( arr, 3 );
	assert( arr == [ 1, 2, 4, 5, 6, 7, 8, 9 ] );

	remove!int( arr, 8 );
	assert( arr == [ 1, 2, 4, 5, 6, 7, 9 ] );
}

/**
 Returns true if the given Array contains the specified value.
 If the Array doesn't contain the value, the function returns false.
*/
bool contains(T)( in T[] arr, in T val ) pure
{

        foreach( element; arr ) {
                if( element == val ) {
                        return true;
                }
        }

        return false;
}

unittest {
        int[] arr = testValues.dup;
        int val = 5;

        assert( contains!int( arr, val ) );
        assert( !contains!int( arr, 10 ) );
}

/**
 Returns the indexes of all empty field in the Sudoku.
*/
int[][] getEmptyFields( in Sudoku s ) pure
out( result ) {
	assert( result.length >= 0 && result.length <= Sudoku.totalValueAmount );
}
body {
	int[][] empty;

	foreach( row; 0..s.height ) {
		foreach( col; 0..s.width ) {
			if( s[row, col] == Sudoku.defaultValue ) {
				empty ~= [ row, col ];	
			}
		}
	}

	return empty;
}


unittest {
	Sudoku s;
	assert( getEmptyFields(s).length == Sudoku.totalValueAmount );

	s[ 0, 0 ] = 1;
	s[ 0, 1 ] = 2;
	s[ 0, 2 ] = 3;

	assert( getEmptyFields(s).length == Sudoku.totalValueAmount - 3 );

	auto empty = getEmptyFields(s);
	assert( s[ empty[0][0], empty[0][1] ] == 0 );
}


/**
 Returns the indexes of all filled fields in the Sudoku.
*/
int[][] getFilledFields( in Sudoku s ) pure
out( result ) {
	assert( result.length >= 0 && result.length <= Sudoku.totalValueAmount );
}
body {
	int[][] filled;

	foreach( row; 0..s.height ) {
		foreach( col; 0..s.width ) {
			if( s[ row, col ] != Sudoku.defaultValue ) {
				filled ~= [ row, col ];
			}
		}
	}
	return filled;
}

unittest {
	Sudoku s;

	assert( getFilledFields( s ).length == 0 );

	s[ 0, 0 ] = 1;
	assert( getFilledFields( s ).length == 1 );
	
	s[ 0, 1 ] = 2;
	assert( getFilledFields( s ).length == 2 );
}


/**
 Returns all possible values for the Sudoku in the specified Point.
*/
int[] getPossible( in Sudoku s, in int r, in int c )// pure 
in {
        assert( r >= 0 && r < s.height );
        assert( c >= 0 && c < s.width );
}
out( result ) {
        assert( result.length <= 9 );
}
body {
        int[] buf = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];

        foreach( i; 0..s.height ) {
			int ri = abs( s[ r, i ] );
			int ic = abs( s[ i, c ] );

			if( contains!int( buf, ri ) ) remove!int( buf, ri );
			if( contains!int( buf, ic ) ) remove!int( buf, ic );
        }

        foreach( i; 0..3 ) {
                foreach( j; 0..3 ) {
				int ij = abs( s[ i + r / 3 * 3, j + c / 3 * 3 ] );
				if( contains!int( buf, ij ) ) remove!int( buf, ij );
                }
        }

        return buf;
}

unittest {

        Sudoku s;

        assert( getPossible(s, 0, 0 ) == testValues );
        assert( getPossible( s, 0, 0).length == 9 );


	s[ 0, 0 ] = 1;
        assert( getPossible( s, 0, 0 ) == testValues[1..$] );

	s[ 0, 1 ] = 2;
        assert( getPossible( s, 0, 0 ).length == 7 );


	s[ 0, 0 ] = 6;
	s[ 0, 1 ] = 3;
	s[ 0, 2 ] = 4;
	s[ 0, 4 ] = 1;
	s[ 0, 5 ] = 5;
	s[ 1, 4 ] = 4;
	s[ 2, 4 ] = 7;
	s[ 4, 4 ] = 2;
	s[ 6, 4 ] = 8;
	s[ 7, 4 ] = 9;
	s[ 8, 4 ] = 3;
	

        assert( getPossible(s, 0, 4) == [] );
}

/**
 Returns true if the Sudoku is solvable.
*/
bool isSolvable( Sudoku s )
{


        int tmp;
        int[] poss;

        foreach( row; 0..s.height ) {
                foreach( col; 0..s.width ) {

                        tmp = s[ row, col ];

                        s[ row, col ] = Sudoku.defaultValue;

                        poss = getPossible( s, row, col );

                                if( tmp != Sudoku.defaultValue && !contains!int( poss, tmp ) && !contains!int( poss, -tmp ) ) {
                                        return false;
                                }

                        s[ row, col ] = tmp;
                }
        }
        return true;
}

unittest {
        Sudoku s;

        assert( isSolvable(s) );

        s[ 0, 0 ] = 4;
        assert( isSolvable(s) );

	s[ 0, 1 ] = 4;
	assert( !isSolvable(s) );
}


