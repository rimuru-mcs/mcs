#include "process_helper.h"

#include <array>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

#if defined(_WIN32)
#define EQEMU_POPEN _popen
#define EQEMU_PCLOSE _pclose
#else
#define EQEMU_POPEN popen
#define EQEMU_PCLOSE pclose
#endif

std::string Process::execute(const std::string &cmd, bool return_result)
{
	if (!return_result) {
		std::system(cmd.c_str());
		return {};
	}

	const std::string command = cmd + " 2>&1";
	std::shared_ptr<FILE> pipe(EQEMU_POPEN(command.c_str(), "r"), EQEMU_PCLOSE);
	if (!pipe) {
		return "ERROR";
	}

	std::array<char, 256> buffer{};
	std::string result;
	while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe.get()) != nullptr) {
		result += buffer.data();
	}

	return result;
}
