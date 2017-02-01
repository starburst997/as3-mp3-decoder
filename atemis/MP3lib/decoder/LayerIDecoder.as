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
	 * Implements decoding of MPEG Audio Layer I frames. 
	 */
	internal class LayerIDecoder implements FrameDecoder
	{
		protected var		 			stream:Bitstream;
	    protected var	 				header:Header;
	    protected var			 		filter1:SynthesisFilter, filter2:SynthesisFilter;
	    protected var	 				buffer:Obuffer;
	    protected var 					which_channels:int;
		protected var					mode:int;
		
		protected var					num_subbands:int;
		protected var					subbands:Array;
		protected var					crc:Crc16	= null;	// new Crc16[1] to enable CRC checking.
		
		public function LayerIDecoder()
		{
			crc = new Crc16();
		}
		
		public function create(stream0:Bitstream, header0:Header,
			filtera:SynthesisFilter, filterb:SynthesisFilter,
			buffer0:Obuffer, which_ch0:int):void
		{		
		  	stream         = stream0;
		  	header         = header0;
		  	filter1        = filtera;
		  	filter2        = filterb;
		  	buffer         = buffer0;
		  	which_channels = which_ch0;
			  
		}
		
		
		
		public function decodeFrame():void
		{
			
			num_subbands = header.number_of_subbands();
			subbands = new Array(32);
			mode = header.mode();
			
			createSubbands();
			
			readAllocation();
			readScaleFactorSelection();
			
		    if ((crc != null) || header.checksum_ok())
	  		{
				readScaleFactors();
				
				readSampleData();			
			}
	
		}
	
		protected function createSubbands():void
		{  		
			var i:int;
			if (mode == Header.SINGLE_CHANNEL)
	  		  for (i = 0; i < num_subbands; ++i)
	  		    subbands[i] = new SubbandLayer1(i);
	  		else if (mode == Header.JOINT_STEREO)
			{
	  		  for (i = 0; i < header.intensity_stereo_bound(); ++i)
	  		    subbands[i] = new SubbandLayer1Stereo(i);
	  		  for (i=i; i < num_subbands; ++i)
	  		    subbands[i] = new SubbandLayer1IntensityStereo(i);
	  		}
			else
			{
	  		  for (i = 0; i < num_subbands; ++i)
	  		    subbands[i] = new SubbandLayer1Stereo(i);
	  	    }		
		}
		
		protected function readAllocation():void
		{
			// start to read audio data:
	  	    for (var i:int = 0; i < num_subbands; ++i)
	  	      subbands[i].read_allocation(stream, header, crc);
			
		}
	
		protected function readScaleFactorSelection():void
		{
			// scale factor selection not present for layer I. 
		}
		
		protected function readScaleFactors():void
		{
			for (var i:int = 0; i < num_subbands; ++i)
	  		  subbands[i].read_scalefactor(stream, header);  		
		}
		
		protected function readSampleData():void
		{
			var read_ready:Boolean = false;
			var write_ready:Boolean = false;
			var mode:int = header.mode();
			var i:int;
			do
	  		{
	  		  for (i = 0; i < num_subbands; ++i)
	  		  	read_ready = subbands[i].read_sampledata(stream);
	  		  do
	  		  {
	  		  	for (i = 0; i < num_subbands; ++i)
	  		  		write_ready = subbands[i].put_next_sample(which_channels,filter1, filter2);
	
	  		  	filter1.calculate_pcm_samples(buffer);
	  		  	if ((which_channels == OutputChannels.BOTH_CHANNELS) && (mode != Header.SINGLE_CHANNEL))
	           		filter2.calculate_pcm_samples(buffer);
	  		  } while (!write_ready);
	  		} while (!read_ready);
			
		}
	}
}
