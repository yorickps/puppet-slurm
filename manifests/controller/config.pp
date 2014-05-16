# == Class: slurm::controller::config
#
class slurm::controller::config (
  $manage_state_dir_nfs_mount = false,
  $state_dir_nfs_device = undef,
  $state_dir_nfs_options = 'rw,sync,noexec,nolock,auto',
  $manage_logrotate = true,
) {

  include slurm

  File {
    owner => $slurm::slurm_user,
    group => $slurm::slurm_user_group,
  }

  file { 'StateSaveLocation':
    ensure  => 'directory',
    path    => $slurm::state_save_location,
    mode    => '0700',
    require => File[$slurm::shared_state_dir],
  }

  file { 'JobCheckpointDir':
    ensure  => 'directory',
    path    => $slurm::job_checkpoint_dir,
    mode    => '0700',
    require => File[$slurm::shared_state_dir],
  }

  if $manage_state_dir_nfs_mount {
    mount { 'StateSaveLocation':
      ensure  => 'mounted',
      name    => $slurm::state_save_location,
      atboot  => true,
      device  => $state_dir_nfs_device,
      fstype  => 'nfs',
      options => $state_dir_nfs_options,
      require => File['StateSaveLocation'],
    }
  }

  if $manage_logrotate {
    #Refer to: https://computing.llnl.gov/linux/slurm/slurm.conf.html#lbAJ
    logrotate::rule { 'slurmctld':
      path          => $slurm::slurmctld_log_file,
      compress      => true,
      missingok     => true,
      copytruncate  => false,
      delaycompress => false,
      ifempty       => false,
      rotate        => 10,
      sharedscripts => true,
      size          => '10M',
      create        => true,
      create_mode   => '0640',
      create_owner  => $slurm::slurm_user,
      create_group  => 'root',
      postrotate    => '/etc/init.d/slurm reconfig >/dev/null 2>&1',
    }
  }

}