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

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  # if $::root_encrypted == 'no' {
  #   fail('Please enable full disk encryption and try again')
  # }

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  include ruby::1_8_7
  include ruby::1_9_2
  include ruby::1_9_3
  include ruby::2_0_0

  # common, useful packages
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
  $ruby_global = "1.9.3"

  class { 'ruby::global':
    version => $ruby_global
  }

  ruby::gem { "rapido-css for ${ruby_global}":
    gem     => 'rapido-css',
    ruby    => $ruby_global
  }

  ruby::gem { "sass-globbing for ${ruby_global}":
    gem     => 'sass-globbing',
    ruby    => $ruby_global
  }

  ruby::gem { "oily_png for ${ruby_global}":
    gem     => 'oily_png',
    ruby    => $ruby_global
  }

  ruby::plugin { 'rbenv-gemset':
    ensure => 'v0.5.3',
    source  => 'jf/rbenv-gemset'
  }

  # Node.js
  $node_global = "v0.10"

  class { 'nodejs::global':
    version => $node_global
  }

  nodejs::module { [ 'coffee-script', 'grunt-cli' ]:
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
  # include libreoffice
  include mou
  # include omnigraffle
  include opera
  include skype
  include sourcetree
  include spotify
  include textexpander
  include transmission
  include transmit
  include tunnelblick
  include vagrant
  include virtualbox
  include macvim
  include vlc

}