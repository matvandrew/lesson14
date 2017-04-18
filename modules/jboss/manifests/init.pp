class jboss{

  $jboss_user = 'jboss'
  $jboss_home = '/opt/jboss-as-7.1.1.Final'
  $java_version = '1.7.0'
  $jboss_url = 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz'
  $archive = '/opt/jboss-as-7.1.1.Final.tar.gz'


  package { 'java':
    name => "java-$java_version-openjdk",
    ensure => installed,
  }


  user { $jboss_user:
    ensure => present,
    home   => "${jboss_home}",
  }

 
  file { 'jboss_file':
    ensure => file,
    path   => $archive,
    source => $jboss_url,
  }
 
 
  exec { 'untar jboss':
    command => "tar xzf ${archive}",
    cwd     => '/opt',
    creates => $jboss_home,
    path    => ['/usr/bin', '/usr/sbin',],
    require => File['jboss_file'],
  }
 
 
  file {'add jboss_conf':
    ensure => directory,
    path   => '/etc/jboss-as',
    mode   => '0755',
  }
 
 
  exec { 'change owner':
    command => "chown -R ${jboss_user}:${jboss_user} ${jboss_home}",
    path    => ['/usr/bin', '/usr/sbin',],
    require => Exec['untar jboss'],
  }
 

  file { '/etc/jboss-as/jboss-as.conf':
    ensure  => file,
    content => template('jboss/jboss-as.erb'),
    mode    => '0644',
  }
 
  file { '/etc/init.d/jboss':
    ensure  => file,
    content => template('jboss/jboss-as-standalone-init.sh.erb'),
    mode    => '0755',
  }
 
  service { 'jboss':
    ensure => 'running',
    enable => true,
  }
}



class deploy{

  $app_url = "http://www.cumulogic.com/download/Apps/testweb.zip" 
  $app_file = "/opt/jboss-as-7.1.1.Final/standalone/deployments/testweb.zip"
  $app_folder = "/opt/jboss-as-7.1.1.Final/standalone/deployments/"

  package { 'unzip':
    ensure => installed,
  }

  file { $app_file:
      ensure  => file,
      source  => $app_url,
  }

  exec {'unzip':
      command => "unzip -j ${app_file} -d ${app_folder}",
      path => ['/usr/bin', '/usr/sbin',],
      creates => "${app_folder}/testweb.war",
	}

}