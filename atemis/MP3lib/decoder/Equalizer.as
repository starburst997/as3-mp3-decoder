/*
 * 06/01/07  	Ported to ActionScript 3. By Jean-Denis Boivin 
 *			 	(jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 * 11/19/04		1.0 moved to LGPL.
 *
 * 12/12/99		Initial version.	mdm@techie.com
 *-----------------------------------------------------------------------
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *----------------------------------------------------------------------
 */


package atemis.MP3lib.decoder {

	/**
	 * The <code>Equalizer</code> class can be used to specify
	 * equalization settings for the MPEG audio decoder. 
	 * <p>
	 * The equalizer consists of 32 band-pass filters. 
	 * Each band of the equalizer can take on a fractional value between 
	 * -1.0 and +1.0.
	 * At -1.0, the input signal is attenuated by 6dB, at +1.0 the signal is
	 * amplified by 6dB. 
	 * 
	 * @see Decoder
	 * 
	 * @author MDM
	 */
	public final class Equalizer
	{		
		/**
		 * Equalizer setting to denote that a given band will not be
		 * present in the output signal.
		 */
		static public const BAND_NOT_PRESENT:Number = Number.NEGATIVE_INFINITY;
			
		static public var PASS_THRU_EQ:Equalizer = new Equalizer();
		
		private static const BANDS:int = 32;
		
		private var	settings:Array = new Array(BANDS);
		
		/**
		 * Creates a new <code>Equalizer</code> instance. 
		 */
		
	//	private Equalizer(float b1, float b2, float b3, float b4, float b5,
	//					 float b6, float b7, float b8, float b9, float b10, float b11,
	//					 float b12, float b13, float b14, float b15, float b16,
	//					 float b17, float b18, float b19, float b20);
	
		public function Equalizer(arg:Object = null)
		{
			if (arg is EQFunction) {
				setFrom(arg as EQFunction);
			}else if (arg is Array) {
				setFrom(arg as Array);
			}
		}
		
		public function setFrom(arg:Object):void {
			if (arg is EQFunction) {
				setFrom2(arg as EQFunction);
			}else if (arg is Equalizer) {
				setFrom3(arg as Equalizer);
			}else if (arg is Array){
				setFrom1(arg as Array);
			}
		}
		
		public function setFrom1(eq:Array):void
		{
			reset();
			var max:int = (eq.length > BANDS) ? BANDS : eq.length;
			
			for (var i:int=0; i<max; i++)
			{
				settings[i] = limit(eq[i]);
			}
		}
	
		public function setFrom2(eq:EQFunction):void
		{
			reset();
			var max:int = BANDS;
			
			for (var i:int=0; i<max; i++)
			{
				settings[i] = limit(eq.getBand(i));
			}		
		}
		
		/**
		 * Sets the bands of this equalizer to the value the bands of
		 * another equalizer. Bands that are not present in both equalizers are ignored. 
		 */
		public function setFrom3(eq:Equalizer):void
		{
			if (eq!=this)
			{
				setFrom(eq.settings);
			}
		}


		/**
		 * Sets all bands to 0.0
		 */
		public function reset():void
		{
			for (var i:int=0; i<BANDS; i++)
			{
				settings[i] = 0.0;
			}
		}
	
		
		/**
		 * Retrieves the number of bands present in this equalizer.
		 */
		public function getBandCount():int
		{
			return settings.length;	
		}
		
		public function setBand(band:int, neweq:Number):Number
		{
			var eq:Number = 0.0;
			
			if ((band>=0) && (band<BANDS))
			{
				eq = settings[band];
				settings[band] = limit(neweq);
			}
			
			return eq;		
		}
		
		
		
		/**
		 * Retrieves the eq setting for a given band.
		 */
		public function getBand(band:int):Number
		{
			var eq:Number = 0.0;
			
			if ((band>=0) && (band<BANDS))
			{
				eq = settings[band];
			}
			
			return eq;
		}
		
		private function limit(eq:Number):Number
		{
			if (eq==BAND_NOT_PRESENT)
				return eq;
			if (eq > 1.0)
				return 1.0;
			if (eq < -1.0)
				return -1.0;
			
			return eq;
		}
		
		/**
		 * Retrieves an array of floats whose values represent a
		 * scaling factor that can be applied to linear samples
		 * in each band to provide the equalization represented by
		 * this instance. 
		 * 
		 * @return	an array of factors that can be applied to the
		 *			subbands.
		 */
		public function getBandFactors():Array
		{
			var factors:Array = new Array(BANDS);
			for (var i:int=0; i<BANDS; i++)
			{
				factors[i] = getBandFactor(settings[i]);
			}
			
			return factors;
		}
		
		/**
		 * Converts an equalizer band setting to a sample factor.
		 * The factor is determined by the function f = 2^n where
		 * n is the equalizer band setting in the range [-1.0,1.0].
		 * 	 
		 */
		public function getBandFactor(eq:Number):Number
		{
			if (eq==BAND_NOT_PRESENT)
				return 0.0;
			
			var f:Number = Math.pow(2.0, eq);
			return f;
		}

	}	
}
