# = Define: composer::config::entry
#
# == Parameters:
#
# [*ensure*]
#   Whether to apply or remove the config entry.
#
# [*entry*]
#   Parameter name.
#
# [*value*]
#   Configuration value.
#
# [*user*]
#   User which should own the configs.
#
# [*custom_home_dir*]
#   Home directory (in some cases it should be configurable).
#
define composer::config::entry(
  String $entry,
  String $user,
  String $ensure,
  $value = undef,
  Optional[String] $custom_home_dir = undef
  ) {

  if $caller_module_name != $module_name {
    warning('::composer::config::entry is not meant for public use!')
  }

  $home_dir = $custom_home_dir ? {
    undef   => "/home/${user}",
    default => $custom_home_dir,
  }

  $cmd_template = "${::composer::composer_full_path} config -g"
  $cmd          = $ensure ? {
    present => "${cmd_template} ${entry} ${value}",
    default => "${cmd_template} --unset ${entry}"
  }

  $unless = $ensure ? {
    present => "test `${cmd_template} ${entry}` = ${value}",

    # NOTE: in this case the parameter will be resetted to the default value so it cannot be checked properly
    # when to execute the command to remove the command or not.
    default => undef,
  }

  exec { "composer-config-entry-${entry}-${user}-${ensure}":
    command     => $cmd,
    path        => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    user        => $user,
    require     => Class['::composer'],
    environment => "HOME=${home_dir}",
    unless      => $unless
  }
}
