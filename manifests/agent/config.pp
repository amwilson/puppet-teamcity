class teamcity::agent::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case downcase($::osfamily){
    'debian': {

      exec {'Ensure buildAgent.properties exists on ubuntu':
        command => 'cp buildAgent.dist.properties buildAgent.properties',
        onlyif  => "test -e ${teamcity::agent::destination_dir}/${$teamcity::agent::agent_dir}/conf/buildAgent.properties",
        cwd     => "${teamcity::agent::destination_dir}/${$teamcity::agent::agent_dir}/conf",
        path    => $::path,
      } ->

      ini_setting { 'server url':
        ensure            => 'present',
        section           => '',
        key_val_separator => '=',
        path              => "${teamcity::agent::destination_dir}/conf/buildAgent.properties",
        setting           => 'serverUrl',
        value             => $::teamcity::agent::server_url,
      } ->

      ini_setting { 'agent name':
        ensure            => 'present',
        section           => '',
        key_val_separator => '=',
        path              => "${teamcity::agent::destination_dir}/conf/buildAgent.properties",
        setting           => 'name',
        value             => $::teamcity::agent::agentname,
      }
    }
    'windows': {

      exec {'Ensure buildAgent.properties exists on windows':
        command  => 'cp buildAgent.dist.properties buildAgent.properties',
        onlyif   => "if(Test-Path ${teamcity::agent::destination_dir}/conf/buildAgent.properties) { exit 1 } else { exit 0 }",
        cwd      => "${teamcity::agent::destination_dir}/conf",
        provider => 'powershell',
      } ->

      ini_setting { 'server url':
        ensure            => 'present',
        section           => '',
        key_val_separator => '=',
        path              => "${teamcity::agent::destination_dir}/conf/buildAgent.properties",
        setting           => 'serverUrl',
        value             => $::teamcity::agent::server_url,
      } ->

      ini_setting { 'agent name':
        ensure            => 'present',
        section           => '',
        key_val_separator => '=',
        path              => "${teamcity::agent::destination_dir}/conf/buildAgent.properties",
        setting           => 'name',
        value             => $::teamcity::agent::agentname,
      }

    }
  }
}
