require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

define install_gems {
  ruby::gem { "${name} for ${ruby_global}":
    gem     => $name,
    ruby    => $ruby_global
  }
}

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  # include nginx

  # fail if FDE is not enabled
  # if $::root_encrypted == 'no' {
  #   fail('Please enable full disk encryption and try again')
  # }

  # Git
  Git::Config::Global <| title == "core.excludesfile" |> {
    value => "~/.gitignore_global"
  }

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }

  # Homebrew
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # Ruby
  $ruby_global = '2.0.0'

  class { 'ruby::global':
    version => $ruby_global
  }

  $ruby_gems = [
    'rapido-css',
    'sass-globbing',
    'oily_png',
    'susy',
    'homesick'
  ]

  install_gems { $ruby_gems: }

  ruby::plugin { 'rbenv-gemset':
    ensure => 'v0.5.3',
    source => 'jf/rbenv-gemset'
  }

  # Node.js
  $node_global = 'v0.10'

  class { 'nodejs::global':
    version => $node_global
  }

  $node_modules = [
    'coffee-script',
    'grunt-cli',
    'mimosa',
    'bower'
  ]

  nodejs::module { $node_modules:
    node_version => $node_global
  }

  # other modules
  include adium
  include alfred
  include btsync
  include ccleaner
  include chrome
  include cloudapp
  include codekit
  include dropbox
  include firefox
  include flux
  include istatmenus4
  include iterm2::dev
  include launchbar
  include macvim
  include mou
  include opera
  include sequel_pro
  include skype
  include sourcetree
  include textexpander
  include transmission
  include transmit
  include tunnelblick
  include vagrant
  include virtualbox
  include vlc

}
