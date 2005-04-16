use Module::Build;

my $build = Module::Build->new(
	module_name => 'SUPER',
	license     => 'perl',
	requires    =>
	{
		'Scalar::Util' => '',
	},
	build_requires =>
	{
		'Test::More' => '',
	},
	create_makefile_pl => 'traditional',
	sign               => 1,
);

$build->create_build_script();
