class teamcity::agent::params {
  $username = "teamcity"
  $server_url = "http://10.10.21.42"
  $archive_name = "buildAgent.zip"
  $agent_dir = "build-agent"

  case downcase($::osfamily) {
    'debian': {
      $destination_dir = '/var/tainted'
      $temp_dir = '/tmp'
    }
    'windows': {
      $destination_dir = 'c:/buildAgent'
      $temp_dir = 'c:/temp'
    }
    default: {
      fail('Operating system not supported for this module')
    }
  }
  $priority = "20"
  $teamcity_agent_mem_opts = "-Xms2048m -Xmx2048m -XX:+HeapDumpOnOutOfMemoryError"
}
