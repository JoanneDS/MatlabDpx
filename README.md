MatlabDpx
=========

Read and writing dpx files in Matlab

=========

To use dpxRead and dpxWrite make sure that the files are visible to Matlab. The file system can be navigated through the command line using "cd DIRECTORY_NAME".

dpxRead only takes in the dpx filename as an argument and returns a data structure of cells. The cell is separated into the header and image data. For example, the syntax would be data = dpxRead('Image1.dpx'). The image data is held in the second cell of the returned structure. For example, the image data could be accessed with image = data{2}.

dpxWrite takes in two arguments. The first is the output file name, and the second is the data structure returned from dpxRead. The entire data structure is needed because the header is require to write the file, but the second cell can be modified. If the file aleady exists, press 1 to overwrite it when prompted.

Here could be a use case.

data = dpxRead('in.dpx');
imageData = data{2};

modified = data{2}/2;

data{2} = modified;
dpxWrite(out.dpx, data);
