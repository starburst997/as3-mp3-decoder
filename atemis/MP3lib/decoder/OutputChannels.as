/*
 * 06/02/07 Ported to ActionScript 3. By Jean-Denis Boivin 
 *			(jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 * 11/19/04 1.0 moved to LGPL.
 *
 * 12/12/99 Initial implementation.		mdm@techie.com. 
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
	 * A Type-safe representation of the the supported output channel
	 * constants. 
	 * 
	 * This class is immutable and, hence, is thread safe. 
	 * 
	 * @author	Mat McGowan 12/12/99 
	 * @since	0.0.7
	 */
	public class OutputChannels
	{		
		/**
		 * Flag to indicate output should include both channels. 
		 */
		public static const BOTH_CHANNELS:int = 0;
			
		/**
		 * Flag to indicate output should include the left channel only. 
		 */
		public static const LEFT_CHANNEL:int = 1;
	
		/**
		 * Flag to indicate output should include the right channel only. 
		 */
		public static const RIGHT_CHANNEL:int = 2;
			
		/**
		 * Flag to indicate output is mono. 
		 */
		public static const DOWNMIX_CHANNELS:int = 3;
	
		
		public static const LEFT:OutputChannels = new OutputChannels(LEFT_CHANNEL);
		public static const RIGHT:OutputChannels = new OutputChannels(RIGHT_CHANNEL);
		public static const BOTH:OutputChannels = new OutputChannels(BOTH_CHANNELS);
		public static const DOWNMIX:OutputChannels = new OutputChannels(DOWNMIX_CHANNELS);
					
		
		private /*final*/ var	outputChannels:int;
				
		/**
		 * Creates an <code>OutputChannels</code> instance
		 * corresponding to the given channel code.
		 * 
		 * @param	code one of the OutputChannels channel code constants.
		 * 
		 * @throws	IllegalArgumentException if code is not a valid
		 *			channel code. 
		 */
		static public function fromInt(code:int):OutputChannels
		{
			switch (code)
			{
			case LEFT_CHANNEL:
				return LEFT;
			case RIGHT_CHANNEL:
				return RIGHT;
			case BOTH_CHANNELS:
				return BOTH;
			case DOWNMIX_CHANNELS:
				return DOWNMIX;
			default:
				throw new Error("Invalid channel code: "+code);
			}
		}
			
		public function OutputChannels(channels:int):void
		{
			outputChannels = channels;
				
			if (channels<0 || channels>3)
				throw new Error("channels");
		}
			
		/**
		 * Retrieves the code representing the desired output channels.
		 * Will be one of LEFT_CHANNEL, RIGHT_CHANNEL, BOTH_CHANNELS
		 * or DOWNMIX_CHANNELS.
		 * 
		 * @return the channel code represented by this instance.
		 */
		public function getChannelsOutputCode():int
		{
			return outputChannels;	
		}
			
		/**
		 * Retrieves the number of output channels represented 
		 * by this channel output type.
		 * 
		 * @return	The number of output channels for this channel output
		 *			type. This will be 2 for BOTH_CHANNELS only, and 1
		 *			for all other types. 
		 */
		public function getChannelCount():int
		{
			var count:int = (outputChannels==BOTH_CHANNELS) ?  2 : 1;
			return count;
		}
			
			
		public function equals(o:Object):Boolean
		{
			var equals:Boolean = false;
				
			if (o is OutputChannels)
			{
				var oc:OutputChannels = o as OutputChannels;
				equals = (oc.outputChannels == outputChannels);
			}
				
			return equals;
		}
								  
		public function hashCode():int
		{
			return outputChannels;	
		}
	}		
}
