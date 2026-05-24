import os
import sys
import uuid
import glob

# Project Settings
PROJECTS = [
    # Server Apps
    {"name": "common", "type": "StaticLibrary", "dir": "common", "guid": "{0E58DBD0-A67D-3C9D-8811-B470515B85CE}", "category": "Libs"},
    {"name": "world", "type": "Application", "dir": "world", "guid": "{E1CD390E-CB82-34E2-8626-DC0D7EC458AD}", "category": "Apps"},
    {"name": "zone", "type": "Application", "dir": "zone", "guid": "{2981CAB5-2C0A-392E-89BD-2BF35794D6DD}", "category": "Apps"},
    {"name": "loginserver", "type": "Application", "dir": "loginserver", "guid": "{CBCBD890-689D-32C8-87E7-0E4B96EE9413}", "category": "Apps"},
    {"name": "ucs", "type": "Application", "dir": "ucs", "guid": "{CDC0E534-4F5A-3068-88C9-212EB85BD5B3}", "category": "Apps"},
    {"name": "queryserv", "type": "Application", "dir": "queryserv", "guid": "{DF417B59-69EC-3907-BEC9-1A849C3CDABE}", "category": "Apps"},
    {"name": "eqlaunch", "type": "Application", "dir": "eqlaunch", "guid": "{CA3144AD-D43C-344D-9313-9E3A0B0DCB1E}", "category": "Apps"},
    {"name": "shared_memory", "type": "Application", "dir": "shared_memory", "guid": "{564C7819-8737-3364-9B6D-C1EA5072D9C2}", "category": "Apps"},
    {"name": "hc", "type": "Application", "dir": "hc", "guid": "{5EFCA571-C38D-3CD6-933C-EE29A0CA5ACE}", "category": "Apps"},
    
    # Utilities
    {"name": "export_client_files", "type": "Application", "dir": "client_files/export", "guid": "{0C2D947A-C63D-319A-BBAE-E021B58F74A9}", "category": "Utils"},
    {"name": "import_client_files", "type": "Application", "dir": "client_files/import", "guid": "{C1DD478D-BA46-31CA-BAE8-AA39D8AE7A07}", "category": "Utils"},
    
    # Tests
    {"name": "cppunit", "type": "StaticLibrary", "dir": "tests/cppunit", "guid": "{6BD87D37-FFD7-307B-8FB0-EC39D18919EE}", "category": "Tests"},
    {"name": "tests", "type": "Application", "dir": "tests", "guid": "{78C95CA1-A619-39E6-BF93-F296BA77F78F}", "category": "Tests"},
    
    # Libs (Submodules)
    {"name": "fmt", "type": "StaticLibrary", "dir": "submodules/fmt", "guid": "{6969F5AB-F131-326C-B325-CF4F44A98269}", "category": "ThirdParty"},
    {"name": "uv_a", "type": "StaticLibrary", "dir": "submodules/libuv", "guid": "{E4231E3E-E5E3-317F-A31F-3F723DF84C7C}", "category": "ThirdParty"},
    {"name": "zlib-ng", "type": "StaticLibrary", "dir": "libs/zlibng", "guid": "{F7996CB1-94C3-3BB9-AF36-D5C8E870F919}", "category": "ThirdParty", "target_name": "zlib_ng1"},
    {"name": "perlbind", "type": "StaticLibrary", "dir": "libs/perlbind", "guid": "{6D8E17E8-047D-34A1-8143-DBBD25721AB0}", "category": "Libs"},
    {"name": "luabind", "type": "StaticLibrary", "dir": "libs/luabind", "guid": "{4117B448-64CC-33A8-8395-26F56D0C14D5}", "category": "Libs"},
    
    # recastnavigation
    {"name": "Detour", "type": "StaticLibrary", "dir": "submodules/recastnavigation/Detour", "guid": "{D0B6DB9D-26DF-3A4D-9931-1DB4DF4DF2A4}", "category": "ThirdParty"},
    {"name": "Recast", "type": "StaticLibrary", "dir": "submodules/recastnavigation/Recast", "guid": "{6A185FED-9B5C-34F4-AFAB-2BFCF1853633}", "category": "ThirdParty"},
    {"name": "DebugUtils", "type": "StaticLibrary", "dir": "submodules/recastnavigation/DebugUtils", "guid": "{9D1EEA29-1584-324F-BE9A-80BDD7F868E0}", "category": "ThirdParty"},
    {"name": "DetourCrowd", "type": "StaticLibrary", "dir": "submodules/recastnavigation/DetourCrowd", "guid": "{04130B46-0267-39AE-9430-7AE0CF82F124}", "category": "ThirdParty"},
    {"name": "DetourTileCache", "type": "StaticLibrary", "dir": "submodules/recastnavigation/DetourTileCache", "guid": "{E0F32B73-A0CB-3040-B573-1177C38A841E}", "category": "ThirdParty"},
]

def normalize_guid(value, with_braces=True):
    """Return a valid uppercase Visual Studio GUID string."""
    raw = str(value).strip().strip("{}").upper()
    parsed = uuid.UUID(raw)
    text = str(parsed).upper()
    return f"{{{text}}}" if with_braces else text

def project_exists(project):
    return os.path.isdir(project.get("dir", ""))

def active_projects():
    active = []
    for project in PROJECTS:
        if project_exists(project):
            active.append(project)
        else:
            print(f"Skipping {project['name']}: missing directory {project['dir']}")
    return active

def all_static_library_projects(projects):
    return [p for p in projects if p.get("type", "Application") == "StaticLibrary"]

def to_rel(path):
    if not path: return ""
    path = path.replace("\\", "/")
    # If path starts with root, make it relative to code/
    root = os.getcwd().replace("\\", "/")
    if path.startswith(root):
        rel = os.path.relpath(path, os.path.join(os.getcwd(), "code"))
    else:
        # Already relative to root probably?
        if os.path.isabs(path):
            rel = os.path.relpath(path, os.path.join(os.getcwd(), "code"))
        else:
            rel = os.path.join("..", path)
    return rel.replace("/", "\\")

def get_files_from_dir(directory, project_name):
    # Discovery
    print(f"Discovering files for {project_name} in {directory}...")
    found_files = []
    
    # Specific rules for complex libs
    if project_name == "uv_a":
        patterns = ["src/*.c", "src/win/*.c", "include/*.h"]
        for p in patterns:
            for f in glob.glob(os.path.join(directory, p)):
                found_files.append(os.path.relpath(f, os.getcwd()))
    elif project_name == "zlib-ng":
        patterns = ["*.c", "arch/x86/*.c", "*.h"]
        for p in patterns:
            for f in glob.glob(os.path.join(directory, p)):
                found_files.append(os.path.relpath(f, os.getcwd()))
    elif project_name == "fmt":
        # Exclude fmt.cc as it is a module interface and skip tests
        for root, dirs, files in os.walk(directory):
            if "test" in root.lower():
                continue
            for file in files:
                if file.endswith(('.cpp', '.cc', '.h', '.hpp')) and file != "fmt.cc":
                    full_path = os.path.join(root, file)
                    found_files.append(os.path.relpath(full_path, os.getcwd()))
    else:
        # Files that are #included in other files and therefore should NOT be compiled as separate translation units
        # These will still be added as headers if they exist in the headers list, or just ignored if they are .cpp
        always_exclude = [
            "zone_loot.cpp", 
            "sidecar_serve_http.cpp",
            "log_handler.cpp", 
            "test_controller.cpp", 
            "map_best_z_controller.cpp",
            "template.cpp",
            "template.h",
            "strings_legacy.cpp",
            "strings_misc.cpp",
            "database_update_manifest.cpp",
            "database_update_manifest_bots.cpp"
        ]
        
        # Directories that should be skipped entirely
        excl_dirs = ["socketlib", "sidecar_api_loot_simulator"]
        
        # Directories where all .cpp files are #included in a master file and shouldn't be compiled individually
        include_only_dirs = ["bot_commands", "gm_commands", "cli"]
        
        # Legacy root files that have modern versions in subdirs (only exclude if in root)
        legacy_root_files = ["eq_stream.cpp", "eq_stream_factory.cpp", "tcp_connection.cpp", "packetfile.cpp", "tcp_server.cpp", "eqmq.cpp", "eqmq.h"]
        
        for root, dirs, files in os.walk(directory):
            root_lower = root.replace("\\", "/").lower()
            parts = root_lower.split("/")
            
            # Skip noise
            if "test" in parts and project_name not in ["tests", "cppunit"]: continue
            if "cmake" in parts or ".github" in parts: continue
            
            # Skip entirely excluded directories
            if any(d in parts for d in excl_dirs):
                continue
                
            for file in files:
                file_lower = file.lower()
                rel_root = os.path.relpath(root, directory).replace("\\", "/")
                
                # Global exclusions for files included elsewhere
                if file_lower in [f.lower() for f in always_exclude]:
                    continue
                
                # Handle include_only_dirs
                # Exception: common/cli/eqemu_command_handler.cpp SHOULD be compiled
                if any(d in parts for d in include_only_dirs):
                    if not (project_name == "common" and "cli" in parts and file_lower == "eqemu_command_handler.cpp"):
                        # If it's a .cpp file in these dirs, skip it unless it's the exception
                        if file.endswith(('.cpp', '.c', '.cc')):
                            continue
                
                # Legacy root file exclusion
                if rel_root == "." and file_lower in [f.lower() for f in legacy_root_files]:
                    continue
                
                # Special case for world project excluding legacy files anywhere (as requested before)
                if project_name == "world" and file_lower in ["eqw_http_handler.cpp", "eqw_parser.cpp", "eqw.cpp", "http_request.cpp", "http_request.h", "eqw_parser.h", "eqw_http_handler.h"]:
                    continue

                if file.endswith(('.cpp', '.c', '.h', '.hpp', '.cc', '.natvis')):
                    full_path = os.path.join(root, file)
                    found_files.append(os.path.relpath(full_path, os.getcwd()))
    
    return found_files

def generate_vcxproj(project):
    name = project['name']
    proj_type = project['type']
    directory = project['dir']
    guid = normalize_guid(project['guid'])
    target_name = project.get('target_name', name)

    if not os.path.isdir(directory):
        print(f"Skipping {name}: missing directory {directory}")
        return
    
    output_dir_base = "..\\\\server\\\\bin\\\\" if proj_type == "Application" else "bin\\\\"
    
    files = get_files_from_dir(directory, name)
    
    # Preprocessor definitions
    defines = "WIN32;_WINDOWS;_CRT_SECURE_NO_WARNINGS;NOMINMAX;CRASH_LOGGING;_HAS_AUTO_PTR_ETC;GLM_FORCE_RADIANS;GLM_FORCE_CTOR_INIT;GLM_ENABLE_EXPERIMENTAL;COMMANDS_LOGGING;EQEMU_USE_OPENSSL;CPPHTTPLIB_OPENSSL_SUPPORT;ENABLE_SECURITY;BOOST_BIND_GLOBAL_PLACEHOLDERS;LUA_EQEMU;SANITIZE_LUA_LIBS;EMBPERL;EMBPERL_PLUGIN;PERLBIND_NO_STRICT_SCALAR_TYPES;"
    if name == "ucs": defines += "UCS;"
    if name == "queryserv": defines += "QSERV;"
    if name == "loginserver": defines += "LOGINSERVER;"
    if name == "zlib-ng": defines += "ZLIB_COMPAT;WITH_GZFILEOP;UNALIGNED_OK;UNALIGNED64_OK;NO_FSEEKO;"
    if proj_type == "Application": defines += "ZLIB_COMPAT;"
    if name == "uv_a": defines += "WIN32_LEAN_AND_MEAN;_WIN32_WINNT=0x0602;"

    # Include directories
    includes = ""
    if project.get('category') in ['Apps', 'Libs', 'Utils', 'Tests'] or name == 'common':
        includes += "..\\;..\\common;..\\common\\Patches;..\\common\\SocketLib;..\\common\\StackWalker;..\\libs\\zlibng;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\include\\mysql;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\include;..\\submodules\\glm;..\\submodules\\cereal\\include;..\\submodules\\fmt\\include;..\\submodules\\libuv\\include;..\\submodules\\libuv\\src;..\\submodules\\recastnavigation\\DebugUtils\\Include;..\\submodules\\recastnavigation\\Detour\\Include;..\\submodules\\recastnavigation\\DetourCrowd\\Include;..\\submodules\\recastnavigation\\DetourTileCache\\Include;..\\submodules\\recastnavigation\\Recast\\Include;..\\submodules\\websocketpp;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\include\\luajit;..\\libs\\luabind;..\\perl\\x64\\perl\\lib\\CORE;..\\libs\\perlbind\\include;"
    
    if project['name'] == "perlbind": includes += "..\\libs\\perlbind\\include;"
    if project['name'] == "luabind": includes += "..\\libs\\luabind;"
    if project['name'] == "uv_a": includes += "..\\submodules\\libuv\\include;..\\submodules\\libuv\\src;"
    if project['name'] == "zlib-ng": includes += "..\\libs\\zlibng;"
    if project['name'] == "fmt": includes += "..\\submodules\\fmt\\include;"
    if 'recastnavigation' in directory:
        # Add internal recast includes
        includes += "..\\submodules\\recastnavigation\\Detour\\Include;..\\submodules\\recastnavigation\\Recast\\Include;..\\submodules\\recastnavigation\\DebugUtils\\Include;..\\submodules\\recastnavigation\\DetourCrowd\\Include;..\\submodules\\recastnavigation\\DetourTileCache\\Include;"

    # Lib dependencies for Apps
    libs = [
        "bin\\$(Configuration)\\common.lib",
        "bin\\$(Configuration)\\zlib_ng1.lib",
        "bin\\$(Configuration)\\uv_a.lib",
        "bin\\$(Configuration)\\fmt.lib",
        "bin\\$(Configuration)\\Detour.lib",
        "bin\\$(Configuration)\\perlbind.lib",
        "bin\\$(Configuration)\\luabind.lib",
        "bin\\$(Configuration)\\cppunit.lib"
    ]
    
    # Filter out current project from dependencies
    current_lib = f"bin\\$(Configuration)\\{target_name}.lib"
    
    filtered_libs = [l for l in libs if l.lower() != current_lib.lower()]
    libs_str = ";".join(filtered_libs)
    
    lib_deps = f"{libs_str};..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\lib\\libmariadb.lib;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\lib\\libssl.lib;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\lib\\libcrypto.lib;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\lib\\libsodium.lib;..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\lib\\lua51.lib;..\\perl\\x64\\perl\\lib\\CORE\\libperl524.a;ws2_32.lib;psapi.lib;iphlpapi.lib;userenv.lib;user32.lib;advapi32.lib;kernel32.lib;gdi32.lib;winspool.lib;shell32.lib;ole32.lib;oleaut32.lib;uuid.lib;comdlg32.lib;"

    link_or_lib = "Link" if proj_type == "Application" else "Lib"
    link_options = ""
    post_build_xml = ""
    if proj_type == "Application":
        link_options = f"""<SubSystem>{"Console" if name != "loginserver" else "Console"}</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalDependencies>{lib_deps}%(AdditionalDependencies)</AdditionalDependencies>"""
        
        vcpkg_bin = "..\\vcpkg\\vcpkg-export-x64\\installed\\x64-windows\\bin"
        perl_bin = "..\\perl\\x64\\perl\\bin"
        
        dlls = [
            f"{vcpkg_bin}\\libmariadb.dll",
            f"{vcpkg_bin}\\libsodium.dll",
            f"{vcpkg_bin}\\lua51.dll",
            f"{vcpkg_bin}\\libcrypto-1_1-x64.dll",
            f"{vcpkg_bin}\\libssl-1_1-x64.dll",
            f"{vcpkg_bin}\\zlib1.dll",
            f"{perl_bin}\\perl524.dll",
            f"{perl_bin}\\libgcc_s_sjlj-1.dll",
            f"{perl_bin}\\libstdc++-6.dll",
            f"{perl_bin}\\libwinpthread-1.dll"
        ]
        
        # Deployment structure:
        # /server/bin/ -> .exe, .dll
        # /server/bin/build/ -> .pdb, .lib, .exp
        deploy_bin = "$(ProjectDir)..\\server\\bin\\"
        deploy_build = "$(ProjectDir)..\\server\\bin\\build\\"
        
        dll_cmds = " &amp; ".join([f'copy /Y "{d}" "{deploy_bin}"' for d in dlls])
        
        post_build_xml = f"""
    <PostBuildEvent>
      <Command>
        if not exist "{deploy_bin}" mkdir "{deploy_bin}"
        if not exist "{deploy_build}" mkdir "{deploy_build}"
        {dll_cmds}
        copy /Y "$(TargetDir)$(TargetName).exe" "{deploy_bin}"
        copy /Y "$(TargetDir)$(TargetName).pdb" "{deploy_build}"
        if exist "$(TargetDir)$(TargetName).lib" copy /Y "$(TargetDir)$(TargetName).lib" "{deploy_build}"
        if exist "$(TargetDir)$(TargetName).exp" copy /Y "$(TargetDir)$(TargetName).exp" "{deploy_build}"
      </Command>
    </PostBuildEvent>"""
    else:
        # For static libs, we don't usually want to bundle other libs into them
        # but if we do, we'd use AdditionalDependencies in <Lib>
        link_options = ""

    xml = f'''<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="17.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|x64">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>{guid}</ProjectGuid>
    <Keyword>Win32Proj</Keyword>
    <RootNamespace>{name}</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'" Label="Configuration">
    <ConfigurationType>{proj_type}</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>{proj_type}</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <WholeProgramOptimization>false</WholeProgramOptimization>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="Shared">
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <OutDir>$(SolutionDir){output_dir_base}$(Configuration)\\</OutDir>
    <IntDir>$(SolutionDir)obj\\$(ProjectName)\\$(Configuration)\\</IntDir>
    <TargetName>{target_name}</TargetName>
    <LinkIncremental>false</LinkIncremental>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <OutDir>$(SolutionDir){output_dir_base}$(Configuration)\\</OutDir>
    <IntDir>$(SolutionDir)obj\\$(ProjectName)\\$(Configuration)\\</IntDir>
    <TargetName>{target_name}</TargetName>
    <LinkIncremental>false</LinkIncremental>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>_DEBUG;{defines}%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <LanguageStandard>stdcpp20</LanguageStandard>
      <AdditionalIncludeDirectories>{includes}%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <MultiProcessorCompilation>false</MultiProcessorCompilation>
      <RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
      <DisableSpecificWarnings>4996;4091;4701;4703;4700;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <DebugInformationFormat>OldStyle</DebugInformationFormat>
    </ClCompile>
    <{link_or_lib}>
      {link_options}
    </{link_or_lib}>{post_build_xml}
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>NDEBUG;{defines}%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <LanguageStandard>stdcpp20</LanguageStandard>
      <AdditionalIncludeDirectories>{includes}%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <MultiProcessorCompilation>false</MultiProcessorCompilation>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <DisableSpecificWarnings>4996;4091;4701;4703;4700;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <DebugInformationFormat>OldStyle</DebugInformationFormat>
    </ClCompile>
    <{link_or_lib}>
      {link_options}
    </{link_or_lib}>{post_build_xml}
  </ItemDefinitionGroup>
  <ItemGroup>
'''
    for f in files:
        if f.endswith(('.cpp', '.c', '.cc')):
            xml += f'    <ClCompile Include="{to_rel(f)}">\n      <ObjectFileName>$(IntDir)%(RelativeDir)</ObjectFileName>\n    </ClCompile>\n'
    xml += '  </ItemGroup>\n  <ItemGroup>\n'
    for f in files:
        if f.endswith(('.h', '.hpp')):
            xml += f'    <ClInclude Include="{to_rel(f)}" />\n'
    xml += '  </ItemGroup>\n'
    
    xml += f'''  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>'''

    with open(f"code/{name}.vcxproj", 'w', encoding='utf-8-sig') as f:
        f.write(xml)

    # Generate Filters
    fxml = '''<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
'''
    # Unique filters
    filters = set()
    for f in files:
        rel = os.path.relpath(f, directory)
        parts = os.path.dirname(rel).split(os.sep)
        curr = ""
        for p in parts:
            if p and p != ".":
                curr = os.path.join(curr, p)
                filters.add(curr.replace("/", "\\"))
    
    for flt in sorted(list(filters)):
        fxml += f'    <Filter Include="{flt}">\n      <UniqueIdentifier>{{{uuid.uuid4()}}}</UniqueIdentifier>\n    </Filter>\n'
    
    fxml += '  </ItemGroup>\n  <ItemGroup>\n'
    for f in files:
        if f.endswith(('.cpp', '.c', '.cc')):
            rel = os.path.relpath(f, directory)
            flt = os.path.dirname(rel).replace("/", "\\")
            if flt and flt != ".":
                fxml += f'    <ClCompile Include="{to_rel(f)}">\n      <Filter>{flt}</Filter>\n    </ClCompile>\n'
            else:
                fxml += f'    <ClCompile Include="{to_rel(f)}" />\n'
    fxml += '  </ItemGroup>\n  <ItemGroup>\n'
    for f in files:
        if f.endswith(('.h', '.hpp')):
            rel = os.path.relpath(f, directory)
            flt = os.path.dirname(rel).replace("/", "\\")
            if flt and flt != ".":
                fxml += f'    <ClInclude Include="{to_rel(f)}">\n      <Filter>{flt}</Filter>\n    </ClInclude>\n'
            else:
                fxml += f'    <ClInclude Include="{to_rel(f)}" />\n'
    fxml += '  </ItemGroup>\n</Project>'
    
    with open(f"code/{name}.vcxproj.filters", 'w', encoding='utf-8-sig') as f:
        f.write(fxml)

def generate_solution():
    print("Generating code/EQEmu.sln...")
    sln = '''Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 18
VisualStudioVersion = 18.0.11222.15 d18.0
MinimumVisualStudioVersion = 10.0.40219.1
'''
    CATS = {
        "Apps": "{B1C38865-8F33-4F8A-9A8E-9877E9A3E7D1}",
        "Libs": "{C2D49976-9A44-4F9B-AB9F-0988F0B4F8E2}",
        "Utils": "{D3E5AA87-0B55-4A0C-AC0F-1099A1C5A9F3}",
        "Tests": "{E4F6BB98-1C66-4A1D-AD1A-2100A2D6A0F4}",
        "ThirdParty": "{F5A7CC09-2D77-482E-AE2A-3211A3E7A1F5}",
    }

    projects = active_projects()

    for cat_name, cat_guid in CATS.items():
        sln += f'Project("{{2150E333-8FDC-42A3-9474-1A3956D46DE8}}") = "{cat_name}", "{cat_name}", "{cat_guid}"\nEndProject\n'

    third_party_libs = ["fmt", "uv_a", "zlib-ng", "cppunit", "perlbind", "luabind", "Detour", "Recast", "DebugUtils", "DetourCrowd", "DetourTileCache"]

    for proj in projects:
        proj_name = proj["name"]
        proj_guid = normalize_guid(proj["guid"])
        proj_guid_raw = normalize_guid(proj["guid"], with_braces=False)
        proj_type = proj.get("type", "Application")

        sln += f'Project("{{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}}") = "{proj_name}", "{proj_name}.vcxproj", "{proj_guid}"\n'

        deps = []
        if proj_type == "Application":
            deps = all_static_library_projects(projects)
        elif proj_type == "StaticLibrary" and proj_name not in third_party_libs:
            deps = [p for p in all_static_library_projects(projects) if p["name"] in third_party_libs]

        if deps:
            sln += '\tProjectSection(ProjectDependencies) = postProject\n'
            for dep in deps:
                dep_guid = normalize_guid(dep["guid"])
                dep_guid_raw = normalize_guid(dep["guid"], with_braces=False)
                if dep_guid_raw != proj_guid_raw:
                    sln += f'\t\t{dep_guid} = {dep_guid}\n'
            sln += '\tEndProjectSection\n'
        sln += 'EndProject\n'

    sln += '''Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|x64 = Debug|x64
		Release|x64 = Release|x64
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
'''
    for project in projects:
        guid = normalize_guid(project["guid"])
        sln += f'\t\t{guid}.Debug|x64.ActiveCfg = Debug|x64\n'
        sln += f'\t\t{guid}.Debug|x64.Build.0 = Debug|x64\n'
        sln += f'\t\t{guid}.Release|x64.ActiveCfg = Release|x64\n'
        sln += f'\t\t{guid}.Release|x64.Build.0 = Release|x64\n'

    sln += '''	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(NestedProjects) = preSolution
'''
    for project in projects:
        cat_guid = CATS.get(project["category"])
        if cat_guid:
            sln += f'\t\t{normalize_guid(project["guid"])} = {cat_guid}\n'

    sln += '''	EndGlobalSection
EndGlobal
'''
    with open("code/EQEmu.sln", "w", encoding="utf-8-sig") as f:
        f.write(sln)

if __name__ == "__main__":
    if not os.path.exists("code"):
        os.makedirs("code")
    for p in active_projects():
        print(f"Generating {p['name']}...")
        generate_vcxproj(p)
    generate_solution()
    print("Done.")
