import streams, math, opengl, strutils, tables

# var bmpCache: seq[tuple[f: string, i: GLuint]] = @[] # a mapping of string to GLuint (textureID)

var bmpCache = initTable[string, GLuint]() # a mapping of string to GLuint (textureID)

proc parseBmp*( filePath: string ): GLuint =
  # var compare: tuple[f: string, i: GLuint] #container for the cache entries
  #
  # for i in low(bmpCache)..high(bmpCache):
  #   compare = bmpCache[i]
  #   if ( compare.f == filePath) :
  #     return compare.i # instead of reloading the BMP, just return the data.

  if bmpCache.hasKey(filePath):
    return bmpCache[filePath]


  #if we didn't find it in the cache
  var
    file: File

    # header variables
    hField : char
    hField2 : char
    size : int32
    extraInfo : int32 #this is reserved for the image prcoessor
    offset : int32
    dibSize : int32
    imageWidth : int32
    imageHeight : int32
    #DIB crap its 124 bytes

    #Here is what we want

  discard open(file, filePath)
  let fStream = newFileStream(file)

  hField = readChar(fStream)
  hField2 = readChar(fStream)

  size = readInt32(fStream)
  extraInfo = readInt32(fStream)
  offset = readInt32(fStream)

  dibSize = readInt32(fStream)
  imageWidth = readInt32(fStream)
  imageHeight = readInt32(fStream)

  var i = 0

  #echo( hField.int8 and hField2.int8 )#identify what type of DIP we are using
  #echo(dibSize)
  #echo(imageWidth)
  #echo(imageHeight)
  #echo()

  while i < offset-26 : # remove 14 because we've read in some data
    discard readChar(fStream) # jump to the actual image data
    inc(i)

  # we know that the format of the bmps is R8 B8 G8

  i = 0
  #Essentially the rows of a bitmap get padded, so we need to go through each
  #row and sift through the padding
  #It gets padded so that the bytes are divisible by 4
  var
    index = 0 # size of the return sequence, without the padding
    padding = (imageWidth * 4 - (imageWidth * 3) mod 4) mod 4 # function for
    #finding the padding. the data needs to fit in something divisible by 4 bytes

  var tempSeq = newSeq[uint8]((imageWidth*imageHeight)*3)
  while i < size-offset : # the amount of room the data takes up
    if ( i mod (imageWidth*3+padding) <= (imageWidth*3)-1 ) : #-1 because i is zero'd
      tempSeq[index] = readInt8(fStream).uint8 # bitmaps have some padding
      inc(index)
      # they neeed to be able to be stored in a number of bytes divisible by 4
      # example 2x2 picture has 6 bytes in the first row, with a padding of 2 and
      # 6 bytes in the second row with a padding of 2
    else :
      discard readInt8(fStream).uint8 # toss the padding byte
    inc(i) # make an array with all the data in it

  #i = 0

  #while i < 12 :
    #if ( (i mod 3) == 0 ) :
    #  echo("-----")
    #echo(tempSeq[i])
    #inc(i)
  #unfortunately i don't think we are done.
  #we have all the pixel data, except it isn't usable because its in a slighly
  #different ordering.


  var finalSeq = newSeq[uint8]((imageWidth*imageHeight)*4)
  var j = 0

  i = 1

  while i <= (imageWidth*imageHeight)*4 : # this routine correts the data from
    if ( i mod 4 > 0 ) :                  # BRG to RGBA
      if ( tempSeq.len-i+j >= 0 ) :
        finalSeq[i-1] = tempSeq[tempSeq.len-i+j]
    else :
      finalSeq[i-1] = 255
      inc(j)
    inc(i)

  var textureID: GLuint

  glGenTextures(1, addr textureID)
  echo($textureID)
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, addr finalSeq[0])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

  close(fStream)

  # var cache: tuple[f: string, i: GLuint]
  # cache.f = filePath
  # cache.i = textureID
  #
  # bmpCache.add(cache)

  bmpCache[filePath] = textureID

  return textureID
