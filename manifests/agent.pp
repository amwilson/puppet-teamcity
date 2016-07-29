class teamcity::agent(
  $agentname,
  $username = $teamcity::agent::params::username,
  $server_url = $teamcity::agent::params::server_url,
  $archive_name = $teamcity::agent::params::archive_name,
  $agent_dir = $teamcity::agent::params::agent_dir,
  $destination_dir = $teamcity::agent::params::destination_dir,
  $priority =  $teamcity::agent::params::priority,
  $teamcity_agent_mem_opts = $teamcity::agent::params::teamcity_agent_mem_opts,
  $temp_dir = $teamcity::agent::params::temp_dir
) inherits teamcity::agent::params {

  class {'teamcity::user_mgmt': } ->
  class {'teamcity::agent::install': } ->
  class {'teamcity::agent::config': } ->
  class {'teamcity::agent::service': } ->
  Class['teamcity::agent']

}
