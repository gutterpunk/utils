package com.xxistcenturyboy.utils;

/**
 * ...
 * @author Jean-Sebastien Payette
 * 
 * based on http://en.wikipedia.org/wiki/Mersenne_twister
 */

class MerseneTwister 
{
	// Create a length 624 array to store the state of the generator
	private var MT : Array<Int>;
	private var index : Int = 0;
	public function new(seed : Int = 0) 
	{
		MT = new Array<Int>();
		this.seed = seed;
	}

	// Initialize the generator from a seed
	public function initialize_generator(seed : Int):Void
	{
		var i : Int = 1;
		MT[0] = seed;
		while (i < 624) { // loop over each other element
			MT[i] = (1812433253 * (MT[i - 1] ^ (MT[i - 1] >>> 30)) + i) & 0xFFFFFFFF; // 0x6c078965
			i++;
		}
	}
	
	// Extract a tempered pseudorandom number based on the index-th value,
	// calling generate_numbers() every 624 numbers
	public function extract_number():Int
	{
		if (index == 0) {
			generate_numbers();
		}

		var y : Int = MT[index];
		y ^= (y >>> 11);
		y ^= ((y << 7) & 0x9d2c5680);
		y ^= ((y << 15) & 0xefc60000);
		y ^= (y >>> 18);

		index = (index + 1) % 624;
		return y;
	}

	// Generate an array of 624 untempered numbers
	private function generate_numbers():Void
	{
		var i : Int = 0;
		while (i < 623)
		{
			var y : Int = (MT[i] & 0x80000000)                       // bit 31 (32nd bit) of MT[i]
						+ (MT[(i + 1) % 624] & 0x7fffffff);   		 // bits 0-30 (first 31 bits) of MT[...]
			MT[i] = MT[(i + 397) % 624] ^ (y >>> 1);
			if ((y % 2) != 0) { // y is odd
				MT[i] = MT[i] ^ 0x9908b0df;
			}
			i++;
		}
	}
	
	//Extensions
	public var random(nextFloat, null) : Float;
	public var seed(default, setSeed) : Int;

	public function setSeed(value : Int) : Int
	{
		seed = value;
		initialize_generator(value);
		return value;
	}
	public function nextFloat() : Float
	{
		return (extract_number() / 4294967295) + 0.5;
	}
	
	public function next(high : Int) : Int
	{
		return between(0, high);
	}
	public function between(low : Int, high : Int) : Int
	{
		var delta : Int = (high - low);
		var value : Int = extract_number();
		if (value < 0) value = -value;
		var random : Int = value % delta;
		return random + low;
	}
	
	//Instance
	public static var instance(getInstance, null) : MerseneTwister;
	public static var _self : MerseneTwister = null;
	
	private static function createInstance() : Void
	{
		if (_self == null)
			_self = new MerseneTwister(Std.int((Math.random() - 0.5) * 0xFFFFFFFF));		
	}
	public static function getInstance() : MerseneTwister
	{
		createInstance();
		return _self;
	}
}