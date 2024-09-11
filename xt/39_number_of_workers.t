use strict;
use warnings;
use Test::More;
use File::Which;
use lib "xt/lib";
use CLI;

subtest default_worker_count_matches_system_procs => sub {
    if ($^O !~ /^(?:linux|darwin|bsd|sunos|solaris)$/) {
        plan skip_all => "Skipping test: Not running on a Unix-like system";
    }
    my $system_cpu_count;

    if ($^O eq 'darwin') {
        my $sysctl_path = which('sysctl');
        if (!$sysctl_path) {
            plan skip_all => "Skipping test: 'sysctl' command is not available";
        }
        $system_cpu_count = `sysctl -n hw.logicalcpu`;
        chomp($system_cpu_count);
    } else {
        my $nproc_path = which('nproc');
        if (!$nproc_path) {
            plan skip_all => "Skipping test: 'nproc' command is not available";
        }
        $system_cpu_count = `nproc`;
        chomp($system_cpu_count);
    }

    my $res = cpm("--worker-count");
    my $worker_count = $res->{out};
    chomp($worker_count);

    is($worker_count, $system_cpu_count, "Default worker count matches logical system core count $system_cpu_count");
};

subtest workers_can_be_set_manually => sub {
    my $res = cpm_install("-w", 4242, "--worker-count");
    my $worker_count = $res->{out};
    chomp($worker_count);

    is($worker_count, 4242, "Worker count set to 4242");
};

done_testing();
