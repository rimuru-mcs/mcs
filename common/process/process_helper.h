#ifndef EQEMU_PROCESS_HELPER_H
#define EQEMU_PROCESS_HELPER_H

#include <string>

// Small cross-platform command execution helper used by crash handling,
// database dump tooling, embedded Perl syntax checks, and sidecar helpers.
//
// This intentionally replaces the deleted legacy common/process.* files and
// the orphaned common/eqemu_process.* pair with a single Process declaration.
class Process {
public:
	static std::string execute(const std::string &cmd, bool return_result = true);
};

#endif // EQEMU_PROCESS_HELPER_H
