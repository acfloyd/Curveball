#include <fstream>
#include <iostream>
#include <string>
#include <stdint.h>
#include <stdlib.h>
#include <vector>
#include <sstream>

using namespace std;

#define width 640
#define height 480

////////////////////////////////////////////////////////////////////////////////

uint32_t swap32(uint32_t a) {
  
  unsigned char b1, b2, b3, b4;
  
  b1 = a & 0xFF;
  b2 = (a >> 8) & 0xFF;
  b3 = (a >> 16) & 0xFF;
  b4 = (a >> 24) & 0xFF;

  return ((uint32_t)b1 << 24) + ((uint32_t)b2 << 16) + ((uint32_t)b3 << 8) + (uint32_t) b4;
}

uint16_t swap16(uint32_t a) {
  
  unsigned char b1, b2;

  b1 = a & 0xFF;
  b2 = (a >> 8) & 0xFF;

  return ((uint16_t)b1 << 8) + (uint16_t) b2;
}

void print16(ofstream& out, uint16_t a) {
  out.write((char*) &a, 2);
}

void print32(ofstream& out, uint32_t a) {
  out.write((char*) &a, 4);
}

int main(int argc, char** argv) {

  // check args
  if(argc != 3) {
    cout << "Usage: hex_to_bmp <input_file> <output_file>" << endl;
    exit(-1);
  }

  // open files
  ofstream out;
  ifstream in;

  in.open(argv[1]);
  out.open(argv[2]);

  if(!in.is_open()) {
    cout << "Error opening file: " << argv[1] << endl;
    exit(-1);
  } else if(!out.is_open()) {
    cout << "Error opening file: " << argv[2] << endl;
    exit(-1);
  }

  char colors[height][width * 3];
  string line;
  stringstream ss;
  unsigned int row = 0; 
  unsigned int col = 0;

  // chop up line into chars
  while(getline(in, line) && row < height) {
    ss << hex << line;
    uint32_t val;
    ss >> val;

    char b1 = static_cast<char>(val & 0xFF);
    char b2 = static_cast<char>((val >> 8) & 0xFF);
    char b3 = static_cast<char>((val >> 16) & 0xFF);

    colors[row][col++] = b1;
    colors[row][col++] = b2;
    colors[row][col++] = b3;
    if(col >= width * 3) {
      col = 0;
      row++;
    }
  }

  // build header
  print16(out,0x4D42);
  print32(out,43 + height * width * 3);
  print16(out,0);
  print16(out,0);
  print32(out,0x36);
  print32(out,40);
  print32(out,width);
  print32(out,height);
  print16(out,1);
  print16(out,24);
  print32(out,0);
  print32(out,height * width * 3);
  print32(out,0xB13);
  print32(out,0xB13);
  print32(out,0);
  print32(out,0);


  // write bitmap
  for(int i = height - 1;  i >= 0; i--)
    for(int j = 0; j < width * 3; j++)
      out.write( &colors[i][j], 1);

  out.close();
  in.close();
}

