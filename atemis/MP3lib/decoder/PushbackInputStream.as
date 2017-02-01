/*
 * 06/01/07 	By Jean-Denis Boivin 
 *				(jeandenis.boivin@gmail.com) From Team-AtemiS.com
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
	 * Recreate Java's PushbackInputStream function into ActionScript 3
	 */
	public final class PushbackInputStream extends FilterInputStream
	{
		
		protected var buf:Array;
		
		protected var pos:int;
		
	  /**
	   * Constructor
	   */
	  public function PushbackInputStream(inB:InputStream, size:int)
	  { 
	  	super(inB);
        if (size <= 0) {
            throw new Error("size <= 0");
        }
     	this.buf = new Array(size);
     	this.pos = size;
	  }
	 
	 /**
	  *  Read
	  */
	 public function readB():int {
	     //ensureOpen();
	     if (pos < buf.length) {
	         return buf[pos++] & 0xff;
	     }else{
	     	return readByte();
	     }
	 }
	 
	 /**
	  *  Unread
	  */ 
	 public function unread(b:Array, off:int, len:int):void {
		 if (len > pos) {
	         throw new Error("Push back buffer is full");
	     }
	     pos -= len;
	     position -= len;
	     System.arraycopy(b, off, buf, pos, len);
	 }
	 
	 /**
	  * READ 
	  */
	 public override function read(b:Array, off:int, len:int):int {

	     if ((off < 0) || (off > b.length) || (len < 0) ||
	         ((off + len) > b.length) || ((off + len) < 0)) {
	         throw new Error("Out of bound");
	     }
	 
	     if (len == 0) {
	         return 0;
	     }
	 
	     var avail:int = buf.length - pos;

	     /*if (avail > 0) {
	         if (len < avail) {
	         	avail = len;
	         }
	         System.arraycopy(buf, pos, b, off, avail);
	         pos += avail;
	         off += avail;
	         len -= avail;
	     }*/
	     if (len > 0) {
	         len = super.read(b, off, len);
	         if (len == -1) {
	        	 return avail == 0 ? -1 : avail;
	         }
	         //return avail + len;
	         return len;
	     }
	     return avail;
	   }
	}
}
