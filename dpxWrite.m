% writes dpx file
function dpxWrite(filename, data)

    if (exist(filename, 'file') == 2)
        overwrite = input('File exists. Would you like to overwrite it? (1 = Yes): ');
        
        if (overwrite ~= 1)
            return;
        end
    end

    fp = fopen(filename, 'w');
    
    if (fp == -1)
       disp('File could not be opened. Exiting.');
       return;
    end
    
    header = data{1};
    imageData = data{2};
    
    offset = uint32(header(2));
    depth = bitand(header(201), 255);
    xRes = uint32(header(194));
    yRes = uint32(header(195));
    packing = bitand(bitshift(header(202), -16), 65535);
    descriptor = bitand(bitshift(header(201), -24), 255);
    
    writeHeader(fp, header);
    writeImageData(fp, imageData, offset, depth, xRes, yRes, packing, descriptor);
    fclose(fp);
    
% write header
function writeHeader(fp, header)
    for i = 1:length(header)
        fwrite(fp, header(i), 'uint32', 0, 'b');
    end

    
% write the image data    
function writeImageData(fp, data, offset, depth, xRes, yRes, packing, descriptor)

    depthType = getDepthType(depth);            
    fseek(fp, offset, 'bof');
    compLen = getCompLen(descriptor);
    numElements = xRes*yRes*compLen;
    dataItr = 1;
    
    
    if (depth == 10 || depth == 12)
        
        % datum is sequential 
        if (packing == 0)
            lnBitLen = xRes*compLen*depth;
            pad = 32 - mod(lnBitLen, 32);
            
            for i = 1:yRes
                
                % write sequential data followed
                for j = 1:xRes
                    fwrite(fp, data(dataItr), depthType, 0, 'b');
                    dataItr = dataItr + 1;
                end
                
                % write padding
                for j = 1:pad
                    fwrite(fp, 0, 'ubit1', 0, 'b');
                end
            end
        
        % Packing type 1
        elseif (packing == 1)
   
            outBuffer = createBufferPacking(data, depth, numElements);
            fwrite(fp, outBuffer, 'uint32', 0, 'b');
            
        else
            disp('Cannot handle this type of packing');
        end
    else
        for i = 1:numElements
            fwrite(fp, data(dataItr), depthType, 0, 'b');
            dataItr = dataItr + 1;
        end
    end
    
    
function outBuffer = createBufferPacking(data, depth, numElements)
        
    % numbers left to fill in word
    if (depth == 10)
        addToEnd = mod(numElements, 3);
        buffLen = floor(numElements/3);
    else
        addToEnd = mod(numElements, 2);
        buffLen = floor(numElements/2);
    end
            
    if (addToEnd == 0)
    	outBuffer = zeros(1, buffLen);
    else
        buffLen = buffLen + 1;
        outBuffer = zeros(1, buffLen);
    end
    
    if (depth == 10)
    
        for i = 1:numElements
            buffItr = floor((double(i) - 1)/3) + 1;
            j = mod((i - 1), 3);
            temp = uint32(data(i));

            if (j == 0)
                temp = bitshift(temp, 2);
            elseif (j == 1)
                temp = bitshift(temp, 12);
            else
                temp = bitshift(temp, 22);
            end

            outBuffer(buffItr) = bitor(outBuffer(buffItr), temp);     
        end
    
    else
        
        for i = 1:numElements
            buffItr = floor((double(i) - 1)/2) + 1;
            j = mod((i - 1), 2);
            temp = uint32(data(i));

            if (j == 0)
                temp = bitshift(temp, 4);
            else
                temp = bitshift(temp, 20);
            end

            outBuffer(buffItr) = bitor(outBuffer(buffItr), temp);     
        end
        
    end

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