class teamcity::agent::service(
$teamcity_agent_mem_opts = $teamcity::agent::teamcity_agent_mem_opts
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case downcase($::osfamily){
    'debian': {

      file { "/etc/init.d/build-agent":
        owner   => "root",
        group   => "root",
        mode    => 755,
        content => template("teamcity/build-agent.erb"),
      }->

      file { "/etc/profile.d/${teamcity::agent::priority}-teamcity.sh":
        owner   => "root",
        group   => "root",
        mode    => 755,
        content => template("${module_name}/teamcity-profile.erb"),
      }->

      exec { "update-rc.d build-agent defaults":
        cwd => "/etc/init.d/",
        path => '/usr/sbin/',
        creates => ["/etc/rc0.d/K20build-agent",
        "/etc/rc1.d/K20build-agent",
        "/etc/rc2.d/S20build-agent",
        "/etc/rc3.d/S20build-agent",
        "/etc/rc4.d/S20build-agent",
        "/etc/rc5.d/S20build-agent",
        "/etc/rc6.d/K20build-agent"
        ]
      }->

      service { "build-agent":
        ensure    => running,
        enable    => true,
        hasstatus => false,
      }
    }
    'windows': {
      service { "TCBuildAgent":
        ensure => running,
        enable => true,
      }
    }
  }
}
