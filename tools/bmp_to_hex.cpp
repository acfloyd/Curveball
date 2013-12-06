#include <iostream>
#include <fstream>
#include <stdint.h>
#include <stdlib.h>

using namespace std;

#define width 512

////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {

  // check args
  if(argc != 3) {
    cout << "Usage: bmp_to_hex <input_file> <output_file>" << endl;
    exit(-1);
  }

  // open files
  ifstream in;
  ofstream out;
  
  in.open(argv[1], ifstream::binary);
  if(!in.is_open()) {
    cout << "Could not open file: " << argv[1] << endl;
    exit(-1);
  }

  out.open(argv[2], ofstream::out | ofstream::trunc);
  if(!out.is_open()) {
    cout << "Could not open file: " << argv[2] << endl;
    exit(-1);
  }

  // read in data file
  in.seekg(0, in.end);
  unsigned int length = in.tellg();
  cout << length << endl;
  in.seekg(0, in.beg);

  unsigned char* buffer = new unsigned char[length];
  in.read((char*) buffer, length);

  // find data start
  uint32_t data_start = buffer[0x0A];

  cout << data_start << endl;

  // write out hex data
  for(int i = length - width * 3; i >= (int) data_start; i -= width * 3) {
    for(unsigned int j = 0; j < width * 3; j += 3) {
      uint32_t next_pixel = buffer[i+j] | (buffer[i+j+1] << 8) | (buffer[i+j+2] << 16);
      if(next_pixel)
        out << "1" << endl;
      else
        out << "0" << endl;
    }
  } 

  out.close();
  in.close();
}

