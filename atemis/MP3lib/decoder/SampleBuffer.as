/* 
 * 06/01/07  Ported to ActionScript 3. By Jean-Denis Boivin 
 *			 (jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 * 11/19/04	 1.0 moved to LGPL.
 * 
 * 12/12/99  Initial Version based on FileObuffer.	mdm@techie.com.
 * 
 * FileObuffer:
 * 15/02/99  Java Conversion by E.B ,javalayer@javazoom.net
 *
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
	 * The <code>SampleBuffer</code> class implements an output buffer
	 * that provides storage for a fixed size block of samples. 
	 */
	public class SampleBuffer extends Obuffer
	{
	  private var	 		buffer:Array;
	  private var	 		bufferp:Array;
	  private var 			channels:int;
	  private var			frequency:int;
	  
	  /**
	   * Constructor
	   */
	  public function SampleBuffer(sample_frequency:int, number_of_channels:int)
	  {
	  	buffer = new Array(OBUFFERSIZE);
		bufferp = new Array(MAXCHANNELS);
		channels = number_of_channels;
		frequency = sample_frequency;
		
		for (var i:int = 0; i < number_of_channels; ++i) 
			bufferp[i] = i;
		
	  }
	
	  public function getChannelCount():int
	  {
		return this.channels;  
	  }
	  
	  public function getSampleFrequency():int
	  {
		  return this.frequency;
	  }
	  
	  public function getBuffer():Array
	  {
		return this.buffer;  
	  }
	  
	  public function getBufferLength():int
	  {
		  return bufferp[0];
	  }
	  
	  /**
	   * Takes a 16 Bit PCM sample.
	   */
	  public override function append(channel:int, value:int):void
	  {
		buffer[bufferp[channel]] = value;
		bufferp[channel] += channels;	  	
	  }
	  
		public override function appendSamples(channel:int, f:Array):void
		{
			//trace(f);
		    var pos:int = bufferp[channel];
			var s:int;
			var fs:Number;
		    for (var i:int=0; i<32;)
		    {
			  	fs = f[i++];
				fs = (fs>32767.0 ? 32767.0
							   : (fs < -32767.0 ? -32767.0 : fs));
				
				s = fs;
				buffer[pos] = s;
				pos += channels;
		    }
			
			bufferp[channel] = pos;
		}
	  
	  
	  /**
	   * Write the samples to the file (Random Acces).
	   */
	  public override function write_buffer(val:int):void
	  {
					  
		//for (int i = 0; i < channels; ++i) 
		//	bufferp[i] = (short)i;
	
	  }
	
	  public override function close():void
	  {}
	  
	  /**
	   *
	   */
	  public override function clear_buffer():void
	  {
		for (var i:int = 0; i < channels; ++i) 
			bufferp[i] = i;
	  }
	
	  /**
	   *
	   */
	  public override function set_stop_flag():void
	  {}
	}
}
