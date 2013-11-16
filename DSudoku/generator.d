// Written in the D programming language. $(WEB: http://www.dlang.org)

/*
 * -------------------------------------------------------------------------
 * Author: Tim Holzschuh
 * Date: 16.11.2013
 * License: "THE BEER-WARE LICENSE"; $(WEB: http://people.freebsd.org/~phk/)
 * -------------------------------------------------------------------------
 */

module generator;

import sudoku;
import utils;
import solver;

import std.random : uniform;

	version( unittest ) 
	{
		import std.stdio : writeln;
	}

enum Difficulty {
	HARD = 10, MEDIUM = 20, EASY = 30, EMPTY = 0
}

/**
 Tries to generate a Sudoku, with 'num' prefilled fields.
*/
Sudoku generate( in int num )
in {
        assert( num > 0 && num <= Sudoku.totalValueAmount );
}
body {
        Sudoku s;

        int cnt = 0;

        int r, lastR;
        int c, lastC;
        int val, lastVal;
        int rand;

        int[][] fields;
        int[] poss;


        while( cnt < num ) {
                lastR = r;
                lastC = c;
                lastVal = val;

                fields = getEmptyFields(s);
                rand = cast(int)(uniform( 0, fields.length ));

                r = fields[rand][0];
                c = fields[rand][1];

                poss = getPossible( s, r, c );

                if( poss is null || poss.length == 0 ) {
			poss = getPossible( s, lastR, lastC );
			remove( poss, lastVal );
		
			r = lastR;
                        c = lastC;

			if( poss.length == 0 ) {
				lastR = uniform( 0, 9 );
				lastC = uniform( 0, 9 );
			}
                }

                if( poss.length > 0 && ( r != lastR || c != lastC ) ) {
                        val = poss[ uniform(0, poss.length) ];
			s[ r, c ] = val;
                        ++cnt;
                }

		if( cnt == 20 ) {
			if( solve(s) ) {

				while( getEmptyFields(s).length < Sudoku.totalValueAmount - num ) {
					lastR = r;
					lastC = c;
				
					fields = getFilledFields(s);

					rand = cast(int)(uniform( 0, fields.length ));

					r = fields[rand][0];
					c = fields[rand][1];

					if( s[ r, c ] != Sudoku.defaultValue ) {
						s[ r, c ] = Sudoku.defaultValue;
					}

			
				}

				break;
			}
		}

        }

        return s;
}

unittest {
	
	int num = 70;

	auto s = generate( num );
	int count = 0;

	foreach( i; 0..s.height ) {
		foreach( j; 0..s.width ) {
			if( s[ i, j ] != Sudoku.defaultValue ) {
				++count;
			}
		}
	}

	assert( isSolvable(s) );

	writeln(s);
	writeln(count, " ", num);
}
