# Pacrat

A minimal yet flexible, general-purpose package manager for a variety of
package types and OSs, geared toward installing CLI tools.

Pacrat does either of two simple things for any CLI-oriented package, depending on
their state:

- install
- upgrade

It utilizes your OS's underlying package manager (dnf, apt-get, brew, etc)
when possible, but also supports installation via `eget` and `git-clone`, plus
ad hoc via `curl/wget`, `gem`, `pip`, whatever.

It's a little like `ansible`, but much simpler: controlled by a single
INI-style config file, and run only locally.

That package spec config file is a `Nestfile` or `nest.ini` (think of a rat's
nest) with a declarative syntax that is simply a bunch of sections
representing individual packages. Here are some examples:

```ini
[clj-kondo]
doc     = 'static analyzer and linter for Clojure code that sparks joy'
details = 'https://github.com/clj-kondo/clj-kondo'
cmd     = 'clj-kondo'
linux   = 'curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo && chmod +x install-clj-kondo && ./install-clj-kondo'
brew    = 'borkdude/brew/clj-kondo'
verget  = 'clj-kondo --version | cut -f2 -d" "'
vermin  = '2024.11.14'
```

That shows a package named `clj-kondo` and that:

- The installed command (`cmd`) is `clj-kondo`, which will be installed if not
  already present (or upgraded depending on `vermin`)

- On a _Linux_ system, `curl` is used to fetch and run another installer script

- On a _Macos_ system, a simple `brew install ...` is used

- The _version_ (`verget`) is obtained by running the tool and a little
  cut-parsing (though `pacrat` almost always can auto-infer it, so `verget` is
  rarely needed)

- An upgrade may be performed if the presently installed version is older
  (gleaned version is older than `vermin`)

A very minimal (typical) example:

```ini
[just]
doc = 'a command runner' 
```

The `doc` isn't even needed -- it could have been a single line: `[just]`.
Several implicit things happen here: After inferreences, the actual spec
becomes:

```ini
[just] 
doc  = 'a command runner'
cmd  = 'just'
pkg  = 'just'
brew = 'just'
dnf  = 'just'
apt  = 'just'
pkg  = 'just'
nix  = 'nixos.just' # nix-env -iA just
verget = '<...some magic...>'
```

## What types of packages need Pacrat?

You already rely on your language's manager for libraries (`clj`,
`bundler/gem`, `pip`, `npm`, etc), but for anything that isn't handled by
those and isn't already on your system (and your colleagues' systems), you
have `pacrat`. Example tools are endless but categories include: linters, data
migrators, aws/github/etc CLIs, parsers, debuggers, and many more. Some tools
I personally like to have (up-to-date) on every system: `clj-kondo`, `cljfmt`,
`just`, `pgmig`, `direnv`, `clojure`, `markdownlint`, `podman`, `jq`,
`pgbouncer`, `ripgrep`, `sqlite`, `bat`, `curlie`, `dbeaver`, `fzf`, `redis`,
`ripgrep`, `yq`, `bbin`.

Many of those expected tools are necessary for keeping a sizeable project in
ship-shape, so you want eveyone on your team to have appropriate versions of
them installed. So you can put a `nest.ini` at the root of every major project
you work on. Even though such a file generally covers a _system_, it shouldn't
be a conflict to have several of them if you work on multiple projects.

The workflow of keeping a team's fleet of systems up-to-date then is:

- Alice creates and adds a `nest.ini` file to a project's repo

- Bob does a dnf/brew upgrade (or git-pull or eget or ...) and discovers that
  he's running a newer version of `just` than what's spec'd in `nest.ini`,
  so he adds the new version as `vermin`
  
- Carol pulls on the project (getting an update to `nest.ini`) and runs
  `pacrat` (maybe automatically via [captain](), and is prompted to upgrade to
  the new version that Bob put in

## Full Nestfile spec

Top level:

- `doc` — short description
- `details` — usually a link to project homepage
- `cmd` — the main CLI command that gets installed (its presence indicates
  it's already installed)
- `path` — a `PATH` entry that will be added to your running shell and its RC file

Installer modes (most override each other depending on OS):

- `clone` — use `git` to pull down source and keep up-to-date; overrides all
- `brew` — used when on a MacOS system and brew present
- `dnf` — used when on a RedHat-family system
- `apt` — used when on a Debian-family system
- `nix` — used when on a Nix-managed system
- `linux` — usually a `wget` or `curl`, untar/unzip, compile, `cp` sequence; overrides any `dnf`, `apt`, etc
- `macos` — same as `^^^` but for when running on mac; overrides `brew`
- `uni` — "universal" general purpose target that can have any shell commands
- `postop` — a post-operation step that can be done in any mode (eg, useful after a clone/pull)

Versioning:

- `vermin` — ensure the package being installed is at least this new
- `verget` — optional, explicit way to help `pacrat` determine the currently
  installed version

## Excluding packages

Sometimes you don't want Pacrat to control a package on your system. Maybe
it's a tool you wrote and you want the rest of your team to clone it, but you
want your own checkout to be different. For this, you can use the CSV env var
`PACRAT_IGNORE`.

## Options

- `PACRAT_NESTFILE` — `.ini` file location
- `PACRAT_IGNORES` — CSV of packages to be ignored in `nest.ini`
- `PACRAT_INTERACTIVE` — set to anything to be prompted before making changes
- `PACRAT_DRYRUN` — run without executing any install/upgrade commands
- `PACRAT_BASE` — base directory for clones, archives, etc (default `~/.pacrat`)
- `PACRAT_CLONES` — directory for git-clones (default `$PACRAT_BASE/clones`)
- `PACRAT_UNI` — directory for archives/extractions (default `$PACRAT_BASE/uni`)
- `PACRAT_BIN` — directory for binaries from eget (default `~/.local/bin`)

## Related installers/friends

- bbin
- eget

## Alternatives

I explored several alternatives when considering whether to create Pacrat. In
the end, I decided it was needed since the following all had some weaknesses
for my use case, and were too complex to tell my team, "just install this
thing this way and follow all its guides and ..."

- asdf
- nix
- zplug/zinit

## Questions

Should docker updates be a feature? Should it initiate pulls
