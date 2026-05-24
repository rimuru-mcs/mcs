# MSR Recovery v29 plugin loader
#
# EQEmu loads this file from the configured plugins directory.
# The recovered Windows runtime used /plugins, while older helper code
# expected quests/plugins.  Load both locations when present, but prefer
# the runtime plugins directory so helper modules such as MySQL.pl expose
# plugin::LoadMysql for cata_progression_utils.pl.
#
# Keep this file intentionally permissive: many legacy EQEmu/THJ plugins
# rely on package globals and do not run cleanly under strict.

package plugin;

sub load {
    my @plugin_dirs = (
        "plugins",
        "quests/plugins",
    );

    my %loaded_paths;

    foreach my $plugin_dir (@plugin_dirs) {
        next unless -d $plugin_dir;

        opendir(my $dh, $plugin_dir) or do {
            warn "plugin::load could not open plugin directory [$plugin_dir]: $!";
            next;
        };

        my @files = sort grep { /\.pl$/i && $_ ne "plugin.pl" } readdir($dh);
        closedir($dh);

        foreach my $file (@files) {
            my $path = "$plugin_dir/$file";
            next if $loaded_paths{$path}++;

            my $loaded = do $path;
            if (!defined $loaded) {
                warn "plugin::load failed to parse [$path]: $@" if $@;
                warn "plugin::load failed to do [$path]: $!" if !$@ && $!;
                warn "plugin::load failed for [$path]: returned undef" if !$@ && !$!;
            } elsif (!$loaded) {
                # A plugin file ending in a false value is usually harmless,
                # but log it so recovery audits can spot legacy oddities.
                warn "plugin::load loaded [$path] but it returned false";
            }
        }
    }

    # Recovery compatibility aliases.
    # If a legacy plugin somehow loaded helpers into main:: instead of plugin::,
    # expose the namespaced forms expected by quest scripts.
    no strict 'refs';
    foreach my $name (qw(LoadMysql LoadMysqlServer)) {
        if (!defined &{"plugin::$name"} && defined &{"main::$name"}) {
            *{"plugin::$name"} = \&{"main::$name"};
        }
    }
}

plugin::load();

1;
