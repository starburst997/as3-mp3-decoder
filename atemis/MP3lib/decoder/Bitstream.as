/*
 * 06/01/07  Ported to ActionScript 3. By Jean-Denis Boivin 
 *			 (jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 * 11/19/04  1.0 moved to LGPL.
 * 
 * 11/17/04	 Uncomplete frames discarded. E.B, javalayer@javazoom.net 
 *
 * 12/05/03	 ID3v2 tag returned. E.B, javalayer@javazoom.net 
 *
 * 12/12/99	 Based on Ibitstream. Exceptions thrown on errors,
 *			 Temporary removed seek functionality. mdm@techie.com
 *
 * 02/12/99 : Java Conversion by E.B , javalayer@javazoom.net
 *
 * 04/14/97 : Added function prototypes for new syncing and seeking
 * mechanisms. Also made this file portable. Changes made by Jeff Tsay
 *
 *  @(#) ibitstream.h 1.5, last edit: 6/15/94 16:55:34
 *  @(#) Copyright (C) 1993, 1994 Tobias Bading (bading@cs.tu-berlin.de)
 *  @(#) Berlin University of Technology
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
	 * The <code>Bistream</code> class is responsible for parsing
	 * an MPEG audio bitstream.
	 *
	 * <b>REVIEW:</b> much of the parsing currently occurs in the
	 * various decoders. This should be moved into this class and associated
	 * inner classes.
	 */
	public final class Bitstream
	{
		static public const BITSTREAM_ERROR:int = 0;
		
		/**
		 * An undeterminable error occurred. 
		 */
		static public const UNKNOWN_ERROR:int = BITSTREAM_ERROR + 0;
		
		/**
		 * The header describes an unknown sample rate.
		 */
		static public const UNKNOWN_SAMPLE_RATE:int = BITSTREAM_ERROR + 1;
	
		/**
		 * A problem occurred reading from the stream.
		 */
		static public const STREAM_ERROR:int = BITSTREAM_ERROR + 2;
		
		/**
		 * The end of the stream was reached prematurely. 
		 */
		static public const UNEXPECTED_EOF:int = BITSTREAM_ERROR + 3;
		
		/**
		 * The end of the stream was reached. 
		 */
		static public const STREAM_EOF:int = BITSTREAM_ERROR + 4;
		
		/**
		 * Frame data are missing. 
		 */
		static public const INVALIDFRAME:int = BITSTREAM_ERROR + 5;
	
		
		/**
		 * Synchronization control constant for the initial
		 * synchronization to the start of a frame.
		 */
		public static var		INITIAL_SYNC:int = 0;
	
		/**
		 * Synchronization control constant for non-initial frame
		 * synchronizations.
		 */
		public static var		STRICT_SYNC:int = 1;
	
		// max. 1730 bytes per frame: 144 * 384kbit/s / 32000 Hz + 2 Bytes CRC
		/**
		 * Maximum size of the frame buffer.
		 */
		private static const	BUFFER_INT_SIZE:int = 433;
	
		/**
		 * The frame buffer that holds the data for the current frame.
		 */
		private const			framebuffer:Array = new Array(BUFFER_INT_SIZE);
	
		/**
		 * Number of valid bytes in the frame buffer.
		 */
		private var				framesize:int;
	
		/**
		 * The bytes read from the stream.
		 */
		private var				frame_bytes:Array = new Array(BUFFER_INT_SIZE*4);
	
		/**
		 * Index into <code>framebuffer</code> where the next bits are
		 * retrieved.
		 */
		private var				wordpointer:int;
	
		/**
		 * Number (0-31, from MSB to LSB) of next bit for get_bits()
		 */
		private var				bitindex:int;
	
		/**
		 * The current specified syncword
		 */
		private var				syncword:int;
		
		/**
		 * Audio header position in stream.
		 */
		private var				header_posz:int = 0;
	
		/**
		 *
		 */
		private var				single_ch_mode:Boolean;
	  //private int 			current_frame_number;
	  //private int				last_frame_number;
	
		private const			bitmask:Array = [0,	// dummy
		 0x00000001, 0x00000003, 0x00000007, 0x0000000F,
		 0x0000001F, 0x0000003F, 0x0000007F, 0x000000FF,
		 0x000001FF, 0x000003FF, 0x000007FF, 0x00000FFF,
		 0x00001FFF, 0x00003FFF, 0x00007FFF, 0x0000FFFF,
	     0x0001FFFF ];
	
		private var source:PushbackInputStream;
	
		private const					header:Header = new Header();
	
		private const					syncbuf:Array = new Array(4);
	
		private var						crc:Array = new Array(1);
	
		private var						rawid3v2:Array = null;
	
		private var						firstframe:Boolean = true;
	
	
		/**
		 * Construct a IBitstream that reads data from a
		 * given InputStream.
		 *
		 * @param in	The InputStream to read from.
		 */
		public function Bitstream(inB:InputStream)
		{
			if (inB==null) throw new Error("inB");
			inB = new BufferedInputStream(inB);		
			loadID3v2(inB);
			firstframe = true;
			//source = new PushbackInputStream(inB, 1024);
			source = new PushbackInputStream(inB, BUFFER_INT_SIZE*4);
			
			closeFrame();

			//current_frame_number = -1;
			//last_frame_number = -1;
		}
	
		/**
		 * Return position of the first audio header.
		 * @return size of ID3v2 tag frames.
		 */
		public function header_pos():int
		{
			return header_posz;
		}
		
		/**
		 * Load ID3v2 frames.
		 * @param in MP3 InputStream.
		 * @author JavaZOOM
		 */
		private function loadID3v2(inB:InputStream):void
		{		
			var size:int = -1;
			try
			{
				// Read ID3v2 header (10 bytes).
				inB.mark(10);			
				size = readID3v2Header(inB);
				header_posz = size;			
			}
			catch (e:Error)
			{}
			finally
			{
				try
				{
					// Unread ID3v2 header (10 bytes).
					inB.reset();
				}
				catch (e:Error)
				{}
			}
			// Load ID3v2 tags.
			try
			{
				if (size > 0)
				{
					rawid3v2 = new Array(size);
					inB.read(rawid3v2,0,rawid3v2.length);
				}			
			}
			catch (e:Error)
			{}
		}
		
		/**
		 * Parse ID3v2 tag header to find out size of ID3v2 frames. 
		 * @param in MP3 InputStream
		 * @return size of ID3v2 frames + header
		 * @throws IOException
		 * @author JavaZOOM
		 */
		private function readID3v2Header(inB:InputStream):int
		{		
			var id3header:Array = new Array(4);
			var size:int = -10;
			inB.read(id3header,0,3);
			// Look for ID3v2
			if ( (id3header[0]==('I').charCodeAt()) && (id3header[1]==('D').charCodeAt()) && (id3header[2]==('3').charCodeAt()))
			{
				inB.read(id3header,0,3);
				var majorVersion:int = id3header[0];
				var revision:int = id3header[1];
				inB.read(id3header,0,4);
				size = /*(int)*/ (id3header[0] << 21) + (id3header[1] << 14) + (id3header[2] << 7) + (id3header[3]);
			}
			return (size+10);
		}
		
		/**
		 * Return raw ID3v2 frames + header.
		 * @return ID3v2 InputStream or null if ID3v2 frames are not available.
		 */
		public function getRawID3v2():InputStream
		{
			if (rawid3v2 == null) return null;
			else
			{
				var bain:ByteArrayInputStream = new ByteArrayInputStream(rawid3v2);		
				return bain;
			}
		}
	
		/**
		 * Close the Bitstream.
		 * @throws BitstreamException
		 */
		public function close():void
		{
			try
			{
				source.close();
			}
			catch (ex:Error)
			{
				throw new BitstreamException(STREAM_ERROR, ex);
			}
		}
	
		/**
		 * Reads and parses the next frame from the input source.
		 * @return the Header describing details of the frame read,
		 *	or null if the end of the stream has been reached.
		 */
		public function readFrame():Header
		{
			var result:Header = null;
			try
			{
				result = readNextFrame();
				// E.B, Parse VBR (if any) first frame.
				if (firstframe == true)
				{
					result.parseVBR(frame_bytes);
					firstframe = false;
				}			
			}
			catch (ex:BitstreamException)
			{
				if ((ex.getErrorCode()==INVALIDFRAME))
				{
					// Try to skip this frame.
					//System.out.println("INVALIDFRAME");
					try
					{
						closeFrame();
						result = readNextFrame();
					}
					catch (e:BitstreamException)
					{
						if ((e.getErrorCode()!=STREAM_EOF))
						{
							// wrap original exception so stack trace is maintained.
							throw new BitstreamException(e.getErrorCode(), e);
						}
					}
				}
				else if ((ex.getErrorCode()!=STREAM_EOF))
				{
					// wrap original exception so stack trace is maintained.
					throw new BitstreamException(ex.getErrorCode(), ex);
				}
			}
			return result;
		}
	
		/**
		 * Read next MP3 frame.
		 * @return MP3 frame header.
		 * @throws BitstreamException
		 */
		private function readNextFrame():Header
		{
			if (framesize == -1)
			{
				nextFrame();
			}
			return header;
		}
	
	
		/**
		 * Read next MP3 frame.
		 * @throws BitstreamException
		 */
		private function nextFrame():void
		{
			// entire frame is read by the header class.
			header.read_header(this, crc);
		}
	
		/**
		 * Unreads the bytes read from the frame.
		 * @throws BitstreamException
		 */
		// REVIEW: add new error codes for this.
		public function unreadFrame():void
		{
			if (wordpointer==-1 && bitindex==-1 && (framesize>0))
			{
				try
				{
					source.unread(frame_bytes, 0, framesize);
				}
				catch (ex:Error)
				{
					throw new BitstreamException(STREAM_ERROR);
				}
			}
		}
	
		/**
		 * Close MP3 frame.
		 */
		public function closeFrame():void
		{
			framesize = -1;
			wordpointer = -1;
			bitindex = -1;
		}
	
		/**
		 * Determines if the next 4 bytes of the stream represent a
		 * frame header.
		 */
		public function isSyncCurrentPosition(syncmode:int):Boolean
		{
			var read:int = readBytes(syncbuf, 0, 4);
			var headerstring:uint = ((syncbuf[0] << 24) & 0xFF000000) | ((syncbuf[1] << 16) & 0x00FF0000) | ((syncbuf[2] << 8) & 0x0000FF00) | ((syncbuf[3] << 0) & 0x000000FF);
	
			try
			{
				source.unread(syncbuf, 0, read);
			}
			catch (ex:Error)
			{
			}
	
			var sync:Boolean = false;
			switch (read)
			{
				case 0:
					sync = true;
					break;
				case 4:
					sync = isSyncMark(headerstring, syncmode, syncword);
					break;
			}
	
			return sync;
		}
	
	
		// REVIEW: this class should provide inner classes to
		// parse the frame contents. Eventually, readBits will
		// be removed.
		public function readBits(n:int):int
		{
			return get_bits(n);
		}
	
		public function readCheckedBits(n:int):int
		{
			// REVIEW: implement CRC check.
			return get_bits(n);
		}
	
		protected function newBitstreamException(errorcode:int):BitstreamException
		{
			return new BitstreamException(errorcode, null);
		}
	
	  /**
	   * Get next 32 bits from bitstream.
	   * They are stored in the headerstring.
	   * syncmod allows Synchro flag ID
	   * The returned value is False at the end of stream.
	   */
	
		public function syncHeader(syncmode:int):uint
		{
			var sync:Boolean, i:int=1;
			var headerstring:uint;
			// read additional 2 bytes
			var bytesRead:int = readBytes(syncbuf, 0, 3);
			
			if (bytesRead!=3) throw new BitstreamException(STREAM_EOF, null);
	
			headerstring = ((syncbuf[0] << 16) & 0x00FF0000) | ((syncbuf[1] << 8) & 0x0000FF00) | ((syncbuf[2] << 0) & 0x000000FF);

			do
			{
				headerstring <<= 8;
	
				if (readBytes(syncbuf, 3, 1)!=1)
					throw new BitstreamException(STREAM_EOF, null);
	
				headerstring |= (syncbuf[3] & 0x000000FF);
				
				sync = isSyncMark(headerstring, syncmode, syncword);
			}
			while (!sync);
			//current_frame_number++;
			//if (last_frame_number < current_frame_number) last_frame_number = current_frame_number;
	
			return headerstring;
		}
	
		public function isSyncMark(headerstring:uint, syncmode:int, word:uint):Boolean
		{
			var sync:Boolean = false;
	
			if (syncmode == INITIAL_SYNC)
			{
				//sync =  ((headerstring & 0xFFF00000) == 0xFFF00000);
				sync =  (uint(headerstring & 0xFFE00000) == 0xFFE00000);	// SZD: MPEG 2.5
			}
			else
			{
				sync =  (uint(headerstring & 0xFFF80C00) == word) &&
				    ((uint(headerstring & 0x000000C0) == 0x000000C0) == single_ch_mode);
			}

			// filter out invalid sample rate
			if (sync)
				sync = (uint(uint(headerstring >>> 10) & 3)!=3);
			// filter out invalid layer
			if (sync)
				sync = (uint(uint(headerstring >>> 17) & 3)!=0);
			// filter out invalid version
			if (sync)
				sync = (uint(uint(headerstring >>> 19) & 3)!=1);

			return sync;
		}
	
		/**
		 * Reads the data for the next frame. The frame is not parsed
		 * until parse frame is called.
		 */
		public function read_frame_data(bytesize:int):int
		{
	 		var	numread:int = 0;
			numread = readFully(frame_bytes, 0, bytesize);
			framesize = bytesize;
			wordpointer = -1;
		    bitindex = -1;
		    return numread;
		}
	
	  /**
	   * Parses the data previously read with read_frame_data().
	   */
	  public function parse_frame():void
	  {
		// Convert Bytes read to int
		var	b:int=0;
		var byteread:Array = frame_bytes;
		var bytesize:int = framesize;
	
		// Check ID3v1 TAG (True only if last frame).
		//for (int t=0;t<(byteread.length)-2;t++)
		//{
		//	if ((byteread[t]=='T') && (byteread[t+1]=='A') && (byteread[t+2]=='G'))
		//	{
		//		System.out.println("ID3v1 detected at offset "+t);
		//		throw newBitstreamException(INVALIDFRAME, null);
		//	} 	
		//}
		
		for (var k:int=0;k<bytesize;k=k+4)
		{
			var convert:int = 0;
			var b0:int = 0;
			var b1:int = 0;
			var b2:int = 0;
			var b3:int = 0;
			b0 = byteread[k];
			if (k+1<bytesize) b1 = byteread[k+1];
			if (k+2<bytesize) b2 = byteread[k+2];
			if (k+3<bytesize) b3 = byteread[k+3];
			framebuffer[b++] = ((b0 << 24) &0xFF000000) | ((b1 << 16) & 0x00FF0000) | ((b2 << 8) & 0x0000FF00) | (b3 & 0x000000FF);
		}
		wordpointer = 0;
	    bitindex = 0;
	  }
	
	  /**
	   * Read bits from buffer into the lower bits of an unsigned int.
	   * The LSB contains the latest read bit of the stream.
	   * (1 <= number_of_bits <= 16)
	   */
	  public function get_bits(number_of_bits:int):int
	  {
	  	var				returnvalue:int = 0;
	  	var 			sum:int = bitindex + number_of_bits;
	
		// E.B
		// There is a problem here, wordpointer could be -1 ?!
	    if (wordpointer < 0) wordpointer = 0;
	    // E.B : End.
	
	  	if (sum <= 32)
	  	{
		   // all bits contained in *wordpointer
		   returnvalue = (framebuffer[wordpointer] >>> (32 - sum)) & bitmask[number_of_bits];
		   // returnvalue = (wordpointer[0] >> (32 - sum)) & bitmask[number_of_bits];
		   if ((bitindex += number_of_bits) == 32)
		   {
			 bitindex = 0;
			 wordpointer++; // added by me!
		   }
		   return returnvalue;
	    }
	
	    // E.B : Check that ?
	    //((short[])&returnvalue)[0] = ((short[])wordpointer + 1)[0];
	    //wordpointer++; // Added by me!
	    //((short[])&returnvalue + 1)[0] = ((short[])wordpointer)[0];
		var Right:int = (framebuffer[wordpointer] & 0x0000FFFF);
		wordpointer++;
		var Left:int = (framebuffer[wordpointer] & 0xFFFF0000);
		returnvalue = ((Right << 16) & 0xFFFF0000) | ((Left >>> 16)& 0x0000FFFF);
	
	    returnvalue >>>= 48 - sum;	// returnvalue >>= 16 - (number_of_bits - (32 - bitindex))
	    returnvalue &= bitmask[number_of_bits];
	    bitindex = sum - 32;
	    return returnvalue;
	}
	
		/**
		 * Set the word we want to sync the header to.
		 * In Big-Endian byte order
		 */
		public function set_syncword(syncword0:int):void
		{
			syncword = syncword0 & 0xFFFFFF3F;
			single_ch_mode = ((syncword0 & 0x000000C0) == 0x000000C0);
		}
		/**
		 * Reads the exact number of bytes from the source
		 * input stream into a byte array.
		 *
		 * @param b		The byte array to read the specified number
		 *				of bytes into.
		 * @param offs	The index in the array where the first byte
		 *				read should be stored.
		 * @param len	the number of bytes to read.
		 *
		 * @exception BitstreamException is thrown if the specified
		 *		number of bytes could not be read from the stream.
		 */
		private function readFully(b:Array, offs:int, len:int):int
		{		
			var nRead:int = 0;
			try
			{
				while (len > 0)
				{
					var bytesread:int = source.read(b, offs, len);
					if (bytesread == -1)
					{
						while (len-->0)
						{
							b[offs++] = 0;
						}
						break;
						//throw newBitstreamException(UNEXPECTED_EOF, new EOFException());
					}
					nRead = nRead + bytesread;
					offs += bytesread;
					len -= bytesread;
				}
			}
			catch (ex:Error)
			{
				throw new BitstreamException(STREAM_ERROR, ex);
			}
			return nRead;
		}
	
		/**
		 * Simlar to readFully, but doesn't throw exception when
		 * EOF is reached.
		 */
		private function readBytes(b:Array, offs:int, len:int):int
		{
			var totalBytesRead:int = 0;
			try
			{
				while (len > 0)
				{
					var bytesread:int = source.read(b, offs, len);
					if (bytesread == -1)
					{
						break;
					}
					totalBytesRead += bytesread;
					offs += bytesread;
					len -= bytesread;
				}
			}
			catch (ex:Error)
			{
				throw new BitstreamException(STREAM_ERROR, ex);
			}
			return totalBytesRead;
		}
	}
}
