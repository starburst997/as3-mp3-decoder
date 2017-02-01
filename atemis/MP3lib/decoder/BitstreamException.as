/*
 * 06/01/07 	Ported to ActionScript 3. By Jean-Denis Boivin 
 *				(jeandenis.boivin@gmail.com) From Team-AtemiS.com
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
	 * Instances of <code>BitstreamException</code> are thrown 
	 * when operations on a <code>Bitstream</code> fail. 
	 * <p>
	 * The exception provides details of the exception condition 
	 * in two ways:
	 * <ol><li>
	 *		as an error-code describing the nature of the error
	 * </li><br></br><li>
	 *		as the <code>Throwable</code> instance, if any, that was thrown
	 *		indicating that an exceptional condition has occurred. 
	 * </li></ol></p>
	 * 
	 * @since 0.0.6
	 * @author MDM	12/12/99
	 */
	
	public class BitstreamException extends JavaLayerException
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
		 * 
		 */
		static public const BITSTREAM_LAST:int = 0x1ff;
		
		private var errorcode:int = UNKNOWN_ERROR;
		
		public function BitstreamException(errorcode:Object, t:Error = null)
		{
			if (errorcode is int) {
				super(getErrorString(errorcode as int), t);
				this.errorcode = errorcode as int;
			}else if (errorcode is String) {
				throw new Error(errorcode as String);	
			}
		}
		
		public function getErrorCode():int
		{
			return errorcode;	
		}
		
		
		static public function getErrorString(errorcode:int):String
		{
			// REVIEW: use resource bundle to map error codes
			// to locale-sensitive strings.
			var a:Array = new Array();
			return "Bitstream errorcode "+errorcode.toString(16);
		}
		
	}
}
