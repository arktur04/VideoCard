// Утилита предназначена для конвертации файла шрифта 14x8 в формат 16х8 путем добавления двух нулевых байт после каждого  14-го байта

#include <fstream>
#include <vector>
#include <sstream>
#include <string>
#include <iostream>
#include <iomanip>

std::vector<unsigned char> readFile(const char* filename)
{
    // open the file:
    std::streampos fileSize;
    std::ifstream file(filename, std::ios::binary);
    // get its size:
    file.seekg(0, std::ios::end);
    fileSize = file.tellg();
    file.seekg(0, std::ios::beg);
    // read the data:
	std::vector<unsigned char> fileData(fileSize);
    file.read((char*) &fileData[0], fileSize);
    return fileData;
}

int main()
{
	std::vector<unsigned char> inputFile = readFile("866.014");
	std::ofstream out("866.014.016", std::ofstream::out);
	unsigned num = 0;
	for(auto ch:inputFile)
	{
		out << ch;
		if(++num % 14 == 0)
		{
			out << char(0) << char(0);
		}
	}
	out.close();
    return 0;
}
