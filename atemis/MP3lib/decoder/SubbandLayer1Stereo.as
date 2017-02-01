/*
 * 06/01/07  	Ported to ActionScript 3. By Jean-Denis Boivin 
 *			 	(jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 * 11/19/04		1.0 moved to LGPL.
 * 
 * 12/12/99		Initial version. Adapted from javalayer.java
 *				and Subband*.java. mdm@techie.com
 *
 * 02/28/99		Initial version : javalayer.java by E.B
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
		 * Class for layer I subbands in stereo mode.
		 */
		internal class SubbandLayer1Stereo extends SubbandLayer1
		{
		  protected var 		channel2_allocation:int;
		  protected var			channel2_scalefactor:Number;
		  protected var 		channel2_samplelength:int;
		  protected var		 	channel2_sample:Number;
		  protected var 	 	channel2_factor:Number, channel2_offset:Number;
	
	
		  /**
		   * Constructor
		   */
		  public function SubbandLayer1Stereo(subbandnumber:int)
		  {
		    super(subbandnumber);
		  }
		  
		  /**
		   *
		   */
		  public override function read_allocation (stream:Bitstream, header:Header, crc:Crc16):void
		  {
		 	 allocation = stream.get_bits(4);
		     channel2_allocation = stream.get_bits(4);
		     if (crc != null)
		     {
			   crc.add_bits (allocation, 4);
		       crc.add_bits (channel2_allocation, 4);
		     }
		     if (allocation != 0)
		     {
			    samplelength = allocation + 1;
		        factor = table_factor[allocation];
		        offset = table_offset[allocation];
		     }
		     if (channel2_allocation != 0)
		     {
		        channel2_samplelength = channel2_allocation + 1;
			    channel2_factor = table_factor[channel2_allocation];
			    channel2_offset = table_offset[channel2_allocation];
		     }
		  }
		  
		  /**
		   *
		   */
		  public override function read_scalefactor(stream:Bitstream, header:Header):void
		  {
		    if (allocation != 0) scalefactor = scalefactors[stream.get_bits(6)];
		    if (channel2_allocation != 0) channel2_scalefactor = scalefactors[stream.get_bits(6)];
		  }
	
		  /**
		   *
		   */
		  public override function read_sampledata (stream:Bitstream):Boolean
		  {
		     var returnvalue:Boolean = super.read_sampledata(stream);
		     if (channel2_allocation != 0)
		     {
			    channel2_sample = /*(float)*/ (stream.get_bits(channel2_samplelength));
		      }
		    return(returnvalue);
		  }
		  
		  /**
		   *
		   */
		  public override function put_next_sample(channels:int, filter1:SynthesisFilter, filter2:SynthesisFilter):Boolean
		  {
		     super.put_next_sample (channels, filter1, filter2);
		     if ((channel2_allocation != 0) && (channels != OutputChannels.LEFT_CHANNEL))
		     {
			    var sample2:Number = (channel2_sample * channel2_factor + channel2_offset) *
						  channel2_scalefactor;
			    if (channels == OutputChannels.BOTH_CHANNELS)
				   filter2.input_sample (sample2, subbandnumber);
			    else
				   filter1.input_sample (sample2, subbandnumber);
				   
		     }
		     return true;
		  }
	}
}
