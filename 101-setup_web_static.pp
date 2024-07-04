#101-setup_web_static.pp
# Puppet manifest to set up the web static deployment

class web_static {
  # Create directories
  file { '/data':
    ensure => 'directory',
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
  }

  file { '/data/web_static':
    ensure  => 'directory',
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0755',
    require => File['/data'],
  }

  file { '/data/web_static/releases':
    ensure  => 'directory',
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0755',
    require => File['/data/web_static'],
  }

  file { '/data/web_static/shared':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/web_static/releases'],
  }

  file { '/data/web_static/releases/test':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/web_static/releases'],
  }

  # Create index.html
  file { '/data/web_static/releases/test/index.html':
    ensure  => 'file',
    content => "<html>\n  <head>\n  </head>\n  <body>\n    Holberton School\n  </body>\n</html>\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/data/web_static/releases/test'],
  }

  # Create symbolic link
  file { '/data/web_static/current':
    ensure => 'link',
    target => '/data/web_static/releases/test',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File['/data/web_static/releases/test'],
  }
}

# Apply the web_static class
include web_static
