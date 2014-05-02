# == Class: slurm
#
class slurm (
  # Role booleans
  $worker = true,
  $master = false,
  $slurmdbd = false,

  # Package ensures
  $munge_package_ensure = 'present',
  $slurm_package_ensure = 'present',
  $auks_package_ensure = 'present',
  $package_runtime_dependencies = $slurm::params::package_runtime_dependencies,

  # User/group management - master
  $manage_slurm_group = true,
  $slurm_user_group = 'slurm',
  $slurm_group_gid = 'UNSET',
  $manage_slurm_user = true,
  $slurm_user = 'slurm',
  $slurm_user_uid = 'UNSET',
  $slurm_user_comment = 'SLURM User',
  $slurm_user_home = '/home/slurm',
  $slurm_user_shell = '/bin/false',

  # Master config
  $manage_state_dir_nfs_mount = true,
  $state_dir_nfs_device = undef,
  $state_dir_nfs_options = 'rw,sync,noexec,nolock,auto',

  # Worker config
  $tmp_disk = '16000',

  # Partitions
  $partitionlist = [],
  $partitionlist_content = undef,
  $partitionlist_source = undef,

  # Managed directories
  $log_dir = '/var/log/slurm',
  $pid_dir = '/var/run/slurm',
  $spool_dir = '/var/spool/slurm',
  $shared_state_dir = '/var/lib/slurm',

  # slurm.conf - master
  $job_checkpoint_dir = '/var/lib/slurm/checkpoint',
  $slurmctld_log_file = '/var/log/slurm/slurmctld.log',
  $state_save_location = '/var/lib/slurm/state',

  # slurm.conf - worker
  $slurmd_log_file = '/var/log/slurm/slurmd.log',
  $slurmd_user = 'root',
  $slurmd_spool_dir = '/var/spool/slurm/slurmd',

  # slurm.conf - epilog/prolog
  $epilog = undef,
  $epilog_source = undef,
  $health_check_program = undef,
  $health_check_program_source = undef,
  $prolog = undef,
  $prolog_source = undef,
  $task_epilog = undef,
  $task_epilog_source = undef,
  $task_prolog = undef,
  $task_prolog_source = undef,

  # slurm.conf - overrides
  $config_override = {},

  # slurmdbd.conf
  $storage_type = 'accounting_storage/mysql',
  $storage_host = 'localhost',
  $storage_port = '3306',
  $storage_loc = 'slurmdbd',
  $storage_user = 'slurmdbd',
  $storage_pass = 'slurmdbd',

  # Munge
  $munge_key = undef,

  # auks
  $use_auks = false,

  # pam
  $use_pam = false,

  # Firewall / ports
  $manage_firewall = true,
  $slurmd_port = '6818',
  $slurmctld_port = '6817',
  $slurmdbd_port = '6819',

  # Logrotate
  $manage_logrotate = true,
) inherits slurm::params {

  # Parameter validations
  validate_bool($worker)
  validate_bool($master)
  validate_bool($slurmdbd)
  validate_bool($manage_slurm_group)
  validate_bool($manage_slurm_user)
  validate_bool($manage_state_dir_nfs_mount)
  validate_array($partitionlist)
  validate_hash($config_override)
  validate_bool($use_auks)
  validate_bool($use_pam)
  validate_bool($manage_firewall)
  validate_bool($manage_logrotate)

  $config_defaults = {
    'AccountingStorageHost' => $::fqdn,
    'AccountingStoragePass' => 'slurmdbd',
    'AccountingStoragePort' => $slurmdbd_port,
    'AccountingStorageType' => 'accounting_storage/slurmdbd',
    'AccountingStorageUser' => $storage_user,
    'AccountingStoreJobComment' => 'YES',
    'AuthType' => 'auth/munge',
    'CacheGroups' => '0',
    'CheckpointType' => 'checkpoint/none',
    'ClusterName' => 'linux',
    'CompleteWait' => '0',
    'ControlAddr' => $::hostname,
    'ControlMachine' => $::hostname,
    'CryptoType' => 'crypto/munge',
    'DefaultStorageHost' => $::fqdn,
    'DefaultStoragePass' => $storage_pass,
    'DefaultStoragePort' => $slurmdbd_port,
    'DefaultStorageType' => 'slurmdbd',
    'DefaultStorageUser' => $storage_user,
    'DisableRootJobs' => 'NO',
    'Epilog' => $epilog,
    'EpilogMsgTime' => '2000',
    'FastSchedule' => '1',
    'FirstJobId' => '1',
    'GetEnvTimeout' => '2',
    'GroupUpdateForce' => '0',
    'GroupUpdateTime' => '600',
    'HealthCheckInterval' => '0',
    'HealthCheckProgram' => $health_check_program,
    'InactiveLimit' => '0',
    'JobAcctGatherFrequency' => '30',
    'JobAcctGatherType' => 'jobacct_gather/linux',
    'JobCheckpointDir' => $job_checkpoint_dir,
    'JobCompType' => 'jobcomp/none',
    'JobRequeue' => '1',
    'KillOnBadExit' => '0',
    'KillWait' => '30',
    'MailProg' => '/bin/mail',
    'MaxJobCount' => '10000',
    'MaxJobId' => '4294901760',
    'MaxMemPerCPU' => '0',
    'MaxMemPerNode' => '0',
    'MaxStepCount' => '40000',
    'MaxTasksPerNode' => '128',
    'MessageTimeout' => '10',
    'MinJobAge' => '300',
    'MpiDefault' => 'none',
    'OverTimeLimit' => '0',
    'PluginDir' => '/usr/lib64/slurm',
    'PreemptMode' => 'OFF',
    'PreemptType' => 'preempt/none',
    'PriorityType' => 'priority/basic',
    'ProctrackType' => 'proctrack/pgid',
    'Prolog' => $prolog,
    'PropagatePrioProcess' => '0',
    'PropagateResourceLimits' => 'ALL',
    'ResvOverRun' => '0',
    'ReturnToService' => '0',
    'SchedulerTimeSlice' => '30',
    'SchedulerType' => 'sched/builtin',
    'SelectType' => 'select/linear',
    'SlurmUser' => $slurm_user,
    'SlurmctldDebug' => '3',
    'SlurmctldLogFile' => $slurmctld_log_file,
    'SlurmctldPidFile' => "${pid_dir}/slurmctld.pid",
    'SlurmctldPort' => $slurmctld_port,
    'SlurmctldTimeout' => '300',
    'SlurmdDebug' => '3',
    'SlurmdLogFile' => $slurmd_log_file,
    'SlurmdPidFile' => "${pid_dir}/slurmd.pid",
    'SlurmdPort' => $slurmd_port,
    'SlurmdSpoolDir' => $slurmd_spool_dir,
    'SlurmdTimeout' => '300',
    'SlurmSchedLogFile' => "${log_dir}/slurmsched.log",
    'SlurmSchedLogLevel' => '0',
    'SlurmdUser' => $slurmd_user,
    'StateSaveLocation' => $state_save_location,
    'SwitchType' => 'switch/none',
    'TaskEpilog' => $task_epilog,
    'TaskPlugin' => 'task/none',
    'TaskProlog' => $task_prolog,
    'TmpFS' => '/tmp',
    'TopologyPlugin'  => 'topology/none',
    'TrackWCKey' => 'no',
    'TreeWidth' => '50',
    'UsePAM' => bool2num($use_pam),
    'VSizeFactor' => '0',
    'WaitTime' => '0',
  }

  $slurm_conf = merge($config_defaults, $config_override)

  if $partitionlist_content {
    $partition_source   = undef
    $partition_content  = template($partitionlist_content)
  } elsif $partitionlist_source {
    $partition_source   = $partitionlist_source
    $partition_content  = undef
  } else {
    $partition_source   = undef
    $partition_content  = template('slurm/slurm.conf/master/slurm.conf.partitions.erb')
  }

  if $worker {
    class { 'slurm::worker': }
  }

  if $master {
    class { 'slurm::master': }
  }

  if $slurmdbd {
    class { 'slurm::slurmdbd': }
  }

}
