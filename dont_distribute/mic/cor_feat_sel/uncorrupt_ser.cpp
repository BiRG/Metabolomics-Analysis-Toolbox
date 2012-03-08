#include <iostream>
#include <fstream>
#include <cstdlib>
#include <queue>


//Return true if c was gotten successfully
bool buffGetC(char& c, std::ifstream& in){
  static std::deque<char> already_read;
  if(already_read.size() > 0){
    //Pop the next character from the queue and return it
    c = already_read.front(); already_read.pop_front();
    return true;;
  }else{
    //Refill the queue
    const unsigned bufsize = 65535;
    char buf[bufsize];
    in.read(buf, bufsize);
    std::streamsize num_read = in.gcount();
    already_read.insert(already_read.end(), buf, buf+num_read);

    if(already_read.size() > 0){
      c = already_read.front(); already_read.pop_front();
      return true;
    }else{
      return false;
    }
  }
}

int main(int argc, char**argv){
  if(argc != 3){
    std::cerr << "Usage: uncorrupt_ser input_file output_file\n"
	      << "Reads from input_file until it finds the byte sequence "
	      << "172 237 0 5, which is the magic number (172 237) for java "
	      << "serialization followed by the specification version 5. "
	      << "Copies all bytes starting at that sequence into "
	      << "output_file. Output file will be overwritten.\n";
    return -1;
  }

  std::ifstream in(argv[1]);
  if(!in){
    std::cerr << "Error: Could not open " << argv[1] << " for reading.\n";
    return -1;
  }

  //Find the header
  unsigned bytes_read = 0;
  unsigned gb_read = 0;
  std::deque<unsigned char> last4Chars;
  bool foundHeader = false;

  char c; 

  while(buffGetC(c,in)){
    ++bytes_read;
    if(bytes_read == 1024*1024*1024){
      bytes_read = 0;
      ++gb_read;
      std::cerr << "Read " << gb_read << "GiB. ";
    }
    while(last4Chars.size() > 3){
      last4Chars.pop_front();
    }
    last4Chars.push_back(c); //Note the conversion to unsigned
    
    if(last4Chars.size() == 4){
      if(last4Chars[0] == 172 && 
	 last4Chars[1] == 237 &&
	 last4Chars[2] == 0 &&
	 last4Chars[3] == 5){
	foundHeader = true;
	break;
      }
    }
  }

  if(!foundHeader){
    std::cerr << "Could not find java serialization version 5 header in file " 
	      << argv[1] <<"\n";
    return -1;
  }

  //Copy the rest of the file
  std::ofstream out(argv[2]);
  if(!out){
    std::cerr << "Error: Could not open " << argv[2] << " for writing.\n";
    return -1;
  }

  //Write the header
  out.put(172); out.put(237); out.put(0); out.put(5);

  //Copy the rest of the file
  while(buffGetC(c,in)){
    out.put(c);
  }

  out.close();
  in.close();
}
