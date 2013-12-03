#include <iostream>
#include <fstream>
#include <iomanip>
#include <stdint.h>
#include <stdlib.h>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {

  // check args
  if(argc != 3) {
    cout << "Usage: raw_to_hex <input_file> <output_file>" << endl;
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
  in.seekg(0, in.beg);

  unsigned char* buffer = new unsigned char[length];
  in.read((char*) buffer, length);

  // write out hex data to file
  for(unsigned int i = 0; i < length; i++) {
    out << hex << setfill('0') << setw(2) << (unsigned int) buffer[i] <<  endl;
  }

  out.close();
  in.close();

}
