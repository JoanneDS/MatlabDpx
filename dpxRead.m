
% reads dpx file
function fileData = dpxRead(filename)



    % open file
    fp = fopen(filename);
    if (fp == -1)
       disp('File could not be opened. Exiting.');
       return;
    end  
    
    % Get byte order 0 = forward, 1 = reverse
    order = getOrder(fp);
    if (order == -1)
        disp('Incorrect syntax. File could not be read. Exiting');
        return;
    end
    
    % Field 4 Data Offset    
    dataOffset = getInfo(fp, 4, 4, 'U32', order);
    fprintf('Offset: %u\n', dataOffset);
    
    % Field 3 Version Number
    version = getInfo(fp, 8, 8, 'ASCII', order);
    fprintf('Version: %s\n', version);
    
    % Field 4 Total Image Size
    fileSize = getInfo(fp, 16, 4, 'U32', order);
    fprintf('Image Size (bytes): %u\n', fileSize);
    
    % Field 5 Ditto Key
    dittoKey = getInfo(fp, 20, 4, 'U32', order);
    fprintf('Ditto Key: %u\n', dittoKey);
    
    % Field 6 Generic Section Header Length (bytes)
    genericHeaderLen = getInfo(fp, 24, 4, 'U32', order);
    fprintf('Generic Section Header Length (bytes): %u\n', genericHeaderLen);
    
    % Field 7 Industry Specific Header Length (bytes)
    industryHeaderLen = getInfo(fp, 28, 4, 'U32', order);
    fprintf('Industry Specific Header Length (bytes): %u\n', industryHeaderLen);
    
    % Field 8 User Defined Header Length (bytes)
    userHeaderLen = getInfo(fp, 32, 4, 'U32', order);
    fprintf('User Defined Header Length (bytes): %u\n', userHeaderLen);
    
    % Field 9 Image Filename
    imageFilename = getInfo(fp, 36, 100, 'ASCII', order);
    fprintf('Image Filename: %s\n', imageFilename);
    
    % Field 10 Creation date/time
    creationTime = getInfo(fp, 136, 24, 'ASCII', order);
    fprintf('Creation Time: %s\n', creationTime);
    
    % Field 12 Creator
    creator = getInfo(fp, 160, 100, 'ASCII', order);
    fprintf('Creator: %s\n', creator);
    
    % Field 13 Project Name
    projectName = getInfo(fp, 260, 200, 'ASCII', order);
    fprintf('Project Name: %s\n', projectName);
    
    % Field 14 Right to Use Copyright Statement
    copywriteStatement = getInfo(fp, 460, 200, 'ASCII', order);
    fprintf('Right to Use Copyright Statement: %s\n', copywriteStatement);
    
    % Field 15
    encryptionKey = getInfo(fp, 660, 4, 'U32', order);
    fprintf('Encryption Key: %x\n', encryptionKey);
    
    % Image Information Header
    
    % Field 17 Image Orientation
    orientation = getInfo(fp, 768, 2, 'U16', order);
    fprintf('Image Orientation: %u\n', orientation);
    
    % Field 18 Number of Image Elements (1 - 8)
    numElements = getInfo(fp, 770, 2, 'U16', order);
    fprintf('Number of Image Elements: %u\n', numElements);
    
    % Field 19 Number of Pixels per Line
    pixelsPerLine = getInfo(fp, 772, 4, 'U32', order);
    fprintf('Pixels per Line: %u\n', pixelsPerLine);

    % Field 20 Lines per Image Element
    linesPerElement = getInfo(fp, 776, 4, 'U32', order);
    fprintf('Lines per Image Element: %u\n', linesPerElement);
    
    % Field 21 Data Structure for Image Element

    dataSign = zeros(1, 8);
    lowData = zeros(1, 8);
    lowQuantity = zeros(1, 8);
    highData = zeros(1, 8);
    highQuantity = zeros(1, 8);
    descriptor = zeros(1, 8);
    transferChar = zeros(1, 8);
    colorSpec = zeros(1, 8);
    bitDepth = zeros(1, 8);
    packing = zeros(1, 8);
    encoding = zeros(1, 8);
    offsetToData = zeros(1, 8);
    linePadding = zeros(1, 8);
    imagePadding = zeros(1, 8);
    descImageElement = [];
    
    for i=1:numElements

        % need offset as if we have multiple elements
        elementOffset = 72*(i - 1);
        
        % Field 21.1 Data Sign
        dataSign(i) = getInfo(fp, 780 + elementOffset, 4, 'U32', order);
        fprintf('Data Sign %d: %u\n', i, dataSign(i));

        % Field 21.2 Reference Low Data Code Value
        lowData(i) = getInfo(fp, 784 + elementOffset, 4, 'U32', order);
        fprintf('Reference Low Data Code Value %d: %u\n', i, lowData(i));

        % Field 21.3 Reference Low Quantity Represented
        lowQuantity(i) = getInfo(fp, 788 + elementOffset, 4, 'U32', order);
        fprintf('Reference Low Quantity Represented %d: %u\n', i, lowQuantity(i));

        % Field 21.4 Reference High Data Code Value
        highData(i) = getInfo(fp, 792 + elementOffset, 4, 'U32', order);
        fprintf('Reference High Data Code Value %d: %u\n', i, highData(i));

        % Field 21.5 Reference Low Quantity Represented
        highQuantity(i) = getInfo(fp, 796 + elementOffset, 4, 'U32', order);
        fprintf('Reference High Quantity Represented %d: %u\n', i, highQuantity(i));

        % Field 21.6 Descriptor
        descriptor(i) = getInfo(fp, 800 + elementOffset, 1, 'U8', order);
        fprintf('Descriptor %d: %u\n', i, descriptor(i));

        % Field 21.7 Transfer Characteristics
        transferChar(i) = getInfo(fp, 801 + elementOffset, 1, 'U8', order);
        fprintf('Transfer Characteristics %d: %u\n', i, transferChar(i));

        % Field 21.8 Colorimetric Specification
        colorSpec(i) = getInfo(fp, 802 + elementOffset, 1, 'U8', order);
        fprintf('Transfer Characteristics %d: %u\n', i, colorSpec(i));

        % Field 21.9 Bit Depth
        bitDepth(i) = getInfo(fp, 803 + elementOffset, 1, 'U8', order);
        fprintf('Bit Depth %d: %u\n', i, bitDepth(i));

        % Field 21.10 Packing
        packing(i) = getInfo(fp, 804 + elementOffset, 2, 'U16', order);
        fprintf('Packing %d: %u\n', i, packing(i));

        % Field 21.11 Encoding
        encoding(i) = getInfo(fp, 806 + elementOffset, 2, 'U16', order);
        fprintf('Encoding %d: %u\n', i, encoding(i));

        % Field 21.12 Offset to Data
        offsetToData(i) = getInfo(fp, 808 + elementOffset, 4, 'U32', order);
        fprintf('Offset to Data %d: %u\n', i, offsetToData(i));

        % Field 21.13 End of Line Padding
        linePadding(i) = getInfo(fp, 812 + elementOffset, 4, 'U32', order);
        fprintf('End-of-line padding %d: %u\n', i, linePadding(i));

        % Field 21.14 End of Image Padding
        imagePadding(i) = getInfo(fp, 816 + elementOffset, 4, 'U32', order);
        fprintf('End-of-image padding %d: %u\n', i, imagePadding(i));

        % Field 21.15 Description of image element
        descImageElement = [ descImageElement, getInfo(fp, 820 + elementOffset, 32, 'ASCII', order) ];
        fprintf('Description of image element %d: %s\n', i, descImageElement(i));
        
    end

    
    % Image information header 
    
    % Field 30 X Offset
    xOffset = getInfo(fp, 1408, 4, 'U32', order);
    fprintf('X Offset: %u\n', xOffset);
    
    % Field 31 Y Offset
    yOffset = getInfo(fp, 1412, 4, 'U32', order);
    fprintf('Y Offset: %u\n', yOffset);
    
    % Field 32 X Center
    xCenter = getInfo(fp, 1416, 4, 'R32', order);
    fprintf('X Center: %d\n', xCenter);
    
    % Field 33 Y Center
    yCenter = getInfo(fp, 1420, 4, 'R32', order);
    fprintf('Y Center: %d\n', yCenter);
    
    % Field 34 X Original Size
    xOrigSize = getInfo(fp, 1424, 4, 'U32', order);
    fprintf('X Original Size: %u\n', xOrigSize);
    
    % Field 35 Y Original Size
    yOrigSize = getInfo(fp, 1428, 4, 'U32', order);
    fprintf('Y Original Size: %u\n', yOrigSize);
    
    % Field 36 Source Image Filename
    srcImageFilename = getInfo(fp, 1432, 100, 'ASCII', order);
    fprintf('Source Image Filename: %s\n', srcImageFilename);
    
    % Field 37 Source Image Date
    srcImageDate = getInfo(fp, 1532, 24, 'ASCII', order);
    fprintf('Source Image Date: %s\n', srcImageDate);
    
    % Field 38 Input Device Name
    inputDevice = getInfo(fp, 1556, 32, 'ASCII', order);
    fprintf('Input Device Name: %s\n', inputDevice);
    
    % Field 39 Input Device Serial Number
    inputDeviceSerial = getInfo(fp, 1588, 32, 'ASCII', order);
    fprintf('Input Device Serial Number: %s\n', inputDeviceSerial);
    
    % Field 40 Border Validity
    borderValidity = getInfo(fp, 1620, 8, 'U16', order);
    fprintf('Border Validity XL: %u XR: %u YT: %u YB: %u\n', borderValidity(1), borderValidity(2), borderValidity(3), borderValidity(4));
    
    % Field 41 Pixel Aspect Ratio
    pixelAspectRatio = getInfo(fp, 1628, 8, 'U32', order);
    fprintf('Pixel Aspect Ratio Horizontal: %u Vertical: %u\n ', pixelAspectRatio(1), pixelAspectRatio(2));
    
    % Field 42 Data structure for additional source image information
    
    % Field 42.1 X Scanned Size
    xScannedSize = getInfo(fp, 1636, 4, 'R32', order);
    fprintf('X Scanned Size: %d\n', xScannedSize);
    
    % Field 42.2 Y Scanned Size
    yScannedSize = getInfo(fp, 1640, 4, 'R32', order);
    fprintf('Y Scanned Size: %d\n', yScannedSize);
    
    % Motion-picture Film Information Header
    
    % Field 43 Film mfg. ID Code
    filmmfg = getInfo(fp, 1664, 2, 'ASCII', order);
    fprintf('Film mfg. ID Code: %s\n', filmmfg);
    
    % Field 44 Film Type
    filmType = getInfo(fp, 1666, 2, 'ASCII', order);
    fprintf('Film Type: %s\n', filmType);
    
    % Field 45 Offset in Perfs
    offsetPerfs = getInfo(fp, 1668, 2, 'ASCII', order);
    fprintf('Offset in Perfs: %s\n', offsetPerfs);
    
    % Field 47 Prefix
    prefix = getInfo(fp, 1670, 6, 'ASCII', order);
    fprintf('Prefix: %s\n', prefix);
    
    % Field 48 Count
    count = getInfo(fp, 1676, 4, 'ASCII', order);
    fprintf('Count: %s\n', count);
    
    % Field 49 Format
    format = getInfo(fp, 1680, 32, 'ASCII', order);
    fprintf('Format: %s\n', format);
    
    % Field 50 Frame Position in Sequence
    framePosSeq = getInfo(fp, 1712, 4, 'U32', order);
    fprintf('Frame Position in Sequence: %u\n', framePosSeq);
    
    % Field 51 Sequence Length (frames)
    seqLength = getInfo(fp, 1716, 4, 'U32', order);
    fprintf('Sequence Length (frames): %u\n', seqLength);
    
    % Field 52 Held Count
    heldCount = getInfo(fp, 1720, 4, 'U32', order);
    fprintf('Held Count: %u\n', heldCount);
    
    % Field 53 Frame Rate of Original (fps)
    fpsOriginal = getInfo(fp, 1724, 4, 'R32', order);
    fprintf('Frame Rate of Original (fps): %d\n', fpsOriginal);
    
    % Field 54 Shuttle Angle (degrees)
    shuttleAngle = getInfo(fp, 1728, 4, 'R32', order);
    fprintf('Shuttle Angle (degrees): %d\n', shuttleAngle);
    
    % Field 55 Frame Identification
    frameID = getInfo(fp, 1732, 32, 'ASCII', order);
    fprintf('Frame Identification: %s\n', frameID);
    
    % Field 56 Slate Information
    slateInfo = getInfo(fp, 1764, 100, 'ASCII', order);
    fprintf('Slate Information: %s\n', slateInfo);
    
    % Television Information Header
    
    % Field 58 SMPTE Time Code
    SMPTETimeCode = getInfo(fp, 1920, 4, 'U32', order);
    fprintf('SMPTE Time Code: %u\n', SMPTETimeCode);
    
    % Field 59 SMPTE User Bits
    SMPTEUserBits = getInfo(fp, 1924, 4, 'U32', order);
    fprintf('SMPTE User Bits: %u\n', SMPTEUserBits);
    
    % Field 60 Interlace
    interlace = getInfo(fp, 1928, 1, 'U8', order);
    fprintf('Interlace: %u\n', interlace);
    
    % Field 61 Field Number
    fieldNum = getInfo(fp, 1929, 1, 'U8', order);
    fprintf('Field Number: %u\n', fieldNum);
    
    % Field 62 Video Signal Standard
    vidSigStnd = getInfo(fp, 1930, 1, 'U8', order);
    fprintf('Video Signal Standard: %u\n', vidSigStnd);
    
    % Field 63 Byte Alignment
    zero = getInfo(fp, 1931, 1, 'U8', order);
    fprintf('Byte Alignment: %u\n', zero);
    
    % Field 64 Horizontal Sampling Rate (Hz)
    horzSampleRate = getInfo(fp, 1932, 4, 'R32', order);
    fprintf('Horizontal Sampling Rate (Hz): %d\n', horzSampleRate);
    
    % Field 65 Verticle Sampling Rate (Hz)
    vertSampleRate = getInfo(fp, 1936, 4, 'R32', order);
    fprintf('Verticle Sampling Rate (Hz): %d\n', vertSampleRate);
    
    % Field 66 Temporal Sampling Rate (Hz)
    tempSampleRate = getInfo(fp, 1940, 4, 'R32', order);
    fprintf('Temporal Sampling Rate (Hz): %d\n', tempSampleRate);
    
    % Field 67 Time Offset from Sync to First Pixel (ms)
    timeOffsetSync = getInfo(fp, 1944, 4, 'R32', order);
    fprintf('Time Offset from Sync to First Pixel (ms): %d\n', timeOffsetSync);
    
    % Field 68 Gamma
    gamma = getInfo(fp, 1948, 4, 'R32', order);
    fprintf('Gamma: %d\n', gamma);
    
    % Field 69 Black Level
    blackLevel = getInfo(fp, 1952, 4, 'R32', order);
    fprintf('Black Level: %d\n', blackLevel);
    
    % Field 70 Black Gain
    blackGain = getInfo(fp, 1956, 4, 'R32', order);
    fprintf('Black Gain: %d\n', blackGain);
    
    % Field 71 Breakpoint
    breakpoint = getInfo(fp, 1960, 4, 'R32', order);
    fprintf('Breakpoint: %d\n', breakpoint);
    
    % Field 72 White Level
    whiteLevel = getInfo(fp, 1964, 4, 'R32', order);
    fprintf('White Level: %d\n', whiteLevel);
    
    % Field 73 Integration Time
    integTime = getInfo(fp, 1968, 4, 'R32', order);
    fprintf('Integration Time: %d\n', integTime);
    
    
    
    
    % Field 77 Image data
      
    frewind(fp);
    headerData = fread(fp, dataOffset/4, 'uint32', 0, 'b');

    imageData = getImageData(fp, dataOffset, bitDepth(1), pixelsPerLine, linesPerElement, packing(1), descriptor(i));
    
    fileData = { headerData imageData };
    
   
% get the image data    
function data = getImageData(fp, offset, depth, xRes, yRes, packing, descriptor)

    depthType = getDepthType(depth);            
    fseek(fp, offset, 'bof');
    compLen = getCompLen(descriptor);
    numElements = xRes*yRes*compLen;
    data = zeros(1, numElements);
    dataItr = 1;
    
    
    if (depth == 10 || depth == 12)
        
        % datum is sequential 
        if (packing == 0)
            lnBitLen = xRes*compLen*depth;
            pad = 32 - mod(lnBitLen, 32);
            
            for i = 1:(yRes - 1)
                data(dataItr:(dataItr + xRes - 1)) = fread(fp, xRes, depthType);
                fread(fp, pad, 'ubit1');
                dataItr = dataItr + xRes;
            end            

        % packing type 1
        elseif (packing == 1)
            
            % Read 10 bit files with packing type 1
            if (depth == 10)
                
                buffLen = double(numElements)/3.0;
                if (mod(numElements, 3) ~= 0)
                    buffLen = buffLen + 1;
                end
                
                buffer = fread(fp, buffLen, 'uint32', 0, 'b');
            
                for i = 1:numElements
                    buffPos = floor((double(i) - 1)/3) + 1;
                    posInWord = mod(i - 1, 3);

                    temp = buffer(buffPos);

                    if (posInWord == 0)
                        t = bitshift(temp, -2); % BLUE
                    elseif (posInWord == 1)
                        t = bitshift(temp, -12); % GREEN
                    else
                        t = bitshift(temp, -22); % RED
                    end


                    data(i) = bitand(t, 1023);

                end
                
            % 12 bit files with packing type 1
            else
                
                buffLen = double(numElements)/2.0;

                if (mod(numElements, 2) ~= 0)
                    buffLen = buffLen + 1;
                end
                
                if (mod(numElements, 2) ~= 0)
                    buffLen = buffLen + 1;
                end
                
                buffer = fread(fp, buffLen, 'uint32', 0, 'b');
           
                for i = 1:numElements
                    buffPos = floor((double(i) - 1)/2) + 1;
                    posInWord = mod(i - 1, 2);

                    temp = buffer(buffPos);

                    if (posInWord == 0)
                        t = bitshift(temp, -4);
                    else
                        t = bitshift(temp, -20);
                    end

                    data(i) = bitand(t, 4095);
                    
                end
                
            end
                
        else
            disp('Cannot handle packing format.');
        end
    else
            data(1:numElements) = uint64(fread(fp, numElements, depthType, 0, 'b'));
    end
    
    fclose(fp);

% get string for bit depth
function depthType = getDepthType(depth)
    switch depth
        case 1
            depthType = 'ubit1';
        case 8
            depthType = 'ubit8';
        case 10
            depthType = 'ubit10';
        case 12
            depthType = 'ubit12';
        case 16
            depthType = 'ubit16';
        case 32
            depthType = 'ubit32';
        case 64
            depthType = 'ubit64';
        otherwise
            disp('Depth not valid');
            depthType = 'ubit32'
    end
    
% gets the length of a component
function compLen = getCompLen(desc)
    switch desc
        case 50
            compLen = 3;
        case 51
            compLen = 4;
        case 52
            compLen = 4;

        otherwise
            disp('Cannot handle descriptor type.');
            compLen = 1
    end    
    
% seeks to a position from the beginning of the file
function seek(fp, pos)
    status = fseek(fp, pos, 'bof');
    if (status ~= 0)
        disp('Error seeking file. Exiting');
    end

%returns the byte order. 0 = forward, 1 = reverse, -1 = wrong syntax
function order = getOrder(fp)
    seek(fp, 0);
    magicNum = fread(fp, 4, '*char');
    
    byteFor = ['S', 'D', 'P', 'X']';
    byteRev = ['X', 'P', 'D', 'S']';

    if isequal(magicNum, byteFor)
        order = 0;
    elseif isequal(magicNum, byteRev)
        order = 1;
    else
        order = -1;
    end
    
% gets file information
function value = getInfo(fp, offset, length, type, order)
    seek(fp, offset);
    
    if (strcmp(type,'U8'))
        count = length;
        if (order)
            value = uint8(fread(fp, count, 'uint8', 0, 'l'));
        else
            value = uint8(fread(fp, count, 'uint8', 0, 'b'));
        end
        
    elseif (strcmp(type,'U16'))
        count = length/2;
        if (order)
            value = uint16(fread(fp, count, 'uint16', 0, 'l'));
        else
            value = uint16(fread(fp, count, 'uint16', 0, 'b'));
        end
        
    elseif (strcmp(type,'U32'))
        count = length/4;
        if (order)
            value = uint32(fread(fp, count, 'uint32', 0 ,'l'));
        else
            value = uint32(fread(fp, count, 'uint32', 0, 'b'));
        end
        
    elseif (strcmp(type,'R32'))
        count = length/4;
        if (order)
            value = int32(fread(fp, count, 'int32', 0, 'l'));
        else
            value = int32(fread(fp, count, 'int32', 0, 'b'));
        end
        
    elseif (strcmp(type,'ASCII'))
        count = length;
        if (order)
            value = fliplr(char(fread(fp, count, '*char')'));
        else
            value = char(fread(fp, count, '*char')');
        end
     
    else
        str = sprintf('%s is not a known type.', type);
        disp(str);
        value = 0;
    end

    
    


